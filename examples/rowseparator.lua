local tp = require "tprint"

local list = {
  {item = "socks",    price=10,  qty=5,  discount=0, note="nice and warm"},
  {item = "gloves",   price=55,  qty=25, discount=0.4, note="made of wool"},
  {item = "cardigan", price=255, qty=11, discount=0.1, note="a bit pricey"},
  {item = "hat",      price=44,  qty=33, discount=0.2, note="old fashioned"},
  {item = "shoes",    price=155, qty=4,  discount=0, note="for running"},
}

-- add row separators on row 2 and 4
print(tp(list,{column={"item","note","price","discount","qty"},
               rowSeparator={2, 4},
               frame=tp.FRAME_ASCII}), "\n")

-- add row separator on first row
print(tp(list,{column={"item","note","price","discount","qty"},
               rowSeparator={1},
               frame=tp.FRAME_ASCII}), "\n")

-- add row separator after every 1 row
print(tp(list,{column={"item","note","price","discount","qty"},
               rowSeparator=1,
               frame=tp.FRAME_ASCII}), "\n")

-- add row separator after every 3 rows
print(tp(list,{column={"item","note","price","discount","qty"},
               rowSeparator=3,
               frame=tp.FRAME_ASCII}), "\n")

local _, msg, err

-- example of invalid setting

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 rowSeparator="wrong"}), "\n")
end

_, msg = pcall(err)
print(msg)


-- example of invalid setting

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 rowSeparator={1, "wrong", 5}}), "\n")
end

_, msg = pcall(err)
print(msg)
