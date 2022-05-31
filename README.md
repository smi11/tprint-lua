# tprint 0.3 Table Printer

[![License](https://img.shields.io/:license-mit-blue.svg)](https://mit-license.org) [![Build Status](https://travis-ci.com/smi11/tprint-lua.svg?branch=main)](https://app.travis-ci.com/smi11/tprint-lua.svg?branch=main) [![Coverage Status](https://coveralls.io/repos/github/smi11/tprint-lua/badge.svg)](https://coveralls.io/github/smi11/tprint-lua)

Easily print reports and various data from tables in tabular format on your terminal.

Supports settings for:

- which columns to print
- titles for column headers
- calculated or fixed footers
- setting how to format cells
- setting values for missing data or calculating new data
- filtering and sorting
- adjusting column alignment, width, format and color
- wrap long cells
- preset or custom frames
- and more...

With optional `eansi` module, you can colorize your output for ansi terminals. Basic output of UTF-8 characters is also supported out of the box. With optional `luautf8` you can even format output for asian languages.

Compatible with Lua 5.1+ and LuaJIT 2.0+

## Installation

### Using LuaRocks

Installing `tprint.lua` using [LuaRocks](https://www.luarocks.org/):

`$ luarocks install tprint`

### Without LuaRocks

Download file `tprint.lua` and put it into the directory for Lua libraries or your working directory.

## Quick start

```lua
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
print(tprint(list))

--[[ By default columns are grabbed from data and sorted alphabetically.
     However you can fully customize which columns to print and how to
     format them.

discount item     note          price qty
──────── ──────── ───────────── ───── ───
       0 socks    nice and warm    10   5
       0 gloves   made of wool     55  25
     0.1 cardigan a bit pricey    255  11
     0.2 hat      old fashioned    44  33
       0 shoes    for running     155   4
--]]
```

## API

In essence there is only one function that you need and that is constructor `tprint.new`. Since the constructor is bound to `__call` metamethod of the module, you can simply use it by module name only.

There are some additional functions you can use for either preparing your data or for formatting and/or calculating your output.

A quick overview:

|                Function                |                        Description                        |
|----------------------------------------|-----------------------------------------------------------|
| `tprint.cut(s,length[,indicator])`     | Cut string to specified length                            |
| `tprint.slice(s,length)`               | Slice string at specified length                          |
| `tprint.pad(s,length,justify,padchar)` | Pad string at length and justified (left,right or center) |
| `tprint.clone(t[,meta])`               | Deep copy table containing cycles and metatables          |
| `tprint.each(t,f[,...])`               | Execute `f(k,v,...)` on each table element                |
| `tprint.map(t,f[,...])`                | Map table with function `f(x,...)`, or extract columns    |
| `tprint.reduce(t,f[,init])`            | Reduce or accumulate items with function `f(acc, item)`   |
| `tprint.filter(list,f)`                | Filter list with function `f(x)`                          |
| `tprint.nonil(t[,limit])`              | Remove nil's and hash part of table                       |
| `tprint.lambda(s)`                     | Return function from string lambda                        |
| `tprint.utf8.charpattern`              | A string pattern describing one UTF-8 character           |
| `tprint.utf8.len(s)`                   | Same as utf8.len in Lua 5.3+ (no check of validity)       |
| `tprint.utf8.offset(s,n,i)`            | Same as utf8.offset in Lua 5.3+                           |
| `tprint.utf8.sub(s,i,j)`               | Same as string.sub but works with UTF-8 encoding          |
| `tprint.utf8.format(fmt,...)`          | Fixed string.format for correct length of `%s` option     |
|                                        |                                                           |

All UTF-8 functions work in all versions of Lua and LuaJIT. However for Asian languages and some emojis, where characters are longer than one column, you need proper UTF-8 library to get correct width of characters.

At the moment only `luautf8` is supported. If you need correct widths for Asian languages install:

    luarocks install luautf8

Then load it in your application:

```lua
local utf8 = require "lua-utf8"  -- with dash
local tprint = require "tprint"
```

`tprint` doesn't require any library for basic functionality, but it will recognize `luautf8` if loaded and use that for UTF-8 handling, and it will also recognize `eansi` if loaded and use that for colorizing your output.

### Constructor `tprint.new (list[, options]) --> object`

`list` is a list or array of records or objects containing your data that you wish to print. Each record represents one row of data.

`options` is a table where you customize your output.

Available options are:

|       Option      |                      Description                       |
|-------------------|--------------------------------------------------------|
| `column`          | A list of column names to print                        |
| `header`          | Titles for columns                                     |
| `headerSeparator` | Show header separator line                             |
| `footer`          | What to display for column footer                      |
| `footerSeparator` | Show footer separator line                             |
| `rowSeparator`    | Show separator line on selected rows                   |
| `filter`          | Function to filter data                                |
| `sort`            | Sort order for columns                                 |
| `sortCmp`         | Custom compare function for sort                       |
| `value`           | Modify cell data                                       |
| `format`          | How column cells and footer should be formatted        |
| `align`           | Column alignment ("left","center" or "right")          |
| `widthDefault`    | Default width ("auto", "data" or number)               |
| `width`           | Set column widths                                      |
| `totalWidth`      | Limit total width of entire table                      |
| `wrap`            | Split long cells to several lines                      |
| `valign`          | Vertical column alignment ("top","middle" or "bottom") |
| `frame`           | Select frame for table                                 |
| `frameColor`      | Set frame color                                        |
| `headerColor`     | Set header color                                       |
| `footerColor`     | Set footer color                                       |
| `valueColor`      | Set color for cell value/content                       |
| `oddColor`        | Set color for odd rows                                 |
| `evenColor`       | Set color for even rows                                |

Most options expect a table with a list of settings for each column you wish to set. The only setting that you probably need to set is option `column`. With it you specify a list of columns to print and their order.

For example to print columns `item`, `note` and `price` in that order we need to specify:

```lua
print(tprint(list, {column={"item", "note", "price"}}))
```

Once we declare which columns to print and in what order, all other options refer to that column list.

Next important setting is `header` for column titles. By default column titles are set to be same as column names. However we can change that.

For example lets change note's column title:

```lua
-- to change header for note we could say (using column index):
print(tprint(list, {column={"item", "note", "price"},
                    header={[2]="My note"}}))
--> "item", "My note", "price"

-- or (using column key/name):
print(tprint(list, {column={"item", "note", "price"},
                    header={note="My note"}}))
--> "item", "My note", "price"

-- in case we specify both index and key name for same column, the index will have precedence
print(tprint(list, {column={"item", "note", "price"},
                    header={[2]="My note (1)", note="My note (2)"}}))
--> "item", "My note (1)", "price"
```

All options follow this rule. See corresponding examples in folder `examples/` for detailed description and examples for each option, its defaults and its specifics.

Specifics of option `header`:

```lua
-- We can disable header by setting it to boolean false:
print(tprint(list, {column={"item", "note", "price"},
                    header=false}))
--> no header

-- Or we could apply some function to either all columns:
print(tprint(list, {column={"item", "note", "price"},
                    header=string.upper}))
--> "ITEM", "NOTE", "PRICE"

-- Or few or just one column by providing a table:
print(tprint(list, {column={"item", "note", "price"},
                    header={item=string.upper}}))
--> "ITEM", "note", "price"
```

See: `examples/*.lua`

## Tests

Running test specs is done using Olivine-Labs [busted](http://olivinelabs.com/busted/). You can install it using [LuaRocks](http://www.luarocks.org/):

```
$ luarocks install busted
$ cd /path/to/tprint/
$ busted
```

## Contributions

Improvements, suggestions and fixes are welcome.

## Changelog

### 0.3

- completely rewritten all code
- added asserts for all options
- new options wrap, valign, value
- added documentation README.md
- written examples for each option
- added busted tests
- first public release
- modified option value to accept f(row,col[,width])
- added option rowSeparator

### 0.2

- didn't track all the changes

### 0.1

- first draft

## License

The code is released under the MIT terms. Feel free to use it in both open and
closed software as you please.

MIT License
Copyright (c) 2020-2021 Milan Slunečko

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without imitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or other
dealings in this Software without prior written authorization.
