local tp = require "tprint"

local list = {
  {item = "socks",    price=10,  qty=5,  discount=0, note="nice and warm"},
  {item = "gloves",   price=55,  qty=25, discount=0.4, note="made of wool"},
  {item = "cardigan", price=255, qty=11, discount=0.1, note="a bit pricey"},
  {item = "hat",      price=44,  qty=33, discount=0.2, note="old fashioned"},
  {item = "shoes",    price=155, qty=4,  discount=0, note="for running"},
}

-- with option "header" we provide titles as strings for columns
-- header can be boolean, function or table of strings/functions

-- by default header is enabled and is the same list as column names

print(tp(list,{column={"item","note","price","discount","qty","item"}}), "\n")

-- which is the same as setting header to true

print(tp(list,{column={"item","note","price","discount","qty","item"},
               header=true}), "\n")

-- to disable header set it to false

print(tp(list,{column={"item","note","price","discount","qty","item"},
               header=false}), "\n")

-- we can apply a function to all columns
-- function should accept string as an argument and return string
-- f(s) -> string

print(tp(list,{column={"item","note","price","discount","qty","item"},
               header=string.upper}), "\n")

-- we can change title of individual columns by their index

print(tp(list,{column={"item","note","price","discount","qty","item"},
               header={[2]="BIG NOTE", [6]="item again"}}), "\n")

-- if we don't specify all columns
-- the ones we don't specify will remain same value as column name

print(tp(list,{column={"item","note","price","discount","qty","item"},
               header={"A","B",[6]="F"}}), "\n")

-- or we can assign titles by column key name
-- notice that assignment by key applies to all instances of that key
-- both column index 1 and 6 is assigned

print(tp(list,{column={"item","note","price","discount","qty","item"},
               header={item="**ITEM**"}}), "\n")

-- or we can combine strings and functions
-- index has always precedence over key name

print(tp(list,{column={"item","note","price","discount","qty","item"},
               header={[6]="**item**",item=string.upper}}), "\n")

-- we can also control headerSeparator line
-- by default if header is enabled so is headerSeparator line
-- we can remove it by setting it to false

print(tp(list,{column={"item","note","price","discount","qty","item"},
               header=string.upper,
               headerSeparator=false}), "\n")

-- or if header is disabled, we can still show separator line

print(tp(list,{column={"item","note","price","discount","qty","item"},
               header=false,
               headerSeparator=true}), "\n")

local _, msg, err

-- example of invalid setting

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 header="wrong"}), "\n")
end

_, msg = pcall(err)
print(msg)

-- example of invalid setting

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 header={[2]=false}}), "\n")
end

_, msg = pcall(err)
print(msg)

