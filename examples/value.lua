-- luacheck: ignore 212  unused argument

local tp = require "tprint"

local list = {
  {item = "socks",    price=10,  qty=5,  discount=0.5, note="nice and warm"},
  {item = "gloves",   price=55,  qty=25, discount=nil, note="made of wool"},
  {item = "cardigan", price=255, qty=11, discount=0.1, note="a bit pricey"},
  {item = "hat",      price=44,  qty=33, discount=0.2, note="old fashioned"},
  {item = "shoes",    price=155, qty=4,  discount=nil, note="for running"},
  {item = "keyring",  price=1,   qty=400,discount=1,   note="a gift"},
}

-- value is a function applied to columns which allows us to either
-- modify values or calculate new ones

-- first argument is table of current row / current object (self)
-- second argument is column name
-- third argument is width, which is only present if we request callback

-- f(row,column[,width]) --> new value, callback function

-- by default value is disabled

print(tp(list,{column={"item","note","price","discount","qty","total"}}), "\n")

-- we can use value for example to set default values for missing data

-- set missing/nil discounts to 0

print(tp(list,{column={"item","note","price","discount","qty","total"},
               value={discount=function(row,col) return row[col] or 0 end}}), "\n")

-- let's calculate total
-- note that each calculation for each column needs to be done in full,
-- in other words you can't use calculations of other columns
-- as the order of evaluation is arbitrary
-- also we only get references to our original table (row, value)

print(tp(list,{column={"item","note","price","discount","qty","total"},
               format={total="%g"},
               value={discount=function(row,col) return row[col] or 0 end,
                      total=function(self,col)
                        local total = self.price * self.qty
                        return total - (self.discount or 0) * total
                      end}}), "\n")

-- let's add some formatting and footer

-- footer
local function sum(t)
  return tp.reduce(t,function(a,b) return a+b end)
end

-- format
local function percent(val)
  -- val may be nil or any type, so make sure you handle that here
  return val and string.format("%d %%", val * 100) or ""
end

print(tp(list,{column={"item","note","price","discount","qty","total"},
               value={discount=function(row,col) return row[col] or 0 end,
                      total=function(self,col)
                        local total = self.price * self.qty
                        return total - (self.discount or 0) * total
                      end},
               format={discount=percent, total="%.1f"},
               footer={qty=sum, total=sum},
             }), "\n")

-- use callback feature to calculate content according to column width
-- see also examples/width.lua

-- when our value function is called the column width is not known yet
-- however if we need column width, we can request callback after
-- column width is established

local function bar(row,col,width)
  -- width is always nil unless we request callback
  if not width then
    -- on the first call we return some dummy value wide enough
    -- to allow tprint to expand our column as wide as needed
    -- we request callback with second return value set to our function
    return string.rep("x",100), bar
  end
  -- on callback width is known, so we can return actuall content
  -- adjusted to column width
  return string.rep("X",math.floor(width*(row.discount or 0)))
end

print(tp(list,{column={"item","discount","bar"},
               value={bar=bar},
               totalWidth=80,  -- limit total width of table
             }), "\n")

print(tp(list,{column={"item","discount","bar"},
               value={bar=bar},
               format={discount=percent},
               totalWidth=40,  -- limit total width of table
             }), "\n")

local _, msg, err

-- example of invalid setting
-- should be table

function err()
  print(tp(list,{column={"item","note","price","discount","qty","total"},
                 value="not a table"}), "\n")
end

_, msg = pcall(err)
print(msg)

-- example of invalid setting
-- should be function

function err()
  print(tp(list,{column={"item","note","price","discount","qty","total"},
                 value={total=false}}), "\n")
end

_, msg = pcall(err)
print(msg)
