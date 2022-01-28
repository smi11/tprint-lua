local tp = require "tprint"

-- for colors to work you need "eansi" module
-- if needed install it with:
--
--    luarocks install eansi
--
-- or download it from https://github.com/smi11/eansi-lua

-- luacheck: ignore 311 331
local isok, eansi = pcall(require, "eansi")
if isok then
  eansi = require "eansi"
else
  eansi = {}
end

-- on windows eansi is disabled by default, so make sure it's on
eansi.enable = true

local list = {
  {item = "socks",    price=10,  qty=5,  discount=0, note="nice and warm"},
  {item = "gloves",   price=55,  qty=25, discount=0.4, note="made of wool"},
  {item = "cardigan", price=255, qty=11, discount=0.1, note="a bit pricey"},
  {item = "hat",      price=44,  qty=33, discount=0.2, note="old fashioned hat with long description"},
  {item = "shoes",    price=155, qty=4,  discount=0, note="for running"},
}

-- we can set "frameColor", "headerColor", "footerColor", "valueColor",
-- "oddColor" and "evenColor"

-- by default all colors are disabled

print(tp(list,{column={"item","note","price","discount","qty"},
               frame=tp.FRAME_SINGLE}), "\n")

-- set frameColor

print(tp(list,{column={"item","note","price","discount","qty"},
               frame=tp.FRAME_SINGLE,
               totalWidth=50,
               wrap=true,
               frameColor="red on green"}), "\n")

-- set headerColor and footerColor

local function sum(t)
  return tp.reduce(t,function(a,b) return a+b end)
end

print(tp(list,{column={"item","note","price","discount","qty"},
               frame=tp.FRAME_SINGLE,
               footer={price=sum,discount=sum,qty=sum},
               totalWidth=50,
               wrap=true,
               headerColor="bold bright cyan",
               footerColor="bright white on red"}), "\n")

-- set valueColor

print(tp(list,{column={"item","note","price","discount","qty"},
               frame=tp.FRAME_SINGLE,
               footer={price=sum,discount=sum,qty=sum},
               totalWidth=50,
               wrap=true,
               headerColor="bold bright yellow",
               valueColor="bright cyan"}), "\n")

-- set oddColor and/or evenColor
-- this works best if we only apply background colors
-- or we'll have to set frameColor as well

print(tp(list,{column={"item","note","price","discount","qty"},
               frame=tp.FRAME_SINGLE,
               footer={price=sum,discount=sum,qty=sum},
               totalWidth=50,
               wrap=true,
               headerColor="bold",
               evenColor="on grey7",
               oddColor="on green"}), "\n")

-- we can also insert color tags into "format" option or any other
-- option that returns string

local mynote="${red}N${green}O${cyan}T${yellow}E"

print(tp(list,{column={"item","note","price","discount","qty"},
               header={note=mynote},
               frame=tp.FRAME_SINGLE,
               totalWidth=50,
               wrap=true,
               footer={price=sum,discount=sum,qty=sum},
               format={price="${bright yellow}%.1f"},
               headerColor="bold",
               evenColor="on grey7"}), "\n")

-- or insert custom color tags according to value

local function myprice(val)
  if val > 100 then
    return string.format("${green}%.1f", val)
  else
    return string.format("${italic bright white}%.1f", val)
  end
end

print(tp(list,{column={"item","note","price","discount","qty"},
               frame=tp.FRAME_SINGLE,
               totalWidth=50,
               wrap=true,
               footer={price=sum,discount=sum,qty=sum},
               format={price=myprice},
               headerColor="bold bright yellow",
               oddColor="on grey7"}), "\n")

-- if eansi is loaded but you wish to suppress color generation you can do
eansi.enable=false

print(tp(list,{column={"item","note","price","discount","qty"},
               frame=tp.FRAME_SINGLE,
               totalWidth=50,
               wrap=true,
               footer={price=sum,discount=sum,qty=sum},
               format={price=myprice},
               headerColor="bold bright yellow",
               oddColor="on grey7"}), "\n")
