local tp = require "tprint"

local list = {
  {item = "socks",    price=10,  qty=5,  discount=0, note="nice and warm"},
  {item = "gloves",   price=55,  qty=25, discount=0.4, note="made of wool"},
  {item = "cardigan", price=255, qty=11, discount=0.1, note="a bit pricey"},
  {item = "hat",      price=44,  qty=33, discount=0.2, note="old fashioned"},
  {item = "shoes",    price=155, qty=4,  discount=0, note="for running"},
}

-- by default filter is turned off, all rows are shown

print(tp(list,{column={"item","note","price","discount","qty"}}), "\n")

-- function that we assign to filter is called for each row of list
-- its boolean return value determines if row is shown or not

-- f(item) --> boolean

-- show only rows where price is greater than 100

print(tp(list,{column={"item","note","price","discount","qty"},
               filter=function(x) return x.price > 100 end}), "\n")

-- show only rows with no discount

print(tp(list,{column={"item","note","price","discount","qty"},
               filter=function(x) return x.discount == 0 end}), "\n")

-- both combined

print(tp(list,{column={"item","note","price","discount","qty"},
               filter=function(x) return x.discount == 0 and x.price > 100 end}), "\n")

local _, msg, err

-- example of invalid setting

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 filter="wrong"}), "\n")
end

_, msg = pcall(err)
print(msg)

