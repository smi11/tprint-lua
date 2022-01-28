local tp = require "tprint"

local list = {
  {item = "socks",    price=10,  qty=5,  discount=0.4, note="nice and warm"},
  {item = "gloves",   price=55,  qty=25, discount=nil, note="made of wool"},
  {item = "cardigan", price=255, qty=11, discount=0.1, note="a bit pricey"},
  {item = "hat",      price=44,  qty=33, discount=0.2, note="old fashioned"},
  {item = "shoes",    price=155, qty=4,  discount=nil, note="for running"},
}

-- with option "footer" we set table's footer
-- footer can be a function that returns a string
-- or a table of strings/functions for individual columns

-- by default footer is disabled

print(tp(list,{column={"item","note","price","discount","qty","item"}}), "\n")

-- unlike header, only footer for those columns that we specify are shown
-- we can output either strings or function results

print(tp(list,{column={"item","note","price","discount","qty","item"},
               footer={price="Avarage?", qty="Sum?"}}), "\n")

-- we can actually calculate sums, averages or other data as we wish
-- function receives a table of all values of that column
-- as an argument and should return some value
-- f(table) -> value

local function sum(t)
  return tp.reduce(t,function(a,b) return a+b end)
end

local function avg(t)
  return sum(t)/#t
end

print(tp(list,{column={"item","note","price","discount","qty","item"},
               footer={price=avg, qty=sum}}), "\n")

-- be careful if some values in your table are missing
-- notice we don't have all values for discount
-- function reduce uses pairs iterator and will work correctly
-- however the table we receive is not a proper array/list and therefore
-- the length operator #t of that array is wrong
-- our sum function will work correctly, but avg will not since it needs #t

print(tp(list,{column={"item","note","price","discount","discount","qty","item"},
               footer={price=avg, qty=sum, [4]=sum, [5]=avg}}), "\n")

-- lets fix our avg function by removing nils

local function avg2(t)
  t = tp.nonil(t)
  return sum(t)/#t  -- t is now proper array/list and #t is also correct
end

print(tp(list,{column={"item","note","price","discount","discount","qty","item"},
               footer={price=avg, qty=sum, [4]=sum, [5]=avg2}}), "\n")

-- we can also assign same function for all columns
-- however in that case we must verify data for
-- appropriate types before doing any arithmetic

local function vsum(t)
  -- more strict checks would be better
  if type(t[1])=="number" then
    return tp.reduce(t,function(a,b) return a+b end)
  end
  return "not numbers"
end

print(tp(list,{column={"item","note","price","discount","qty","item"},
               footer=vsum}), "\n")

-- by default if footer is enabled so is footerSeparator line
-- we can remove this line

print(tp(list,{column={"item","note","price","discount","qty","item"},
               footer={price=avg, qty=sum},
               footerSeparator=false}), "\n")

-- or if we don't have footer, we can still show footerSeparator line

print(tp(list,{column={"item","note","price","discount","qty","item"},
               footerSeparator=true}), "\n")

local _, msg, err

-- example of invalid setting, table expected

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 footer="wrong"}), "\n")
end

_, msg = pcall(err)
print(msg)

-- example of invalid setting, string or function expected

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 footer={[2]=false}}), "\n")
end

_, msg = pcall(err)
print(msg)

