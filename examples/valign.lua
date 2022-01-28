local tp = require "tprint"

local list = {
  {item = "socks",    price=10,  qty=5,  discount=0.4, note="nice and warm"},
  {item = "gloves",   price=55,  qty=25, discount=nil, note="made of wool"},
  {item = "cardigan", price=255, qty=11, discount=0.1, note="a bit pricey"},
  {item = "hat",      price=44,  qty=33, discount=0.2, note="this is long description for old fashioned hat"},
  {item = "shoes",    price=155, qty=4,  discount=nil, note="for running"},
  {item = "keyring",  price=1,   qty=400,discount=1,   note="this is a gift for our regular clients"},
}

-- valign is vertical alignment for wrapped lines
-- options are "top" (default), "middle" and "bottom"
-- we can set them for all columns at the same time
-- or to individual columns only by providing table

-- by default valign is set to top for all columns
-- also enable wrap for valign to have effect

print(tp(list,{column={"item","note","price","discount","qty"},
               wrap=true,
               totalWidth=50}), "\n")

-- set valign to "middle" for all columns but wrap only column note

print(tp(list,{column={"item","note","price","discount","qty"},
               valign="middle",
               wrap={note=true},
               totalWidth=50}), "\n")

-- set valign for each column separately
-- btw, it helps to separate rows with different background color
-- see: examples/colors.lua

print(tp(list,{column={"item","note","price","discount","qty"},
               valign={"middle", "top", "bottom", "middle"}, -- selected columns
               wrap={note=true}, -- only wrap note, other columns will be cut
               totalWidth=50}), "\n")

local _, msg, err

-- example of invalid setting
-- should be string or table

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 valign=false}), "\n")
end

_, msg = pcall(err)
print(msg)

-- example of invalid setting
-- should be "top" "middle" or "bottom"

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 wrap=true,
                 totalWidth=50,
                 valign="tight"}), "\n")
end

_, msg = pcall(err)
print(msg)

-- example of invalid setting
-- column 2 should be "top" "middle" or "bottom"

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 wrap=true,
                 totalWidth=50,
                 valign={note=false}}), "\n")
end

_, msg = pcall(err)
print(msg)
