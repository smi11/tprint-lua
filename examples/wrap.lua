local tp = require "tprint"

local list = {
  {item = "socks",    price=10,  qty=5,  discount=0.4, note="nice and warm"},
  {item = "gloves",   price=55,  qty=25, discount=nil, note="made of wool"},
  {item = "cardigan", price=255, qty=11, discount=0.1, note="a bit pricey"},
  {item = "hat's name that is very long", price=44, qty=33, discount=0.2,
   note="this is long description for old fashioned hat"},
  {item = "shoes",    price=155, qty=4,  discount=nil, note="for running"},
  {item = "keyring",  price=1,   qty=400,discount=1,   note="this is a gift for our regular clients"},
}

-- with option "wrap" we control wrapping of long columns
-- wrap is either boolean or our own function that handles wrapping
-- it can be set to all columns at the same time or individually by columns

-- by default wrap is set to false for all columns
-- that means if the column is too long it will be cut
-- notice character "…" that indicates our value was cut
-- cut indicator is frame index 17, see: examples/frame.lua

print(tp(list,{column={"item","note","price","discount","qty"},
               header={discount="dis."},
               totalWidth=50}), "\n")

-- this is exactly the same as above, we just set manually wrap
-- to function cut

print(tp(list,{column={"item","note","price","discount","qty"},
               header={discount="dis."},
               wrap=tp.cut,
               totalWidth=50}), "\n")

-- if we set wrap to true, long columns will wrap over several lines

print(tp(list,{column={"item","note","price","discount","qty"},
               header={discount="dis."},
               wrap=true,
               totalWidth=50}), "\n")

-- wrap is aware of color tags and/or ansi colors in your data and
-- if you loaded module lua-utf8 it will also handle correct widths of
-- characters
-- in other words it will work correctly even for asian languages
-- that have wider characters
-- but it works only on character level

-- if you want to wrap columns in a certain way, you can
-- provide custom function to do that
-- the function should either cut value at specified length or
-- split it to as many lines as needed

-- f(value,length,indicator) --> one string or table of strings
-- value - to be wrapped
-- length - maximum length of single line
-- indicator - cut indicator (frame index 17)

-- lets do simple wrap at word boundaries
-- you should probably use something more robust and handle appropriate
-- character encodings

local function wordwrap(str, length) --> table of strings
  str=tostring(str or "")
  local line, lines = "", {}
  for word in string.gmatch(str,'%S+') do -- iterate non-space characters
    if #word+#line+1 > length then
      lines[#lines+1] = line  -- add line shorter or equal than length
      line = word
    else
      line = line == "" and word or line .. " " .. word -- join words
    end
  end
  lines[#lines+1] = line -- add remaining line
  return lines -- return table of strings
end

-- column item wraps at character level
-- column note wraps at word boundary

print(tp(list,{column={"item","note","price","discount","qty"},
               header={discount="dis."},
               wrap={item=true, note=wordwrap},
               totalWidth=50}), "\n")

local _, msg, err

-- example of invalid setting
-- should be boolean or function

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 totalWidth=50,
                 wrap="not a boolean or function"}), "\n")
end

_, msg = pcall(err)
print(msg)

-- example of invalid setting
-- column should be boolean or function

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 totalWidth=50,
                 wrap={note="wrong"}}), "\n")
end

_, msg = pcall(err)
print(msg)
