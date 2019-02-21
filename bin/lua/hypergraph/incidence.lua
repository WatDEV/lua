
--[===========================================================================[
	Copyright (C) Peter Kapec - All Rights Reserved.
	Unauthorized copying, via any medium, or unauthorized usage of this code,
	or any part of it, is strictly prohibited.
	Written by Peter Kapec <kapecp@gmail.com>
--]===========================================================================]

pIncidence =
{
	--^	My stuff.
		_type='Incidence',
	--v
}

local n = 0
local function inc()
	n = n + 1
	return n
end

function I(label)
	local o = {label=label}
	setmetatable(o,
		{
			__index = pIncidence,
			__tostring = function(t)
			 	if t.label then return t.id..":"..t.label end
			end
		}
	)

	o.id = "I"..inc()

	return o
end
