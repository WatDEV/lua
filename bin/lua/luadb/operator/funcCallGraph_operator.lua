------------------------------------------------------------------------------------------------------
local utils                 = require "luadb.utils"

------------------------------------------------------------------------------------------------------
------------------------- Modificators
local setEdgeColor =
{
	what = "EDGE",

	func = function(edge)
		return edge
	end,

	action = function(edge)
		colorTable = {
		['calls']           = {A = 1, R = 0.8, G = 0.8, B = 1},
		['assigns']         = {A = 1, R = 0.8, G = 1, B = 0.8},
		['contains']        = {A = 1, R = 0.8, G = 1, B = 0.8},
		['requires']        = {A = 1, R = 1, G = 0.8, B = 1},
		['implements']      = {A = 1, R = 1, G = 0.8, B = 1},
		['provides']        = {A = 1, R = 1, G = 0.8, B = 1},
		['initializes']     = {A = 1, R = 1, G = 0.8, B = 1},
		['declares']        = {A = 1, R = 1, G = 0.8, B = 1},
		['represents']      = {A = 1, R = 1, G = 0.8, B = 1},
		['has']             = {A = 1, R = 1, G = 0.8, B = 1}
	  }

		local edgeType = edge.label
		if(colorTable[edgeType]) then
			return { color = colorTable[edgeType] }
		else
			return { color = {A = 1, R = 1, G = 1, B = 1} }
		end
	end
}

local setNodeColor =
{
	what = "NODE",

	func = function(node)
		return node
	end,

	action = function(node)
		colorTable = {
		['project']         = {A = 1, R = 1, G = 1, B = 0},
		['directory']       = {A = 1, R = 1, G = 1, B = 0},
		['file']            = {A = 1, R = 1, G = 0, B = 1},
		['module']          = {A = 1, R = 1, G = 0, B = 1},
		['global function'] = {A = 1, R = 0, G = 0, B = 1},
		['local variable']  = {A = 1, R = 0, G = 1, B = 0},
		['global variable'] = {A = 1, R = 0, G = 1, B = 0},
		['interface']       = {A = 1, R = 0, G = 0, B = 0},
		['argument']        = {A = 1, R = 0, G = 1, B = 1},
		['method']          = {A = 1, R = 0, G = 1, B = 0},
		['class']           = {A = 1, R = 1, G = 0, B = 0}
	  }

		local nodeType = node.meta.type
		if(colorTable[nodeType]) then
			return { color = colorTable[nodeType] }
		else
			return { color = {A = 1, R = 1, G = 1, B = 1} }
		end
	end
}

local filterEdges =
{
	what = "EDGE",

	func = function(edge)
		if edge.label == "implements" or edge.label == "contains" or edge.label == "calls" then
			return edge
		end
	end,

	action = function(edge)
		return {}
	end
}

-- Public interface of module
return {
  setEdgeColor = setEdgeColor,
  setNodeColor = setNodeColor,
  filterEdges = filterEdges
}
