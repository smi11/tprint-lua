--[[

 tprint 0.3 Table Printer
 no warranty implied; use at your own risk

 Easily print reports and various data from tables in tabular format on your terminal.

 Supports settings for:

  - which columns to print
  - titles for column headers
  - calculated or fixed footers
  - setting how to format cells
  - setting values for missing data or calculating new data
  - filtering and sorting
  - adjusting column alignment, width, format and color
  - wrap long cells
  - preset or custom frames
  - and more...

 With optional `eansi` module, you can colorize your output for ansi terminals. Basic output
 of UTF-8 characters is also supported out of the box. With optional `luautf8` you can even
 format output for asian languages.

 Compatible with Lua 5.1+ and LuaJIT 2.0+

 author: Milan Slunečko
 url: https://github.com/smi11/tprint-lua

 DEPENDENCY

 Lua 5.1+ or LuaJIT 2.0+

 Optionally:
  - eansi
  - luautf8

 BASIC USAGE

 local tprint = require "tprint"

 local list = {
   {item = "socks",    price=10,  qty=5,  discount=0,   note="nice and warm"},
   {item = "gloves",   price=55,  qty=25, discount=0,   note="made of wool"},
   {item = "cardigan", price=255, qty=11, discount=0.1, note="a bit pricey"},
   {item = "hat",      price=44,  qty=33, discount=0.2, note="old fashioned"},
   {item = "shoes",    price=155, qty=4,  discount=0,   note="for running"},
 }

 -- more control
 local out = tprint.new(list)
 io.stdout:write(tostring(out), "\n")

 -- or simpler
 print(tprint(list))

  discount item     note          price qty
  ──────── ──────── ───────────── ───── ───
         0 socks    nice and warm    10   5
         0 gloves   made of wool     55  25
       0.1 cardigan a bit pricey    255  11
       0.2 hat      old fashioned    44  33
         0 shoes    for running     155   4

 See README.md for documentation

 HISTORY

 0.3 < active
      - completely rewritten all code
      - added asserts for all options
      - new options wrap, valign, value
      - added documentation README.md
      - written examples for each option
      - added busted tests
      - first public release
      - modified option value to accept f(row,col[,width])

 0.2
      - didn't track all the changes

 0.1
      - first draft

 LICENSE

 MIT License. See end of file for full text.

--]]

local M = {
  _VERSION     = 'tprint 0.3',
}

local unpack = table.unpack or unpack -- Luajit and Lua 5.1
-- fix stack offset for Lua 5.1 only
local stackofs = _VERSION == "Lua 5.1" and not jit and 1 or 0

-- l=left border, p=column padding, c=column separator, r=right border
--                  l   p   c   r
M.FRAME_SINGLE  = {"┌","─","┬","┐", -- top line
                   "│"," ","│","│", -- thead, tfoot, row content
                   "├","─","┼","┤", -- thead & tfoot separator line
                   "└","─","┴","┘", -- bottom line
                   "…"}             -- trim/cut indicator

M.FRAME_DOUBLE  = {"╔","═","╦","╗", -- 1-4 offsets
                   "║"," ","║","║", -- 5-8
                   "╠","═","╬","╣", -- 9-12
                   "╚","═","╩","╝", -- 13-16
                   "…"}

M.FRAME_ASCII   = {"+","-","+","+",
                   "|"," ","|","|",
                   "+","-","+","+",
                   "+","-","+","+",
                   "="}

M.FRAME_COMPACT = {"","","","",      -- no top line
                   ""," "," ","",    -- columns separated by 1 space
                   "","─"," ","",    -- thead & tfoot separator
                   "","","","",      -- no bottom line
                   "…"}

-- optional modules
local eansi, utf8

-- check if eansi and utf8 are available. if not, initialize shims
local function updateshim()

  --- eansi minimal shim -------------------------------

  local E = {}
  eansi = ((package or E).loaded or E)["eansi"]

  if not eansi then
    eansi = {
      _colortag = "$%b{}",
      _resetcmd = "",
    }
    eansi.toansi = function() return "" end
    eansi.nopaint = function(str)
      return (tostring(str or ""):gsub(eansi._colortag, ""):gsub("\27%[[%d:;]*m", ""))
    end
    eansi.rawpaint = eansi.nopaint
    eansi.paint = eansi.nopaint
    setmetatable(eansi, { __call = function (_, s) return eansi.paint(s) end})
  end

  --- basic utf8 shim ------------------------------------

  -- check luautf8 or built-in utf8 of Lua 5.3+
  utf8 = ((package or E).loaded or E)["lua-utf8"] or
         ((package or E).loaded or E)["utf8"]

  if not utf8 then
    utf8 = {
      -- luajit can't handle \0 in patterns so we need to use %z
      charpattern = "[%z\1-\127\194-\244][\128-\191]*"
    }
    utf8.len = function(s) --> number
      local _,len = s:gsub(utf8.charpattern,"")
      return len
    end
    utf8.offset = function (s,n,i) --> number or nil
      local t = {1}
      for c in s:gmatch(utf8.charpattern.."()") do
        t[#t+1] = c
      end
      i = i or (n>=0) and 1 or #t+1
      if n == 0 then
        n = 1
        while n <= #t and i >= t[n] do n = n + 1 end
        return t[n-1]
      end
      return t[i+n-1]
    end
  end

  --- add additional utf8 functions if missing ---------------------

  -- utf8 string.sub
  utf8.sub = utf8.sub or function(s,i,j) --> string
    assert(type(i)=="number","bad argument #2 to 'utf8.sub' (number expected)")
    i = utf8.offset(s,i) or (i<1) and 1 or #s+1
    if not j or j == -1 then j = nil
    elseif      j  >  0 then j = (utf8.offset(s,j+1) or #s+1)-1
    elseif      j  <  0 then j = (utf8.offset(s,j+1) or 1)-1
    else                     j = i-1
    end
    return s:sub(i,j)
  end

  -- utf8 string.format - fixes length of strings with pattern %s
  utf8.format = utf8.format or function(fmt, ...) --> string
    local args, strings, pos = {...}, {}, 0
    for spec in fmt:gmatch'%%.-([%a%%])' do
      pos = pos + 1
      local s = tostring(args[pos])
      if spec == 's' and s ~= '' then
        strings[#strings+1] = s
        args[pos] = '\1'..('\2'):rep((utf8.width or utf8.len)(s)-1)
      end
    end
    return (fmt:format(unpack(args))
               :gsub('\1\2*', function() return table.remove(strings, 1) end))
  end

  -- add utf8 to api
  M.utf8 = utf8
end

------------------
-- Helpers
------------------

-- formatted assert
local function fassert(test, msg, ...)
  if test then return test, msg, ... end
  if select('#',...) > 0 then
    msg = string.format(msg, ...)
  end
  error(msg or "assertion failed!", 3+stackofs)
end

-- memoize for functions taking one unique argument
local function memoize(f) --> new function f(x)
  local mem = {}
  setmetatable(mem, {__mode = "kv"})
  return function (x)
    local r = mem[x]
    if r == nil then
      r = f(x)
      mem[x] = r
    end
    return r
  end
end

-- modified string.rep so that it handles embedded ansi colors
-- char my contain 1 color followed by 1 character or only 1 character
local function crep(char,len) --> new string
  local color
  local function aux(c) color = color or c return "" end
  char = char:gsub(eansi._colortag, aux):gsub("\27%[[%d:;]*m", aux)
  return tostring(color or "")..string.rep(char,len)
end

-- ansi color aware string cut (with optional cut indicator)
function M.cut(s,length,indicator) --> string
  local len = utf8.width or utf8.len
  s = tostring(s)
  if len(eansi.nopaint(s)) <= length then
    return s
  end
  indicator = indicator or ""
  length = length - len(indicator)
  -- cut gradually as there may be color tags and/or
  -- characters that are wider than 1
  while len(eansi.nopaint(s)) > length do
    s = utf8.sub(s,1,-2)
  end
  return s..indicator
end

-- ansi color aware string slice
function M.slice(s,length) --> string or table of strings
  local len = utf8.width or utf8.len
  local ctag = "^"..eansi._colortag
  local chr = "^"..utf8.charpattern
  local spart
  local colp, coln = "", ""
  local parts = {}
  local sl, pos, e, pe, b, _ = 1, 1, 0
  s = tostring(s)
  repeat
    while e and len(eansi.nopaint(string.sub(s,sl,e))) < length do
      pe = e
      b,e = string.find(s,ctag,pos)
      if not e then
        b,e = string.find(s,"^\27%[[%d:;]*m",pos)
        if not e then
          _,e = string.find(s,chr,pos)
        else
          coln = string.sub(s,b,e)
        end
      else
        coln = string.sub(s,b,e)
      end
      if e then
        if length > 1 and len(eansi.nopaint(string.sub(s,sl,e))) > length then
          e = pe
          pos=e+1
          break
        end
        pos=e+1
      end
    end
    spart = string.sub(s,sl,e)
    if #spart > 0 then
      if not string.find(spart,ctag) or
         not string.find(spart,"^\27%[[%d:;]*m") then
        spart = colp..spart
      end
      parts[#parts+1] = spart
      colp = coln
    end
    sl = pos
  until e == nil or pos == 1
  return #parts > 1 and parts or #parts == 1 and parts[1] or ""
end

-- ansi color aware string pad
function M.pad(s, length, justify, padchar) --> new string
  local len = utf8.width or utf8.len
  padchar = padchar or " "
  s = tostring(s)
  if justify == "right" then
    return string.rep(padchar, length - len(eansi.nopaint(s)))..s
  elseif justify == "left" then
    return s..string.rep(padchar, length - len(eansi.nopaint(s)))
  end
  s = string.rep(padchar, math.floor((length - len(eansi.nopaint(s)))/2))..s
  return s..string.rep(padchar, length - len(eansi.nopaint(s)))
end

local function iscallable(f) --> boolean
  if type(f) == "function" then return true end
  local mt = getmetatable(f)
  return mt and mt.__call ~= nil
end

-- clone object including tables with cycles and metatables.
function M.clone(t, meta, cycles) --> new object
  cycles = cycles or {}
  local copy
  if type(t) == 'table' then
    if cycles[t] then
      copy = cycles[t]
    else
      copy = {}
      cycles[t] = copy
      for t_key, t_value in next, t, nil do
        copy[M.clone(t_key, meta, cycles)] = M.clone(t_value, meta, cycles)
      end
      if meta then
        setmetatable(copy, M.clone(getmetatable(t), meta, cycles))
      end
    end
  else
    copy = t
  end
  return copy
end

-- iterate t and perform f(k,v,...) on each element
function M.each(t, f, ...)
  for k,v in pairs(t) do
    f(k,v,...)
  end
end

-- map f(x, ...) --> 'x over table t, or extract column, or apply method
function M.map(t, f, ...) --> new table
  local nt = {}
  if type(f) == "function" then
    for k,v in pairs(t) do
      nt[k] = f(v, ...)
    end
  else
    for k, v in pairs(t) do
      local sel = v[f]
      if type(sel) == 'function' then
        nt[k] = sel(v, ...) -- method
      else
        nt[k] = sel         -- extract
      end
    end
  end
  return nt
end

-- accumulate elements of t using function f(a,b) --> value
function M.reduce(t, f, init) --> result of f
  local acc, first = init, init == nil
  for _, v in pairs(t) do
    if first then
      acc, first = v, false
    else
      acc = f(acc, v)
    end
  end
  return acc
end

-- filter list using function f(a) --> boolean
function M.filter(list, f) --> new list
  local nt = {}
  for _, v in ipairs(list) do
    if f(v) then nt[#nt+1] = v end
  end
  return nt
end

-- return array/list part of sparse table in correct order without holes
function M.nonil(t, limit) --> new list
  local n = 0
  for k in pairs(t) do -- find max integer key
    if type(k) == "number" and k%1 == 0 and k > n then
      n = k
    end
  end
  limit = limit or n
  local nt, tlen = {}
  for i = 1,n do
    tlen=#nt
    if tlen >= limit then break end
    nt[tlen+1] = t[i]
  end
  return nt
end

-- make lambda function out of string s
local function lambda(s) --> function
  local args, body = s:match([[^([%w,_%s]-):(.-)$]])
  assert(args and body, "bad string lambda")
  local fs = "return function(" .. args .. ") return " .. body .. " end"
  return assert((loadstring or load)(fs))()
end

-- use cache with lambda as loadstring/load is expensive
M.lambda = memoize(lambda)

-- sort table t, by columns col, with optional compare function f
local function tsort(t,col,f) --> new sorted table
  if col == nil or (type(col) == "table" and #col == 0) then return t end

  -- use custom compare function or default
  f = f or function(a,b)
    if type(a) == type(b) and type(a) ~= "boolean" and a ~= nil then
      return a < b
    else
      return (a and 1 or 0) < (b and 1 or 0)
    end
  end

  -- extract prefixes and sufixes and build lookup tables asc and low
  local lower = utf8.lower or string.lower
  local asc, low = {}, {}
  local lc, o
  local _, keys = next(t)
  for i, v in ipairs(col) do
    lc, col[i], o = v:match("([_]?)(.-)([+-<>]?)$")
    if keys[col[i]] == nil then
      error(string.format("invalid option 'sort' (column '%s' doesn't exist)", col[i]),3+stackofs)
    end
    asc[i] = o == "+" or o == "<" or o == ""
    low[i] = lc == "_"
  end

  -- sort copy of t
  local st = M.clone(t)
  table.sort(st, function (u,v)
    local a, b
    for i = 1, #col do
      a = u[col[i]]; a = low[i] and type(a) == "string" and lower(a) or a
      b = v[col[i]]; b = low[i] and type(b) == "string" and lower(b) or b
      if asc[i] then -- ascending
        if f(b, a) then return false end
        if f(a, b) then return true end
      else           -- descending
        if f(a, b) then return false end
        if f(b, a) then return true end
      end
    end
  end)

  return st
end

-- Extract keys from entire table
local function extractKeys(list) --> table
  local keys = {}
  for _, row in ipairs(list) do
    for k in pairs(row) do
      keys[k] = true
    end
  end
  local res = {}
  for k in pairs(keys) do
    res[#res+1] = k
  end
  table.sort(res)
  return res
end

-- cell vertical alignment / modifies t
local function vertical(t,n,valign,s)
  if valign=="top" then
    while #t < n do t[#t+1]=s end
  elseif valign=="bottom" then
    while #t < n do table.insert(t,1,s) end
  else
    local flip = true
    while #t < n do
      if flip then t[#t+1]=s
      else         table.insert(t,1,s)
      end
      flip = not flip
    end
  end
  return t
end

-- metatable with __tostring method -------------------------------------

local mt = {}
mt.__index = mt

-- serialize our table object
function mt:__tostring()
  local ot = {}

  local function out(...)
    for _,v in ipairs{...} do
      ot[#ot+1] = tostring(v)
    end
  end

  local format, width, align, frame = self.format, self.width, self.align, self.frame
  local row, rc

  -- build header, footer and all separator lines
  local head, foot = {}, {}
  local top, tsep, bottom = {}, {}, {}
  local v
  local hlines, flines = 0, 0

  for i in ipairs(self.column) do
    table.insert(top, eansi(crep(frame[2],width[i])))
    table.insert(tsep, eansi(crep(frame[10],width[i])))
    if self.header then
      v = self.wrap[i](self.header[i],width[i],frame[17])
      if type(v) == "string" then v = {v} end
      head[i] = {}
      if #v > hlines then hlines = #v end
      M.each(v, function(ri,vi)
        vi = M.cut(vi,width[i],frame[17])
        vi = M.pad(vi,width[i],align[i],frame[6])
        head[i][ri] = eansi(self.headerColor..vi)
      end)
    end
    if self.footer then
      v = type(self.footer[i]) == "function" and self.footer[i](self.datac[i]) or self.footer[i]
      v = self.wrap[i](format[i](v),width[i],frame[17])
      if type(v) == "string" then v = {v} end
      foot[i] = {}
      if #v > flines then flines = #v end
      M.each(v, function(ri,vi)
        vi = M.cut(vi,width[i],frame[17])
        vi = M.pad(vi,width[i],align[i],frame[6])
        foot[i][ri] = eansi(self.footerColor..vi)
      end)
    end
    table.insert(bottom, eansi(crep(frame[14],width[i])))
  end

  -- top frame
  if #eansi.nopaint(table.concat(top)) > 0 then
    out(eansi(frame[1]),table.concat(top,frame[3]),eansi(frame[4]),"\n")
  end

  -- header
  if self.header then
    for i in ipairs(self.column) do
      vertical(head[i],hlines,self.valign[i],eansi(self.headerColor..crep(frame[6],width[i])))
    end
    for i in ipairs(head[1]) do
      out(eansi(frame[5]),table.concat(M.map(head,i),frame[7]),eansi(frame[8]),"\n")
    end
  end

  -- header separator
  if self.headerSeparator then
    out(eansi(frame[9]),table.concat(tsep,frame[11]),eansi(frame[12]),"\n")
  end

  -- lines
  local lines
  for l = 1, self.rows do
    rc = (l % 2 == 0) and self.evenColor or self.oddColor
    row = {}
    lines = 0
    for i, key in ipairs(self.column) do
      local val = self.datac[i][l]
      if iscallable(val) then -- callback requested?
        val = val(self.data[l],key,width[i])
      end
      val = self.wrap[i](format[i](val),width[i],frame[17])
      if type(val) == "string" then val = {val} end
      row[i] = {}
      if #val > lines then lines = #val end
      M.each(val, function(ri,vi)
        vi = M.cut(vi,width[i],frame[17])
        vi = M.pad(vi,width[i],align[i],frame[6])
        row[i][ri] = eansi(rc..self.valueColor..vi)
      end)
    end
    for i in ipairs(self.column) do
      vertical(row[i],lines,self.valign[i],eansi(rc..self.valueColor..crep(frame[6],width[i])))
    end
    for i in ipairs(row[1]) do
      out(eansi(frame[5]),table.concat(M.map(row,i), eansi(rc..frame[7])),eansi(frame[8]),"\n")
    end
  end

  -- footer separator
  if self.footerSeparator then
    out(eansi(frame[9]),table.concat(tsep,frame[11]),eansi(frame[12]),"\n")
  end

  -- footer
  if self.footer then
    for i in ipairs(self.column) do
      vertical(foot[i],flines,self.valign[i],eansi(self.footerColor..crep(frame[6],width[i])))
    end
    for i in ipairs(foot[1]) do
      out(eansi(frame[5]),table.concat(M.map(foot,i),frame[7]),eansi(frame[8]),"\n")
    end
  end

  -- bottom frame
  if #eansi.nopaint(table.concat(bottom)) > 0 then
    out(eansi(frame[13]),table.concat(bottom,frame[15]),eansi(frame[16]),"\n")
  end

  -- remove last line feed
  if ot[#ot] == "\n" then ot[#ot] = nil end

  return table.concat(ot)
end

------------------
-- Constructor
------------------

function M.new(t, options)
  -- refresh shims in case eansi or utf8 was loaded later than tprint
  updateshim()

  assert(type(t)=="table","bad argument #1 to 'new' (table expected)")
  local len = utf8.width or utf8.len
  local o = options or {}

  -- column = list of column keys to be printed
  o.column = o.column == nil and extractKeys(t) or o.column
  fassert(type(o.column) == "table" and #o.column > 0,
          "invalid option 'column' (table with at least one column name expected)")

  -- apply filter if provided
  if type(o.filter) == "function" then
    t = M.filter(t,o.filter)
  elseif o.filter ~= nil then
    error("invalid option 'filter' (function expected)",2+stackofs)
  end

  -- sort = order for columns
  if type(o.sort) == "string" then
    o.sort = {o.sort}
  elseif type(o.sort) == "table" then
    for i in ipairs(o.sort) do
      fassert(type(o.sort[i]) == "string",
              "invalid option 'sort' for index %i, (string expected)",i)
    end
  elseif o.sort ~= nil then
    error("invalid option 'sort' (string or table expected)",2+stackofs)
  end

  -- sortCmp custom compare function f(a,b) --> boolean
  fassert(type(o.sortCmp) == "function" or o.sortCmp == nil,
          "invalid option 'sortCmp' (function expected)")

  -- save sorted and filtered table for later
  o.data = tsort(t, o.sort, o.sortCmp)

  -- header = boolean, table or function f(s) -> string
  if o.header == nil or o.header == true then
    o.header = M.clone(o.column)
  elseif iscallable(o.header) then
    o.header = M.map(o.column, o.header)
  elseif type(o.header)=="table" then
    for i, col in ipairs(o.column) do
      o.header[i] = o.header[i] == nil and o.header[col] or o.header[i]
      o.header[i] = o.header[i] == nil and o.column[i] or o.header[i]
      if iscallable(o.header[i]) then
        o.header[i] = o.header[i](o.column[i])
      end
      fassert(type(o.header[i])=="string",
              "invalid option 'header' for column %i (string or function expected)",i)
    end
    -- luacheck: ignore 542
  elseif o.header == false then
    -- empty if branch (W542) -- on purpose
  else
    error("invalid option 'header' (boolean, table or function expected)",2+stackofs)
  end

  -- footer = table or function f(t) -> value
  if iscallable(o.footer) then
    local f = o.footer
    o.footer = {}
    M.each(o.column, function(i) o.footer[i] = f end)
  elseif type(o.footer)=="table" then
    for i, col in ipairs(o.column) do
      o.footer[i] = o.footer[i] == nil and o.footer[col] or o.footer[i]
      if o.footer[i] ~= nil then
        fassert(type(o.footer[i])=="string" or type(o.footer[i])=="function",
                "invalid option 'footer' for column %i (string or function expected)",i)
      end
    end
  elseif o.footer ~= nil then
    error("invalid option 'footer' (table or function expected)",2+stackofs)
  end

  -- draw header and footer separator line
  o.headerSeparator = o.headerSeparator == nil and type(o.header) == "table" or o.headerSeparator
  o.footerSeparator = o.footerSeparator == nil and o.footer ~= nil or o.footerSeparator

  -- value = optional functions to apply to every item by columns: f(self,val) -> value
  fassert(type(o.value)=="table" or o.value == nil,
          "invalid option 'value' (table expected)")
  o.value = o.value or {}
  for i, col in ipairs(o.column) do
    if o.value[i] == nil then
      o.value[i] = o.value[col]
      if o.value[i] == nil then
        o.value[i] = function(r,c) return r[c] end
      end
    end
    fassert(type(o.value[i])=="function",
            "invalid option 'value' for column %i (function expected)",i)
  end

  -- format specifiers for string.format for each column
  -- or function that returns formatted string
  fassert(type(o.format)=="table" or o.format == nil,
          "invalid option 'format' (table expected)")
  o.format = o.format or {}
  for i, col in ipairs(o.column) do
    if o.format[i] == nil then
      o.format[i] = o.format[col]
      if o.format[i] == nil then
        o.format[i] = function(val)
          return val == nil and "" or tostring(val)
        end
      end
    end
    if type(o.format[i]) == "string" then
      local fmt = o.format[i]
      o.format[i] = function(val)
        return val ~= nil and utf8.format(fmt, val) or ""
      end
    end
    fassert(type(o.format[i])=="function",
            "invalid option 'format' for column %i (string or function expected)",i)
  end

  -- wrap = boolean or function f(value) -> value [, value...]
  if o.wrap == nil or type(o.wrap) == "boolean" then
    local f = o.wrap == nil and M.cut or o.wrap and M.slice or M.cut
    o.wrap = {}
    M.each(o.column, function(i) o.wrap[i] = f end)
  elseif iscallable(o.wrap) then
    local f = o.wrap
    o.wrap = {}
    M.each(o.column, function(i) o.wrap[i] = f end)
  elseif type(o.wrap)=="table" then
    for i, col in ipairs(o.column) do
      if o.wrap[i] == nil then o.wrap[i] = o.wrap[col] end
      if o.wrap[i] == nil or type(o.wrap[i]) == "boolean" then
        o.wrap[i] = o.wrap[i] and M.slice or M.cut
      end
      fassert(type(o.wrap[i])=="function",
              "invalid option 'wrap' for column %i (boolean or function expected)",i)
    end
  elseif o.wrap ~= nil then
    error("invalid option 'wrap' (boolean or function expected)",2+stackofs)
  end

  -- align column "left", "right" or "center"
  -- by default numbers will be "right" and all else "left"
  local align={left=true, right=true, center=true}
  o.align = o.align == nil and {} or o.align
  if type(o.align) == "string" then
    if align[o.align] then
      local a = o.align
      o.align = {}
      M.each(o.column, function(i) o.align[i] = a end)
    else
      error("invalid option 'align' ('left', 'right' or 'center' expected)",2+stackofs)
    end
  elseif type(o.align) ~= "table" then
      error("invalid option 'align' (string or table expected)",2+stackofs)
  end

  -- valign column "top", "middle" or "bottom"
  -- by default all columns will be "top"
  local valign={top=true, middle=true, bottom=true}
  o.valign = o.valign == nil and {} or o.valign
  if type(o.valign) == "string" then
    if valign[o.valign] then
      local a = o.valign
      o.valign = {}
      M.each(o.column, function(i) o.valign[i] = a end)
    else
      error("invalid option 'valign' ('top', 'middle' or 'bottom' expected)",2+stackofs)
    end
  elseif type(o.valign) == "table" then
    for i, col in ipairs(o.column) do
      if o.valign[i] == nil then o.valign[i] = o.valign[col] end
      o.valign[i] = o.valign[i] == nil and "top" or o.valign[i]
      fassert(valign[o.valign[i]],
              "invalid option 'valign' for column %i ('top', 'middle' or 'bottom' expected)",i)
    end
  else
    error("invalid option 'valign' (string or table expected)",2+stackofs)
  end

  -- set width from "data", adjust to fit "auto" or set width by number n
  local iswdef = {auto=true, data=true}
  if o.widthDefault == nil then o.widthDefault = "auto" end
  if type(o.widthDefault) == "number" then
    fassert(o.widthDefault>=1,"invalid option 'widthDefault' (number >= 1 expected)")
  end
  fassert(type(o.widthDefault)=="number" or iswdef[o.widthDefault],
          "invalid option 'widthDefault' (number or 'auto' or 'data' expected)")

  -- if you leave width blank for any column widthDefault will be applied to that column
  if o.width == nil then o.width = {} end
  fassert(type(o.width)=="table", "invalid option 'width' (table expected)")
  for i, col in ipairs(o.column) do
    if o.width[i] == nil then
      o.width[i] = o.width[col]
      if o.width[i] == nil then
        o.width[i] = o.widthDefault
      end
    end
    if type(o.width[i]) == "number" then
      fassert(o.width[i]>=1,"invalid option 'width' for column %i (number >= 1 expected)",i)
    end
    fassert(type(o.width[i])=="number" or iswdef[o.width[i]],
            "invalid option 'width' for column %i (number or 'auto' or 'data' expected)",i)
  end
  o.width=M.nonil(o.width) -- remove possible hash part

  -- total table width (width of terminal is a good value)
  if o.totalWidth == nil then o.totalWidth = math.huge end
  fassert(type(o.totalWidth)=="number" and o.totalWidth>=1,
          "invalid option 'totalWidth' (number >= 1 expected)")

  -- select box-drawing character set for frame
  o.frame = o.frame == nil and M.FRAME_COMPACT or o.frame
  fassert(type(o.frame) == "table" and #o.frame == 17,
          "invalid option 'frame' (table with 17 strings expected)")
  for k = 1,17 do
    local v = o.frame[k]
    fassert(type(v)=="string",
            "invalid option 'frame' at index %i (string expected)",k)
    if k == 6 then
      fassert(len(eansi.nopaint(v)) == 1,
              "invalid option 'frame' at index %i (1 UTF-8 character expected)",k)
    end
    if k % 4 == 2 then
      fassert(len(eansi.nopaint(v))<2,
              "invalid option 'frame' at index %i (0 or 1 UTF-8 characters expected)",k)
    end
    local cc = v:gsub(eansi._colortag, "\255"):gsub("\27%[[%d:;]*m", "\255")
                :gsub(utf8.charpattern,"P"):gsub("P+","P")
                :gsub("\255","C")
--    print(k,v,cc,utf8.charpattern)
    fassert(v=="" or cc=="CP" or cc=="P",
            "invalid option 'frame' at index %i (only one color within string expected)",k)
  end

  -- colors
  o.frameColor  = eansi.toansi(o.frameColor )
  o.headerColor = eansi.toansi(o.headerColor)
  o.footerColor = eansi.toansi(o.footerColor)
  o.valueColor  = eansi.toansi(o.valueColor  )
  o.oddColor    = eansi.toansi(o.oddColor   )
  o.evenColor   = eansi.toansi(o.evenColor  )

  -- apply frame color to non-empty elements of frame
  if #o.frameColor > 0 then
    o.frame = M.map(o.frame, function(item)
      return item == "" and "" or o.frameColor..item
    end)
    o.frame[6] = eansi.nopaint(o.frame[6]) -- no colors for pad character
    o.frame[17] = eansi.nopaint(o.frame[17]) -- no colors for trim/cut indicator
  end

  -- iterate all rows and columns and get maxWidth and align
  local maxWidth = {}
  local datac = M.map(o.column, function() return {} end)
  local rows
  for rowi, rowt in ipairs(o.data) do
    for i, ckey in ipairs(o.column) do
      local val, callback = o.value[i](rowt,ckey)
      local v = eansi.nopaint(o.format[i](val))
      maxWidth[i] = math.max(len(tostring(v)),(maxWidth[i] or 0))
      o.align[i] = o.align[i] or o.align[ckey] or type(val) == "number" and "right" or "left"
      datac[i][rowi] = callback and callback or val
    end
    rows=rowi
  end
  o.datac = datac
  o.rows = rows

  -- include header and footer in maxWidth calculation
  for i in ipairs(o.column) do
    local v1, v2 = o.header and eansi.nopaint(o.header[i])
    if o.footer then
      v2 = type(o.footer[i]) == "function" and o.footer[i](datac[i]) or o.footer[i]
    end
    v2 = v2 and eansi.nopaint(o.format[i](v2))
    maxWidth[i] = math.max((maxWidth[i] or 0),len(v1 or ""),len(v2 or ""))
    fassert(align[o.align[i]],
            "invalid option 'align' in column %i ('left', 'right' or 'center' expected)",
            i)
    fassert(valign[o.valign[i]],
            "invalid option 'valign' in column %i ('top', 'middle' or 'bottom' expected)",
            i)
  end

  -- mark columns that need width adjustment
  local adjust = {}
  for i in ipairs(o.column) do
    if o.width[i] == "data" then
      o.width[i] = maxWidth[i]
    elseif o.width[i] == "auto" then
      o.width[i] = 1
      adjust[#adjust+1] = i
    end
  end

  -- adjust column width
  local function add(a,b) return a+b end
  local frame = o.frame
  local fwidth = len(eansi.nopaint(frame[5]..frame[8]))+(#o.column-1)*len(eansi.nopaint(frame[7]))
  local cwidth = fwidth + M.reduce(o.width,add)
  local i = 1
  while ( #adjust > 0            ) and
        ( cwidth  < o.totalWidth ) do
    o.width[adjust[i]] = o.width[adjust[i]] + 1
    if o.width[adjust[i]] >= maxWidth[adjust[i]] then
       table.remove(adjust,i)
    end
    i = ( i < #adjust ) and i + 1 or 1
    cwidth = fwidth + M.reduce(o.width,add)
  end

  o.totalWidth = cwidth

  return setmetatable(o, mt)
end

-- make sure eansi and utf8 shims are initialized
updateshim()

-- allow constructor to be called just by module name
return setmetatable(M, { __call = function(_, ...) return M.new(...) end })

--[[

MIT License
Copyright (c) 2020-2022 Milan Slunečko

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without imitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or other
dealings in this Software without prior written authorization.

--]]
