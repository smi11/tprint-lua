local tp = require "tprint"

local list = {
  {item = "socks",    price=10,  qty=5,  discount=0.4, note="nice and warm"},
  {item = "gloves",   price=55,  qty=25, discount=nil, note="made of wool"},
  {item = "cardigan", price=255, qty=11, discount=0.1, note="a bit pricey"},
  {item = "hat",      price=44,  qty=33, discount=0.2, note="old fashioned"},
  {item = "shoes",    price=155, qty=4,  discount=nil, note="for running"},
  {item = "keyring",  price=1,   qty=400,discount=1,   note="a gift"},
}

-- with option "format" we specify how column values and footer should be formatted
-- format should be a table of string and/or functions
-- if string it shouldbe format specifier for string.format
-- if function, the function should return formatted string
-- f(value) --> string

-- by default format is not set for any column
-- so all columns just use function tostring(value)

print(tp(list,{column={"item","note","price","discount","qty"}}), "\n")

-- let's set format for price as float with 1 decimal place
-- and set format for discount as percentage

local function percent(val) --> string
  -- val may be nil or any type, so make sure you handle that here
  return val and string.format("%d %%", val * 100) or ""
end

print(tp(list,{column={"item","note","price","discount","qty"},
               format={price="%.1f", discount=percent}}), "\n")

-- format can be also used to set width and alignment for strings
-- however there are options width and align which offer more control
-- see: examples/width.lua and examples/align.lua

print(tp(list,{column={"item","note","price","discount","qty"},
               format={item="%-10s", note="%20s", price="%.1f", discount=percent}}), "\n")

local _, msg, err

-- example of invalid setting, table expected

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 format="%s"}), "\n")
end

_, msg = pcall(err)
print(msg)

-- example of invalid setting, column should be string or function

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 format={[2]=false}}), "\n")
end

_, msg = pcall(err)
print(msg)

-- example of invalid setting, column should be string or function

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 format={discount=math.pi}}), "\n")
end

_, msg = pcall(err)
print(msg)

