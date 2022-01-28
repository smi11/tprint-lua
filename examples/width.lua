local tp = require "tprint"

local list = {
  {item = "socks",    price=10,  qty=5,  discount=0.4, note="nice and warm"},
  {item = "gloves",   price=55,  qty=25, discount=nil, note="made of wool"},
  {item = "cardigan", price=255, qty=11, discount=0.1, note="a bit pricey"},
  {item = "hat",      price=44,  qty=33, discount=0.2, note="old fashioned"},
  {item = "shoes",    price=155, qty=4,  discount=nil, note="for running"},
  {item = "keyring",  price=1,   qty=400,discount=1,   note="a gift"},
}

-- with option "width" we control width of individual columns (table)
-- we can use option "widthDefault" to assign default value for all columns (string or number)
-- with option "totalWidth" we set desired total width of entire table (number)

-- columns of width and widthDefault can be either:
-- "auto" - column width will be auto adjusted and may be cut if not enough space
-- "data" - column width is set to fixed value of its widest element
-- number - column width is set to specified number

-- totalWidth is number representing width of entire table
-- note that if setting totalWidth too low so that table can't fit
-- it will auto adjust to minimum possible width

-- if all columns are set to either "data" or number then the table can't
-- be adjusted to fit totalWidth, therefore we need at least one or more
-- columns set to "auto" to allow width adjustment

-- by default widthDefault is "auto"
-- totalWidth by default is set to math.huge

print(tp(list,{column={"item","note","price","discount","qty"}}), "\n")

-- if we now limit total width of table, all columns will adjust their
-- width accordingly to fit desired totalWidth if possible
-- it may be good idea to set totalWidth to the width of your terminal
-- to prevent lines wrapping for wide tables

print(tp(list,{column={"item","note","price","discount","qty"},
               totalWidth=30}), "\n")

-- if we set totalWidth too low it will auto adjust to minimum possible
-- value, but our output will be probably unusable

print(tp(list,{column={"item","note","price","discount","qty"},
               totalWidth=5}), "\n")

-- we can set numerical columns to fixed width so only text columns
-- adjust their width
-- we can use either column names or index to address desired columns

print(tp(list,{column={"item","note","price","discount","qty"},
               width={price=4, discount=4, [5]=4},
               totalWidth=25}), "\n")

-- set all columns to be as wide as their widest element
-- except column note which should auto adjust its width
-- to achieve totalWidth of 35

print(tp(list,{column={"item","note","price","discount","qty"},
               widthDefault="data",
               width={note="auto"},
               totalWidth=35}), "\n")

-- set all columns to be 10 characters wide

print(tp(list,{column={"item","note","price","discount","qty"},
               widthDefault=10}), "\n")

-- you can access all calculated column widths after calling constructor

local x = tp(list,{column={"item","note","price","discount","qty"},
                   frame=tp.FRAME_SINGLE})

tp.each(x.width,print) -- for each column print column index and its width
print(x.totalWidth)    -- print totalWidth of entire table
print(x)               -- print table

local _, msg, err

-- example of invalid setting
-- should be string "auto" or "data" or number >= 1

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 widthDefault=false}), "\n")
end

_, msg = pcall(err)
print(msg)

-- example of invalid setting
-- should be string "auto" or "data" or number >= 1

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 widthDefault=-10}), "\n")
end

_, msg = pcall(err)
print(msg)

-- example of invalid setting
-- should be string "auto" or "data" or number >= 1

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 widthDefault="wrong"}), "\n")
end

_, msg = pcall(err)
print(msg)

-- example of invalid setting
-- should be table

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 width=23.5}), "\n")
end

_, msg = pcall(err)
print(msg)

-- example of invalid setting
-- column should be string "auto" or "data" or number >= 1

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 width={note=0}}), "\n")
end

_, msg = pcall(err)
print(msg)

-- example of invalid setting
-- column should be string "auto" or "data" or number >= 1

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 width={price="wrong"}}), "\n")
end

_, msg = pcall(err)
print(msg)

-- example of invalid setting
-- should be number >= 1

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 totalWidth=0}), "\n")
end

_, msg = pcall(err)
print(msg)
