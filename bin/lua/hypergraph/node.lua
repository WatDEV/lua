
--[===========================================================================[
	Copyright (C) Peter Kapec - All Rights Reserved.
	Unauthorized copying, via any medium, or unauthorized usage of this code,
	or any part of it, is strictly prohibited.
	Written by Peter Kapec <kapecp@gmail.com>
--]===========================================================================]

pNode =
{
	--^	My stuff.
		_type='Node',
	--v
}

local n = 0
local function inc()
	n = n + 1
	return n
end

function N(label)
	local o = {label=label}
	setmetatable(o,
		{
			__index = pNode,
			__tostring = function(t)
				if t.label then return t.id..":"..t.label end
			end
		}
	)

	o.id = "N"..inc()

	return o
end




