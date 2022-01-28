local tp = require "tprint"

local list = {
  {item = "socks",    price=10,  qty=5,  discount=0, note="nice and warm"},
  {item = "gloves",   price=55,  qty=25, discount=0.4, note="made of wool"},
  {item = "cardigan", price=255, qty=11, discount=0.1, note="a bit pricey"},
  {item = "hat",      price=44,  qty=33, discount=0.2, note="old fashioned"},
  {item = "shoes",    price=155, qty=4,  discount=0, note="for running"},
}

-- with option "frame" we can select pre-built frames or provide our own

-- default frame is tp.FRAME_COMPACT

print(tp(list,{column={"item","note","price","discount","qty","value"}}), "\n")

-----------------------------------------------------------------------

-- tp.FRAME_SINGLE

print(tp(list,{column={"item","note","price","discount","qty","value"},
               frame=tp.FRAME_SINGLE}), "\n")

-----------------------------------------------------------------------

-- tp.FRAME_DOUBLE

print(tp(list,{column={"item","note","price","discount","qty","value"},
               frame=tp.FRAME_DOUBLE}), "\n")

-----------------------------------------------------------------------

-- tp.FRAME_ASCII

print(tp(list,{column={"item","note","price","discount","qty","value"},
               frame=tp.FRAME_ASCII}), "\n")

-----------------------------------------------------------------------

-- custom frame is a list/array of 17 strings

-- l=left border, p=column padding, c=column separator, r=right border
--                     l  p    c     r
local FRAME_CUSTOM = {"","─","─┬─","─┬┐", -- top line
                      "","·"," │ "," ││", -- thead, tfoot, row content
                      "","─","─┼─","─┼┤", -- thead & tfoot separator line
                      "","", "",   "",    -- bottom line
                      "…"}                -- trim/cut character

-- column p is padding character and must be exactly 1 character or empty ""
-- this applies to indexes 2, 6, 10 and 14
-- index 6 is padding character for cell content
-- index 17 is character indicating cell has been trimmed or cut
-- all characters can be ASCII or UTF-8 encoded

-- l, c and r can be wider, but keep all within same column same length
-- to avoid your table being distorted

-- in this example we removed left border by setting all l's to ""
-- we also removed bottom line by setting its l, p, c and r to ""
-- we made column separators wider "─┬─", " │ ", "─┼─"
-- we made right border wider and double "─┬┐", " ││", "─┼┤"
-- we set padding character for cells/content to small dot "·"

print(tp(list,{column={"item","note","price","discount","qty","value"},
               frame=FRAME_CUSTOM}), "\n")

-----------------------------------------------------------------------

-- use existing frame as a template for our new custom modified frame

-- make a copy first, so we don't corrupt original
local FRAME_COPY = tp.clone(tp.FRAME_COMPACT)

-- modify cell padding character
FRAME_COPY[6] = "·"

print(tp(list,{column={"item","note","price","discount","qty","value"},
               frame=FRAME_COPY}), "\n")

local _, msg, err

-- example of invalid setting, frame must be table containing 17 strings

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 frame="not table"}), "\n")
end

_, msg = pcall(err)
print(msg)

-- example of invalid setting, all elements must be strings

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 frame={"","","","","","1","","","","","",false,"","","","",""}}), "\n")
end

_, msg = pcall(err)
print(msg)

-- example of invalid setting
-- padding characters (index 2, 10 and 14) must be 0 or 1 characters

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 frame={"","čšž","","","","1","","","","","","","","","","",""}}), "\n")
end

_, msg = pcall(err)
print(msg)

-- example of invalid setting
-- padding character (index 6) must be exactly 1 character

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 frame={"","","","","","","","","","","","","","","","",""}}), "\n")
end

_, msg = pcall(err)
print(msg)

-- example of invalid setting
-- only 1 color tag or ansi escape sequence followed by a string allowed for all indexes

function err()
  print(tp(list,{column={"item","note","price","discount","qty"},
                 frame={"${bold}${red}","","","","","1","","","","","","","","","","",""}}), "\n")
end

_, msg = pcall(err)
print(msg)
