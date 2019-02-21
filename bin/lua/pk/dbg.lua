--| pk.dbg module

module("pk.dbg", package.seeall)

--%	The Serialize function.
---	serializes a lua variable (good for table visualization).
--@	o	(any)		Variable to Serialize
--@	d	(number)	INTERNAL (RECURSIVE FUNCTION)
function Serialize(o, d)
  if not d then d = 0 end

  if type(o) == "number" then
    io.write(o)
  elseif type(o) == "string" then
    io.write(string.format("%q", o))
  elseif type(o) == "boolean" then
    if(o) then io.write("true") else io.write("false") end
  elseif type(o) == "table" then
    io.write("{\n")
    for k,v in next, o do
	  for f = 1,d do
        io.write("  ")
      end
	  if type(k) == "string" and not string.find(k, "[^%w_]") then
        io.write("  ", k, " = ")
      else
	    io.write("  [")
        Serialize(k)
        io.write("] = ")
      end

      Serialize(v, d + 1)
      if type(v) ~= "table" then io.write("\n") end
    end

    for f = 1,d do
      io.write("  ")
    end

    io.write("}\n")
  elseif type(o) == "function" then
    io.write(tostring(o))
  elseif type(o) == "userdata" then
    io.write(tostring(o))
  else
    error("cannot Serialize a "..type(o));
  end
end

--%	The Save function.
---	serializes a cyclic table.
--@	name	(string)	name of the table
--@	value	(table)		table to Serialize
--@	saved	()
function Save (name, value, saved)
	saved = saved or {}       -- initial value
	local function basicserialize (o)
		if type(o) == "number" then
			return tostring(o)
		elseif type(o) == "table" then
			return "'"..tostring(o).."'"
		elseif type(o) == "function" then
			return tostring(o)
		elseif o == nil then
			return "nil"
		else   -- assume it is a string
			return string.format("%q", o)
		end
	end

	io.write(name, " = ")
	if type(value) == "number" or type(value) == "string" then
		io.write(basicserialize(value), "\n")
	elseif type(value) == "boolean" then
		if(value) then io.write("true\n") else io.write("false\n") end
	elseif type(value) == "table" then
		if saved[value] then    -- value already saved?
		  io.write(saved[value], "\n")  -- use its previous name
		else
		  saved[value] = name   -- Save name for next time
		  io.write("{}\n")     -- create a new table
		  for k,v in pairs(value) do      -- Save its fields
			local fieldname = string.format("%s[%s]", name, basicserialize(k))
			--print(fieldname,"aaa")
		    Save(fieldname, v, saved)
			--vypisanie aj indexovych objektov 
			Save(fieldname, k, saved)
			
		  end
		end
	elseif type(value) == "function" then
		io.write(tostring(value), "\n")
	elseif value	 == nil then
		return "nil"
	else
		error("cannot save a " .. type(value))
	end
end

--%	The serialize_with_meta function.
---	serializes a table and table's metatable.
--@	name	(string)	name of the table to display
--@	t	(table)		table to Serialize
function SerializeMetatable(name,t)
	print(name..'=') Serialize(t)
	if getmetatable(t) then
		SerializeMetatable("meta "..name..'=',getmetatable(t))
	end
end

--%	The save_with_meta function.
---	serializes a table and table's metatable.
--@	name	(string)	name of the table to display
--@	t	(table)		table to Serialize
function SaveMetatable(name,t)
	Save(name, t)
	if getmetatable(t) then
		SaveMetatable("meta "..name,getmetatable(t))
	end
end



--%	The SerializeTable function.
---	Display key=value pair of a table.
--@	t	(table)
function SerializeTable(t)
	for k,v in next, t  do
		print(k,v)
		
	end
end
