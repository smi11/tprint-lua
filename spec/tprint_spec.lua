local tp = require "tprint"

-- also test character width processing if luautf8 is available
-- luacheck: ignore 311 value assigned to variable lutf8 is unused
local isok, lutf8 = pcall(require,"lua-utf8")
if isok then
  lutf8 = require "lua-utf8"
else
  lutf8 = nil
end

describe("utf8.len(s)", function()
  it("should return number of utf8 characters", function()
    assert.equal(7,tp.utf8.len"no utf8")
    assert.equal(5,tp.utf8.len"čšžćđ")
    assert.equal(9,tp.utf8.len"おはようございます")
  end)
end)

describe("utf8.offset(s,n,i)", function()
  it("should return offset of utf8 character in bytes", function()
    assert.equal(5,tp.utf8.offset("čšžćđ",3))
    assert.equal(3,tp.utf8.offset("čšžćđ",0,3))
    assert.equal(7,tp.utf8.offset("čšžćđ",-2))
    assert.equal(1,tp.utf8.offset("čšžćđ",1))
  end)
end)

describe("utf8.sub(s,i,j)", function()
  it("should return substring", function()
    assert.equal("8",tp.utf8.sub("no utf8",-1))
    assert.equal("o utf",tp.utf8.sub("no utf8",2,-2))
    assert.equal("o utf",tp.utf8.sub("no utf8",2,6))
    assert.equal("",tp.utf8.sub("no utf8",2,0))
    assert.equal("đ",tp.utf8.sub("čšžćđ",-1))
    assert.equal("ž",tp.utf8.sub("čšžćđ",3,-3))
    assert.equal("",tp.utf8.sub("čšžćđ",3,0))
    assert.equal("šžć",tp.utf8.sub("čšžćđ",2,4))
    assert.equal("ようございます",tp.utf8.sub("おはようございます",3))
  end)
end)

describe("utf8.format(fmt,...)", function()
  it("should format with correct length for %s", function()
    assert.equal("     č š ž",tp.utf8.format("%10s","č š ž"))
    assert.equal("č š ž     ",tp.utf8.format("%-10s","č š ž"))
  end)
end)

describe("cut(s,len[,ind])", function()
  it("should cut string at specified len", function()
    assert.equal("hello",tp.cut("hello world",5))
    assert.equal("hello world",tp.cut("hello world",100))
    assert.equal("h",tp.cut("hello world",1))
    assert.equal("",tp.cut("hello world",0))
    assert.equal("${red}čšžćđ",tp.cut("${red}čšžćđ ${green}world",5))
    assert.equal("h\27[1mello",tp.cut("h\27[1mello world",5))
  end)
  it("should cut string with indicator", function()
    assert.equal("hell/",tp.cut("hello world",5,"/"))
    assert.equal("hello",tp.cut("hello",5,"/"))
    assert.equal("hel//",tp.cut("hello world",5,"//"))
    assert.equal("${red}čšžć/",tp.cut("${red}čšžćđ ${green}world",5,"/"))
    assert.equal("h\27[1mell/",tp.cut("h\27[1mello world",5,"/"))
  end)
  if lutf8 then
    it("should acknowledge wide characters", function()
      tp{{dummy=""}} -- update shims for utf8 and eansi
      assert.equal("",tp.cut("おはようございます",1))
      assert.equal("お",tp.cut("おはようございます",2))
      assert.equal("お",tp.cut("おはようございます",3))
      assert.equal("おは",tp.cut("おはようございます",4))
    end)
  end
end)

describe("slice(s,len)", function()
  it("should slice string at specified len", function()
    assert.same({"h","e","l","l","o"},tp.slice("hello",1))
    assert.same({"hello"," worl","d"},tp.slice("hello world",5))
    assert.same("hello world",tp.slice("hello world",15))
    -- utf8
    assert.same({"č","š","ž","ć","đ"},tp.slice("čšžćđ",1))
    assert.same({"hello"," čšžć","đ"},tp.slice("hello čšžćđ",5))
    assert.same("hello čšžćđ",tp.slice("hello čšžćđ",15))
    -- utf8, color tags and ansi escapes
    assert.same({"č","š","${red}ž","${red}ć","${red}đ"},tp.slice("čš${red}žćđ",1))
    assert.same({"${green}hello","${green} ${red}čšžć","${red}đ"},tp.slice("${green}hello ${red}čšžćđ",5))
    assert.same({"${green}hello","${green} ${red}čš\27[1mžć","\27[1mđ"},tp.slice("${green}hello ${red}čš\27[1mžćđ",5))
    assert.same("hello ${green}čšžćđ",tp.slice("hello ${green}čšžćđ",15))
  end)
  if lutf8 then
    it("should acknowledge wide characters", function()
      tp{{dummy=""}} -- update shims for utf8 and eansi
      assert.same({"お","は","よ","う","x","y"},tp.slice("おはようxy",1))
      assert.same({"お","は","よ","う","xy"},tp.slice("おはようxy",2))
      assert.same({"お","は","よ","うx","y"},tp.slice("おはようxy",3))
      assert.same({"おは","よう","xy"},tp.slice("おはようxy",4))
      assert.same({"おは","ようx","y"},tp.slice("おはようxy",5))
      assert.same({"おはよ","うxy"},tp.slice("おはようxy",6))
      assert.same({"おはよ","うxy"},tp.slice("おはようxy",7))
      assert.same({"おはよう","xy"},tp.slice("おはようxy",8))
      assert.same({"おはようx","y"},tp.slice("おはようxy",9))
      assert.same("おはようxy",tp.slice("おはようxy",10))
    end)
  end
end)

describe("pad(s,len,justify,ch)", function()
  it("should pad string", function()
    assert.same("hello.....",tp.pad("hello",10,"left","."))
    assert.same(".....hello",tp.pad("hello",10,"right","."))
    assert.same("..hello...",tp.pad("hello",10,"center","."))
    -- longer strings
    assert.same("hello",tp.pad("hello",1,"left","."))
    assert.same("hello",tp.pad("hello",2,"right","."))
    assert.same("hello",tp.pad("hello",3,"center","."))
    -- utf8
    assert.same("čšžćđ.....",tp.pad("čšžćđ",10,"left","."))
    assert.same(".....čšžćđ",tp.pad("čšžćđ",10,"right","."))
    assert.same("..čšžćđ...",tp.pad("čšžćđ",10,"center","."))
    -- utf8, color tags and ansi escapes
    assert.same("čšž\27[1mćđ${red}.....",tp.pad("čšž\27[1mćđ${red}",10,"left","."))
    assert.same(".....${red}čšž\27[1mćđ",tp.pad("${red}čšž\27[1mćđ",10,"right","."))
    assert.same("..${red}čšž\27[1mćđ${red}...",tp.pad("${red}čšž\27[1mćđ${red}",10,"center","."))
  end)
end)

describe("clone(t[,meta])", function()
  it("should make copy of scalars", function()
    local a="hello" assert.are.same(a,tp.clone(a))
    local b=123     assert.are.same(b,tp.clone(b))
    local c=true    assert.are.same(c,tp.clone(c))
  end)
  it("should make copy of lists", function()
    local a={1,2,"a","b"}
    assert.are.same(a,tp.clone(a))
  end)
  it("should make copy of tables", function()
    local a={}
    assert.are.same(a,tp.clone(a))
    local b={a="a", b="b",c="c"}
    assert.are.same(b,tp.clone(b))
  end)
  it("should make deep copy of tables with cycles", function()
    local a={1,2,{"a","b", x="x", {{{y="y",2}}}}, c="c"}
    a.cycle = a
    assert.are.same(a, tp.clone(a))
  end)
  it("should make deep copy of tables with cycles and metatables", function()
    local mt={"something"}
    local b={1,2,3}
    setmetatable(b,mt)
    local a={1,2,{"a","b", x="x", {{{y="y",2}}}}, c="c", d=b}
    a.cycle = a
    local copy = tp.clone(a,true)
    assert.are.same(a, copy)
    assert.are.same(getmetatable(a.d), getmetatable(copy.d))
  end)
end)

describe("map(t,f[,...])", function()
  local function mul(x) return x*2 end
  local function add(x,y) return x+y end
  it("should map function f over table", function()
    assert.are.same({2,4,6},tp.map({1,2,3},mul))
    assert.are.same({2,4,6,a=20},tp.map({1,2,3,a=10},mul))
    assert.are.same({2},tp.map({1},mul))
    assert.are.same({},tp.map({},mul))
    assert.are.same({2,3,4},tp.map({1,2,3},add,1))
    assert.are.same({3,4,5,a=12},tp.map({1,2,3,a=10},add,2))
    assert.are.same({0},tp.map({1},add,-1))
    assert.are.same({},tp.map({},add,1))
  end)
  it("should extract fields", function()
    assert.are.same({1,"a",4},tp.map({{1,2,3},{"a","b","c"},{4,5,6}},1))
    assert.are.same({3,"c",6},tp.map({{1,2,3},{"a","b","c"},{4,5,6}},3))
    assert.are.same({},tp.map({{1,2,3},{"a","b","c"},{4,5,6}},10))
    local r1 = { value = 123, word = "strong" }
    local r2 = { value = 321, word = "weak" }
    assert.are.same({"strong","weak"},tp.map({r1,r2},"word"))
    assert.are.same({123,321},tp.map({r1,r2},"value"))
    assert.are.same({},tp.map({r1,r2},"missing"))
  end)
  it("should evaluate methods", function()
    local o_mt = {
      getword = function(self, prefix) return tostring(prefix or "")..self.word end,
      getval = function(self, dx) return self.value + (dx and dx or 0) end
    }
    o_mt.__index = o_mt
    local r1 = { value = 123, word = "strong" }
    setmetatable(r1,o_mt)
    local r2 = { value = 321, word = "weak" }
    setmetatable(r2,o_mt)
    assert.are.same({"strong","weak"},tp.map({r1,r2},"getword"))
    assert.are.same({"Hulk strong","Hulk weak"},tp.map({r1,r2},"getword", "Hulk "))
    assert.are.same({123,321},tp.map({r1,r2},"getval"))
    assert.are.same({133,331},tp.map({r1,r2},"getval",10))
    assert.are.same({},tp.map({r1,r2},"none",10))
  end)
  it("should report error", function()
    local r1 = { value = 123, word = "strong" }
    local r2 = { value = 321, word = "weak" }
    -- should've provided a list of records instad of list of numbers
    local e = "attempt to index a number value (local 'v')"
    if _VERSION == "Lua 5.1" or _VERSION == "Lua 5.2" then
      e = "attempt to index local 'v' (a number value)"
    end
    assert.has_error(function() tp.map({1,2,3},"missing") end, e)
    -- should've used x.value in f1
    local f1 = function(x) return x*x end -- x is table
    e = "attempt to perform arithmetic on a table value (local 'x')"
    if _VERSION == "Lua 5.1" or _VERSION == "Lua 5.2"  then
      e = "attempt to perform arithmetic on local 'x' (a table value)"
    end
    assert.has_error(function() tp.map({r1,r2},f1) end, e)
  end)
end)

describe("reduce(t,f[,init])", function()
  local function add(a,b) return a+b end
  local function concat(a,b) return a..b end
  it("should reduce tables", function()
    assert.equal(16,tp.reduce({1,2,3,a=10},add))
    assert.equal(6,tp.reduce({1,2,3},add))
    assert.equal(3,tp.reduce({1,2},add))
    assert.equal(1,tp.reduce({1},add))
    assert.equal(6,tp.reduce({a=1,b=2,c=3},add))
    assert.equal(3,tp.reduce({a=1,b=2},add))
    assert.equal(1,tp.reduce({c=1},add))
    assert.equal("123",tp.reduce({1,2,3},concat))
    assert.equal("abc",tp.reduce({"a","b","c"},concat))
  end)
  it("should return nil", function()
    assert.equal(nil,tp.reduce({},add))
  end)
  it("should reduce tables with init", function()
    assert.equal(16,tp.reduce({1,2,3},add,10))
    assert.equal(13,tp.reduce({1,2},add,10))
    assert.equal(11,tp.reduce({1},add,10))
    assert.equal(16,tp.reduce({a=1,b=2,c=3},add,10))
    assert.equal(13,tp.reduce({a=1,b=2},add,10))
    assert.equal(11,tp.reduce({c=1},add,10))
    assert.equal("0123",tp.reduce({1,2,3},concat,"0"))
    assert.equal("-abc",tp.reduce({"a","b","c"},concat,"-"))
  end)
  it("should return init with init", function()
    assert.equal(10,tp.reduce({},add,10))
  end)
end)

describe("filter(list,f)", function()
  local function odd(x) return x%2 == 1 end
  it("should filter lists", function()
    assert.are.same({1,3},tp.filter({1,2,3},odd))
    assert.are.same({1,3},tp.filter({1,2,3,a=10,b=11},odd))
    assert.are.same({1},tp.filter({1},odd))
    assert.are.same({},tp.filter({2},odd))
    assert.are.same({},tp.filter({},odd))
  end)
end)

describe("nonil(t[,limit])", function()
  it("should remove holes and hash part of table", function()
    assert.are.same({1,2,3},tp.nonil({nil,1,nil,nil,2,3,a=1,b=2}))
    assert.are.same(3,#tp.nonil({nil,1,nil,nil,2,3,a=1,b=2}))
    assert.are.same({1,2,3},tp.nonil({nil,1,nil,nil,2,3,[7.1]="?",a=1,b=2}))
    assert.are.same({199},tp.nonil({[199]=199}))
    assert.are.same({false,true,false},tp.nonil({nil,false,true,nil,false}))
    assert.are.same({},tp.nonil({}))
  end)
  it("should respect optional limit", function()
    assert.are.same({1,2},tp.nonil({nil,1,nil,nil,2,3,a=1,b=2},2))
    assert.are.same(2,#tp.nonil({nil,1,nil,nil,2,3,a=1,b=2},2))
    assert.are.same({1,2,3},tp.nonil({nil,1,nil,nil,2,3,[7.1]="?",a=1,b=2},3))
    assert.are.same({199},tp.nonil({[199]=199},1))
    assert.are.same({},tp.nonil({},100))
  end)
end)

describe("lambda(s)", function()
  it("should return function", function()
    local f = function(x) return x*x end
    local fl = tp.lambda "x: x*x"
    assert.equal(f(0),fl(0))
    assert.equal(f(1),fl(1))
    assert.equal(f(10),fl(10))

    f = function(a,b) return a+b end
    fl = tp.lambda "a, b : a  + b"
    assert.equal(f(0,1),fl(0,1))
    assert.equal(f(1,11),fl(1,11))
  end)
  it("should return same function for same string", function()
    local fl = tp.lambda "x: x*x/2"
    local fl2 = tp.lambda "x: x*x/2"
    assert.equal(fl,fl2)
  end)
  it("should report error", function()
    -- colon is used to separate arguments from expression
    assert.has_error(function() tp.lambda "x -> x*2" end,
                     "bad string lambda")
    -- invalid syntax by lua compiler
    local e = [[[string "return function(x ) return  x'x end"]:1: unfinished string near <eof>]]
    if _VERSION == "Lua 5.1" then
      e = [[[string "return function(x ) return  x'x end"]:1: unfinished string near '<eof>']]
    end
    assert.has_error(function() tp.lambda "x : x'x" end,e)
  end)
end)

-- make sure all examples render as expected

local examples = {"column", "header", "footer", "filter", "sort",
                  "format", "value",  "width",  "align", "valign",
                  "wrap",   "frame",  "rowseparator"}

local function render(fn)
  local buf = {}
  function _G.print(...)
    for i = 1, select("#", ...) do
      if i > 1 then buf[#buf+1] = "\t" end
      buf[#buf+1] = tostring(select(i,...))
    end
    buf[#buf+1] = "\n"
  end
  dofile(fn)
  return table.concat(buf)
end

local function readfile(path)
  local file = assert(io.open(path, "rb"))
  local content = file:read "*a"
  file:close()
  return content
end

for _, test in ipairs(examples) do
  describe("example", function()
    it(test..".lua should render correctly", function()
      local stat, res = pcall(render, "examples/"..test..".lua")
      assert(stat,res)
      if stat then
        local exp = readfile("spec/"..test..".expected")
        assert.same(exp,res)
      end
    end)
  end)
end

-- test color functionality
describe("example", function()

  -- require eansi if available
  local eansi
  isok, eansi = pcall(require,"eansi")
  if isok then
    eansi = require "eansi"
    eansi.enable = true
  else
    eansi = {enable=false}
  end

  if eansi.enable then
    it("color.lua should render colors", function()
      local stat, res = pcall(render, "examples/color.lua")
      assert(stat,res)
      if stat then
        tp{{dummy=""}} -- update shims for utf8 and eansi
        local exp = readfile("spec/color-yes.expected")
        assert.same(exp,res)
      end
    end)
  else
    it("color.lua no colors available", function()
      local stat, res = pcall(render, "examples/color.lua")
      assert(stat,res)
      if stat then
        local exp = readfile("spec/color-no.expected")
        assert.same(exp,res)
      end
    end)
  end
end)
