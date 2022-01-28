local tp = require "tprint"

local list = {
  {item = "socks",    price=10,  qty=5,  discount=0, note="nice and warm"},
  {item = "hat",      price=44,  qty=33, discount=0.2, note="old fashioned"},
  {item = "hat",      price=60,  qty=20, discount=0.1, note="stylish"},
  {item = "gloves",   price=55,  qty=25, discount=0.4, note="made of wool"},
  {item = "cardigan", price=255, qty=11, discount=0.1, note="a bit pricey"},
  {item = "HAT",      price=40,  qty=25, discount=0.2, note="modern"},
  {item = "Shoes",    price=155, qty=4,  discount=0, note="for running"},
  {item = "hat",      price=10,  qty=50, discount=0, note="cheap"},
}

-- with option "sort" we specify how our data should be sorted

-- by default table is not sorted
-- rows maintain its natural order of their integer index

print(tp(list,{column={"item","note","price","discount","qty"}}), "\n")

-- note that sort can only be applied to columns that contain either strings or numbers,
-- unless you also provide a compare function

-- we can specify a single column to sort by
-- this assumes ascending order on column price

print(tp(list,{column={"item","note","price","discount","qty"},
               sort="price"}), "\n")

-- however, we get more control by specifying columns by their key name
-- by adding suffix "<" or ">" to column name we can assign order
-- < ascending
-- > descending
-- if suffix is not provided then ascending order is assumed

-- descending for column "price"

print(tp(list,{column={"item","note","price","discount","qty"},
               sort="price>"}), "\n")

-- we can provide table to sort by multiple columns
-- first sort ascending by column "item", then descending by "price"

print(tp(list,{column={"item","note","price","discount","qty"},
               sort={"item<", "price>"}}), "\n")

-- by adding prefix "_" to column name,
-- we can specify to ignore string lower and upper case

print(tp(list,{column={"item","note","price","discount","qty"},
               sort={"_item<", "price>"}}), "\n")

-- you can also specify custom compare function f
-- f(a,b) --> boolean
-- a,b are values of any type, so make sure to compare only compatible types
-- function should return true if a should come before b and false otherwise

print(tp(list,{column={"item","note","price","discount","qty"},
               sortCmp = function(a,b) return a < b end,
               sort={"_item<", "price>"}}), "\n")

local _, msg, err

-- example of invalid setting

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 sort=false}), "\n")
end

_, msg = pcall(err)
print(msg)

-- example of invalid setting
-- only columns that are actually in data table are allowed
-- sorting calculated columns is not supported

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 sort="missing"}), "\n")
end

_, msg = pcall(err)
print(msg)

