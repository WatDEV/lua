
--[===========================================================================[
	Copyright (C) Peter Kapec - All Rights Reserved.
	Unauthorized copying, via any medium, or unauthorized usage of this code,
	or any part of it, is strictly prohibited.
	Written by Peter Kapec <kapecp@gmail.com>
--]===========================================================================]

pEdge =
{
	--^	My stuff.
		_type='Edge',
	--v
}

local n = 0
local function inc()
	n = n + 1
	return n
end

function E(label)
	local o = {label=label}
	setmetatable(o,
		{
			__index = pEdge,
			__tostring = function(t)
				if t.label then return t.id..":"..t.label end
			end
		}
	)

	o.id = "E"..inc()

	return o
end
