local tp = require "tprint"

local list = {
  {item = "socks",    price=10,  qty=5,  discount=0, note="nice and warm"},
  {item = "gloves",   price=55,  qty=25, discount=0.4, note="made of wool"},
  {item = "cardigan", price=255, qty=11, discount=0.1, note="a bit pricey"},
  {item = "hat",      price=44,  qty=33, discount=0.2, note="old fashioned"},
  {item = "shoes",    price=155, qty=4,  discount=0, note="for running"},
}

-- with option "column" we specify which columns to print/output
-- it is the only option that we probably need to provide
-- as the default might not be what we want

-- by default columns are grabbed from data and sorted alphabetically

print(tp(list), "\n")

-- manually specified columns
-- we provide a table containing a list of strings representing column names
-- columns will be output in the same order we listed them here

print(tp(list,{column={"item","note","price","discount","qty"}}), "\n")

-- added additional column "value" that doesn't exist in our data table
-- with option "value" we can provide values for such columns
-- see: examples/value.lua

print(tp(list,{column={"item","note","price","discount","qty","value"}}), "\n")

-- we can specify same column(s) many times

print(tp(list,{column={"item","note","price","discount","qty","value","item","note"}}), "\n")

local _, msg, err

-- example of invalid setting

function err()
  print(tp(list,{column=false}), "\n")
end

_, msg = pcall(err)
print(msg)

-- example of invalid setting

function err()
  print(tp(list,{column={}}), "\n")
end

_, msg = pcall(err)
print(msg)

