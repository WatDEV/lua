-----------------------------------------------
-- GRAPH - luadb graph module
-- @release 2013/12/03, Tomas Filcak
-----------------------------------------------

local pGraph = {
    _type = 'Graph'
}

local n = 0
local function inc()
  n = n + 1
  return n
end

local function G(arguments)
  local arguments = arguments or {}

  local o = {
      id = "G"..inc(),
      nodes = {},
      edges = {},
      label = nil,
	  modificators = {},	--zoznam modifikatorov--
	  cacheN = {}, 			--zoznam id uzlov vo formate kluc - hodnota (N5 - poradie z tabulky nodes)--
	  cacheE = {}			--zoznam id hran vo formate kluc - hodnota (E5 - poradie z tabulky edges)--
  }

  setmetatable(o,
    {
      __index = function(t,k)
		if k == "modified_nodes" then
			if #t.modificators == 0 then
				return t.nodes
			else
				return t.modificators[#t.modificators].nodes
			end
		elseif k == "modified_edges" then
			if #t.modificators == 0 then
				return t.edges
			else
				return t.modificators[#t.modificators].edges
			end
		else
			return pGraph[k]
		end
      end,
      __tostring = function(t)
        if t.id and t.label then return "graph "..t.id..":"..t.label
        elseif t.id then return "graph "..t.id
        else return "graph" end
      end
    }
  )

  -- passing arguments
  for key,value in pairs(arguments) do
    o[key] = value
  end

  return o
end

-------------------------------- Add Operator

local function modifierNodes(self,modifier, foundN, isEmpty)
	for key,value in ipairs(self.nodes) do
		local ret = modifier.func(value,modifier.cond)
		if ret then
			isEmpty = false
			foundN[ret.id] = modifier.action(value)
			if #self.modificators == 1 then
				setmetatable(foundN[ret.id],
				{
				  __index = self.nodes[self.cacheN[ret.id]]
				}
			  )
			else
				setmetatable(foundN[ret.id],
				{
				  __index = self.modificators[#self.modificators-1].nodes[ret.id]
				}
			  )
			end
		end
	end
	return isEmpty
end

local function modifierEdges(self,modifier, foundE, isEmpty)
	for key,value in ipairs(self.edges) do
		local ret = modifier.func(value)
		if ret then
			isEmpty = false
			foundE[ret.id] = modifier.action(value)
			if #self.modificators == 1 then
				setmetatable(foundE[ret.id],
				{
				  __index = self.edges[self.cacheE[ret.id]]
				}
			  )
			else
				setmetatable(foundE[ret.id],
				{
				  __index = self.modificators[#self.modificators-1].edges[ret.id]
				}
			  )
			end
		end
	end
	return isEmpty
end

function pGraph:Operator(modifier)
	table.insert(self.modificators,
	{
		nodes={},
		edges={}
	})

	local foundN = self.modificators[#self.modificators].nodes
	local foundE = self.modificators[#self.modificators].edges
	local isEmpty = true
	if modifier.what == "NODE" then
		isEmpty = modifierNodes(self,modifier, foundN, isEmpty)
	end
	if modifier.what == "EDGE" then
		isEmpty = modifierEdges(self,modifier, foundE, isEmpty)
	end
	if modifier.what == "BOTH" then
		local isEmptyE = modifierEdges(self,modifier, foundE, isEmpty)
		local isEmptyN = modifierNodes(self,modifier, foundN, isEmpty)
		if isEmptyE and isEmptyN then
			isEmpty = true
		else
			isEmpty = false
		end
	end

	if isEmpty then
		self.modificators[#self.modificators] = nil
	end
end

-------------------------------- Add functions

function pGraph:addNode(node)
  table.insert(self.nodes, node)
  if self.NodeMapper then
    self.NodeMapper:save(node)
  end
  self.cacheN[node.id] = #self.nodes
end


function pGraph:addEdge(edge)
  table.insert(self.edges, edge)
  if self.EdgeMapper then
    self.EdgeMapper:save(edge)
  end
  self.cacheE[edge.id] = #self.edges
end

-------------------------------- Remove functions

-- remove node by id
function pGraph:removeNodeByID(nodeID)
  for index, vNode in pairs(self.nodes) do
    if vNode.id == nodeID then
      self.nodes[index] = nil
	  self.cacheN[vNode.id] = nil
      return true
    end
  end
  return false
end

-- remove edge by id
function pGraph:removeEdgeByID(edgeID)
  for index, vEdge in pairs(self.edges) do
    if vEdge.id == edgeID then
      self.edges[index] = nil
	  self.cacheE[vEdge.id] = nil
      return true
    end
  end
  return false
end

-------------------------------- Print functions

function pGraph:printNodes()
  for index,node in pairs(self.nodes) do
    if node.data.name then
      print("NODE with ID: "..node['id'].." NAME: "..node['data']['name'])
    else
      print("NODE with ID: "..node['id'])
    end
  end
end


local function concatNodes(str, nodes)
  for i,node in pairs(nodes) do
    if type(node) == "table" and node.data and node.data.name then
      str = str.." "..node.data.name
    elseif type(node) == "table" and node.id then
      str = str.." "..node.id
    else
      str = str.." "..node
    end
  end
  return str
end


function pGraph:printEdges()
  for index,edge in pairs(self.edges) do
    if edge.from and edge.to then
        local from = concatNodes(" FROM", edge.from)
        local to = concatNodes(" TO", edge.to)
        print("EDGE with ID: ".. edge.id .. from .. to)
    end
  end
end

-------------------------------- Find functions

-- get all nodes with selected id
function pGraph:findNodeByID(id)
  for i,node in pairs(self.nodes) do
    if (node.id == id) then
      return node
    end
  end
end

-- get all nodes with selected name
function pGraph:findNodesByName(name)
  local occurrences = {}
  for i,node in pairs(self.nodes) do
    if node.data.name and (node.data.name == name) then
      table.insert(occurrences, node)
    end
  end
  return occurrences
end

 -- get all nodes with selected type
function pGraph:findNodesByType(type)
  local occurrences = {}
  for i,node in pairs(self.nodes) do
    if node.meta and node.meta.type and (node.meta.type == type) then
      table.insert(occurrences, node)
    end
  end
  return occurrences
end

-- get all ids for nodes with selected name
function pGraph:findNodeIdsByName(name)
  local occurrence_ids = {}
  for i,node in pairs(self.nodes) do
    if node.data.name and (node.data.name == name) then
      table.insert(occurrence_ids, node.id)
    end
  end
  return occurrence_ids
end

-- get all edges with selected label
function pGraph:findEdgesByLabel(label)
  local occurrence = {}
  for i,edge in pairs(self.edges) do
    if edge.label and (edge.label == label) then
      table.insert(occurrence, edge)
    end
  end
  return occurrence
end

-- get all edges with selected source ID and selected label
function pGraph:findEdgesBySource(sourceID, label)
  local occurrences = {}
  for i,edge in pairs(self.edges) do
    if (edge.label == label) and (edge.from[1].id == sourceID) then
      table.insert(occurrences, edge)
    end
  end
  return occurrences
end


 -- get all edges with selected target ID and selected label
function pGraph:findEdgesByTarget(targetID, label)
  local occurrences = {}
  for i,edge in pairs(self.edges) do
    if (edge.label == label) and (edge.to[1].id == targetID) then
      table.insert(occurrences, edge)
    end
  end
  return occurrences
end

-- get all outgoing edges from node 'sourceID'
function pGraph:findAllEdgesBySource(sourceID)
  local occurrences = {}
  for k, edge in pairs(self.edges) do
    if edge.from[1].id == sourceID then
      table.insert(occurrences, edge)
    end
  end
  return occurrences
end

-----------------------------------------------
-- Return
-----------------------------------------------

return
{
  new = G
}
