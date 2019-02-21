
--[===========================================================================[
	Copyright (C) Peter Kapec - All Rights Reserved.
	Unauthorized copying, via any medium, or unauthorized usage of this code,
	or any part of it, is strictly prohibited.
	Written by Peter Kapec <kapecp@gmail.com>
--]===========================================================================]

pHypergraph =
{
	--^	My stuff.
		_type='Hypergraph',
	--v
}

function pHypergraph:Query(query)

	local function CompareIN(query, edge_data)
		local matchedIN_in_edge = {}
		for incidence, node  in pairs(edge_data) do -- cez vsetky incidence=node  v edge
			if query(incidence, node) then
				matchedIN_in_edge[incidence] = node
			end
		end
		return matchedIN_in_edge
	end

	local found_edges = {}

	for fQueryEdge, tQueryEdgeData in pairs(query) do -- cez vsetky edge query
		local tmp_edges = {}

		for oEdge, tEdgeData in pairs(self.Edges) do	-- cez vsetky edge
			local e = fQueryEdge(oEdge)
			if e then
				local t = {}
				for _, fQueryIN  in pairs(tQueryEdgeData) do -- cez vsetky incidence=node query
					local i_n = CompareIN(fQueryIN, tEdgeData)
					if next(i_n) ~= nil then
						for i, n in pairs(i_n) do
							t[i]=n
						end
					else
						t = {}
						break
					end
				end

				if next(t) then
					for i, n in pairs(t) do
						tmp_edges[e] = tmp_edges[e] or  {}
						tmp_edges[e][i] = n
					end
				end
			end	--end of `if e then`
		end --end of `cez vsetky edge`

		if next(tmp_edges) ~= nil then
			for e, d in pairs(tmp_edges) do
				found_edges[e] = d
			end
		else
			found_edges = {}
			break
		end

	end

	local NewH = H{}
	NewH(found_edges)	--!	__call metamethod does't return anything...
	return NewH

end


function pHypergraph:CreateNodes()
	for oEdge, tEdgeData in pairs(self.Edges) do	-- cez vsetky edge
		for oIncidence, oNode  in pairs(tEdgeData) do -- cez vsetky incidence=node  v edge
			self.Nodes[oNode] = self.Nodes[oNode] or {}
			self.Nodes[oNode][oIncidence] = oEdge
		end
	end
end

function pHypergraph:AddNodesFromEdgeData(oEdge, tEdgeData)
	for oIncidence, oNode in pairs(tEdgeData) do	-- cez vsetky edge_data
			self.Nodes[oNode] = self.Nodes[oNode] or {}
			self.Nodes[oNode][oIncidence] = oEdge
	end
end

function pHypergraph:AddEdgesFromNodeData(oNode, tNodeData)
	for oIncidence, oEdge in pairs(tNodeData) do	-- cez vsetky node_data
			self.Edges[oEdge] = self.Edges[oEdge] or {}
			self.Edges[oEdge][oIncidence] = oNode
	end
end

--~ Construct empty hypergraph
function H()
	-- The new hypergraph (Nodes is a NIE matrix,  Edges is an EIN matrix)
	local hypergraph =  {Nodes = {}, Edges = {}}

	-- This is metatable is more a like a "proxy" for the underlying Nodes and Edges tables
	setmetatable(hypergraph,
		{
			-- Accessing edges
			__index = function(instance,key)

				-- try pHypergraph first then look for edges
				local value =  pHypergraph[key]	or instance.Edges[key] or instance.Nodes[key]

				-- if value not found, try to find node or edge by its id
				if (value == nil and type(key) == 'string') then
					local firstletter = key:sub(1, 1)
					if firstletter == 'N' then
						for node, relations in pairs(instance.Nodes) do
							if node.id == key then return node end
						end
					elseif firstletter == 'E' then
						for edge, relations in pairs(instance.Edges) do
							if edge.id == key then return edge end
						end
					end
				end

				return value
			end,

			-- Call constructor
			__call = function(instance,constructor)
				instance.Edges = constructor

				-- Set __newindex access for all edge-data tables
				for oEdge, tEdgeData in pairs(instance.Edges) do
					setmetatable(tEdgeData,
						{
							__newindex = function(edge_data,new_i,new_n)
								rawset(edge_data, new_i,  new_n)

			 					-- Update changed nodes
			 					instance.Nodes[new_n] = instance.Nodes[new_n] or {}
			 					instance.Nodes[new_n][new_i] = oEdge
							end
						}
					)
				end

				-- Update the Nodes table into NIE format
				instance:CreateNodes()
			end,

			-- Inserting/Deleting objects
			__newindex = function(instance,new_object,new_object_data)

				-- Deleting a Node or an Edge via nil
				if new_object_data == nil then
					if new_object._type == "Edge" then
						for oIncidence, oNode in pairs(instance.Edges[new_object]) do	-- cez vsetky node_data
							rawset(instance.Nodes[oNode], oIncidence,  nil)
						end
						rawset(instance.Edges, new_object,  nil)
						return
					elseif new_object._type == "Node" then
						for oIncidence, oEdge in pairs(instance.Nodes[new_object]) do	-- cez vsetky node_data
							rawset(instance.Edges[oEdge], oIncidence,  nil)
						end
						rawset(instance.Nodes, new_object,  nil)
						return
					end
				end

				-- Add new objects
				if new_object._type == "Edge" then
					instance.Edges[new_object]=new_object_data

					-- Set __newindex access for the new edge-data table
					setmetatable(instance.Edges[new_object],
						{
							__newindex = function(edge_data,new_i,new_n)
								rawset(edge_data, new_i,  new_n)

								-- Update changed nodes
								instance.Nodes[new_n] = instance.Nodes[new_n] or {}
								instance.Nodes[new_n][new_i] = new_object
							end
						}
					)

					-- Update changed nodes
					instance:AddNodesFromEdgeData(new_object, new_object_data)

				elseif new_object._type == "Node" then
					instance.Nodes[new_object]=new_object_data

					-- Set __newindex access for the new edge-data table
					setmetatable(instance.Nodes[new_object],
						{
							__newindex = function(node_data,new_i,new_n)
								rawset(node_data, new_i,  new_n)

								-- Update changed nodes
								instance.Edges[new_n] = instance.Edges[new_n] or {}
								instance.Edges[new_n][new_i] = new_object
							end
						}
					)

					-- Update changed nodes
					instance:AddEdgesFromNodeData(new_object, new_object_data)
				end
			end,
		}
	)

	return hypergraph
end
