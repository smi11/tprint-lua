local tprint = require "tprint"

local list = {
  {item = "socks",    price=10,  qty=5,  discount=0,   note="nice and warm"},
  {item = "gloves",   price=55,  qty=25, discount=0,   note="made of wool"},
  {item = "cardigan", price=255, qty=11, discount=0.1, note="a bit pricey"},
  {item = "hat",      price=44,  qty=33, discount=0.2, note="old fashioned"},
  {item = "shoes",    price=155, qty=4,  discount=0,   note="for running"},
}

-- more control
local out = tprint.new(list)
io.stdout:write(tostring(out), "\n")

-- or simpler
--print(tprint(list))
