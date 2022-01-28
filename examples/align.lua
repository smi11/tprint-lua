local tp = require "tprint"

local list = {
  {item = "socks",    price=10,  qty=5,  discount=0, note="nice and warm"},
  {item = "gloves",   price=55,  qty=25, discount=0.4, note="made of wool"},
  {item = "cardigan", price=255, qty=11, discount=0.1, note="a bit pricey"},
  {item = "hat",      price=44,  qty=33, discount=0.2, note="old fashioned"},
  {item = "shoes",    price=155, qty=4,  discount=0, note="for running"},
}

-- with option "align" we can specify how columns should be aligned
-- use string "left", "right" or "center"

-- by default numerical columns are aligned "right" and all others "left"

print(tp(list,{column={"item","note","price","discount","qty"}}), "\n")

-- set all columns to align "center"
-- setting align to string will replicate that value to all columns

print(tp(list,{column={"item","note","price","discount","qty"},
               align="center"}), "\n")

-- or set alignment for columns individually by providing table
-- we can address columns either by their column name or column index
-- the columns we don't specify will maintain their default alignment

print(tp(list,{column={"item","note","price","discount","qty"},
               align={note="right", [5]="left"}}), "\n")

-- you can verify alignment of all columns

local x = tp(list,{column={"item","note","price","discount","qty"},
                   align={note="center", [5]="left"}})

-- nonil is used to strip hash part of table align
tp.each(tp.nonil(x.align),print) -- print index and alignment of each column
print(x)                         -- print table

local _, msg, err

-- example of invalid setting

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 align=false}), "\n")
end

_, msg = pcall(err)
print(msg)

-- example of invalid setting

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 align="wrong"}), "\n")
end

_, msg = pcall(err)
print(msg)

-- example of invalid setting

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 align={[4]="wrong"}}), "\n")
end

_, msg = pcall(err)
print(msg)
