

package.path = "lua\\?.lua;lua\\?\\init.lua;lua\\?\\?.lua"

local pk = require "pk.dbg"
local graphImporter = require "graph_importer"
local hypergraph = require "luadb.hypergraph.init"
local c = require "city"
local json = require "json"
local lunajson = require "lunajson"

luadbGraph = nil
colorTable = nil
astID = nil
graphManager = require "luadb.manager.graph".new()
graphImporter.extractGraph("lua\\leg","module graph")


local graph = graphImporter.getLuadbGraph()

--[[
os.remove("leg.txt")
local file = io.open("leg.txt", "a")
io.output(file)
io.write(json.encode(graph))
io.close(file)
local function p(tab,k,v)
	if(type(v) == "boolean") then 
		if v == true then 
			io.write(tab .. k .. " : " .. "true" .."\n")
		else
			io.write(tab .. k .. " : " .. "false" .."\n")	
		end	
	elseif(type(v) ~= "table") then
		io.write(tab .. k .. " : " .. v .."\n")	
	else 
		io.write(tab .. k .. "\n")
	end
end
os.remove("g.txt")
local file = io.open("g.txt", "a")
io.output(file)
for k,v in pairs(graph) do
	p("",k,v)
	if(type(v) == "table") then
		for k,v in pairs(v) do
			p("\t",k,v)
			if(type(v) == "table") then
				for k,v in pairs(v) do
					p("\t\t",k,v)
					if(v ~= nil and type(v) == "table") then
						for k,v in pairs(v) do
							p("\t\t\t",k,v)
							if(v ~= nil and type(v) == "table") then
								for k,v in pairs(v) do
									p("\t\t\t\t",k,v)
									if(v ~= nil and type(v) == "table") then
										for k,v in pairs(v) do
											p("\t\t\t\t\t",k,v)
											if(v ~= nil and type(v) == "table") then
												for k,v in pairs(v) do
													p("\t\t\t\t\t\t",k,v)
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end
io.close(file)
]]
local city = c:new(graph)

city.doLayout()

local g = city.getGraph()


os.remove("newgraph.txt")
local file = io.open("newgraph.txt", "a")
io.output(file)
io.write(lunajson.encode(g.nodes))
io.close(file)

--[[
os.remove("i.txt")
local file = io.open("i.txt", "a")
io.output(file)
io.write(json.encode(edges))
io.close(file)
--]]
--[[local function addEdge(graph, v1, v2)
    local edge = hypergraph.edge.new()
    edge:setSource(v1)
    edge:setTarget(v2)
    graph:addEdge(edge)
end

local newGraph = hypergraph.graph.new()
local nodes = {}


for index,node in pairs(graph.nodes) do
	newGraph:addNode(node)
end

for index,node in pairs(graph.nodes) do
	for node2 in node.funcionalNodes then
		addEdge(newGraph,node,node2)
	end
end]]--


--[[local file = io.open("h.txt", "a")
io.output(file)
for k,v in pairs(graph.nodes) do
	if(v.meta) then
		io.write(v.meta.type,"\n")
	end
end
io.close(file)
]]--

