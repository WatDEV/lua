local colors = require "city.colorSetup":new()

local cityModule = {}

local function compareStatements(a,b)
	return a.position < b.position
end


local function TableConcat(t1,t2)
	for i=1,#t2 do
		t1[#t1+1] = t2[i]
	end
	return t1
end

local function contains(array, id)
	for i,v in pairs(array) do
		if(v.id == id) then
			return true
		end
	end
	return false
end

function cityModule:create(inputGraph, pivot, moduleId)
	local CityModule = {}
	local graph = inputGraph
	local pivot = pivot
	local moduelId = moduleId

	local buildingHeight = 1
	local buildingPlatformSize = 5
	local spaceBetweenBuildings = 1 -- function and variables
	local spaceBetweenPlatforms = 5   --directories and files
	local platformHeight = 2
	local spaceBuffer = 1 --how much is left over the edge of platform

	local functionBase = {}
	local variableBase = {}
	local interfaceBase = {}
	
	local function doLayout()
		CityModule.initFunctionProperties()
		CityModule.initVariablesProperties()
		CityModule.initInterfaceFunctionsProperties()
		functionBase = CityModule.initFunctionsBaseProperties()
		interfaceBase = CityModule.initInterfaceBaseProperties()
		variableBase = CityModule.initVariablesBaseProperties()
		CityModule.initModuleProperties(functionBase.size, variableBase.size, interfaceBase.size)

		CityModule.layoutAllNodes(functionBase, interfaceBase, variableBase)

		-- maybe layout edges
	end
	local function layoutAllNodes(functionBase, interfaceBase, variableBase)
		local moduleBaseLocation = CityModule.layoutModuleBase()
		CityModule.layoutBases(functionBase, variableBase, interfaceBase, moduleBaseLocation)

		CityModule.layoutNodes(CityModule.getFunctions(),functionBase.position)
		CityModule.layoutNodes(CityModule.getVariables(),variableBase.position)
		CityModule.layoutNodes(CityModule.getInterfaceFunctions(),interfaceBase.position)
	end
	local function layoutModuleBase()
		local mod = CityModule.getModule()
		mod.position = pivot
		return mod.position
	end
	local function layoutBases(functionBase, variableBase, interfaceBase, moduleBaseLocation)
		functionBase.position = 
		{
			x = moduleBaseLocation.x + spaceBuffer,
			y = moduleBaseLocation.y + spaceBuffer,
			z = moduleBaseLocation.z + platformHeight
		}
		variableBase.position = 
		{
			x = functionBase.position.x + spaceBuffer + spaceBetweenPlatforms + functionBase.size.x,
			y = functionBase.position.y + spaceBuffer + spaceBetweenPlatforms + functionBase.size.y,
			z = moduleBaseLocation.z + platformHeight
		}
		interfaceBase.position = 
		{
			x = variableBase.position.x + spaceBuffer + spaceBetweenPlatforms + variableBase.size.x,
			y = variableBase.position.y + spaceBuffer + spaceBetweenPlatforms + variableBase.size.y,
			z = moduleBaseLocation.z + platformHeight
		} 
		graph.nodes[#graph.nodes + 1] = functionBase
		graph.nodes[#graph.nodes + 1] = variableBase
		graph.nodes[#graph.nodes + 1] = interfaceBase
	end
	local function layoutNodes(nodes, startPosition)
		local size = math.floor(math.sqrt(table.getn(nodes)))
		if(size * size == table.getn(nodes)) then size = size - 1 end

		local x = 0
		local y = 0
		local previousX = startPosition.x
		local previousY = startPosition.y

		for index,node in pairs(nodes) do
			
			node.position = {}
			node.position.x = previousX + spaceBetweenBuildings + (node.size.x /2)
			node.position.y = previousY + spaceBetweenBuildings + (node.size.y /2)
			node.position.z = startPosition.z + (node.size.z /2)

			x = x + 1
			previousX = previousX + node.size.x + spaceBetweenBuildings
			if(x > size) then
				previousX = startPosition.x
				previousY = previousY + node.size.y + spaceBetweenBuildings
				x = 0
				y = y + 1
			end
		end
	end
	local function initModuleProperties(functionBaseSize, variableBaseSize, inerfaceBaseSize)
		local mod = CityModule.getModule()

		local maxY = 0
		local maxX = 0

		local all = {functionBaseSize,variableBaseSize,inerfaceBaseSize}
		if(all ~= nil) then
			for _,size in pairs(all) do
				if(size.y > maxY) then
					maxY = size.y
				end
				if(size.x > maxX) then
					maxX = size.x
				end
			end
		end

		mod.size = 
		{
			x = 3 * (maxX + spaceBetweenPlatforms) + spaceBuffer,
			y = 3 * (maxY + spaceBetweenPlatforms) + spaceBuffer,
			z = platformHeight
		}
		mod.rotation = {x = 0, y = 0, z = 0}
		mod.color = colors.moduleColor
	end

	local function calculateColors(statement, parentColor, colorArray)
		print(statement.tag)
		local color = 
		{
			r = colors.statementColors[statement.tag].r + parentColor.r,
			g = colors.statementColors[statement.tag].g + parentColor.g,
			b = colors.statementColors[statement.tag].b + parentColor.b
		}

		print("adding :"..color.r .. color.g .. color.b)
		colorArray[#colorArray+1] = color

		if(statement.metrics.statements ~= nil) then
			local statements = {}
			for key,statement in pairs(statement.metrics.statements) do
				TableConcat(statements, statement)
			end

			table.sort(statements,compareStatements)
			for key,statement in pairs(statements) do
				--if statement is condition or cycle pass your color as tint
				calculateColors(statement, color, colorArray)
				--else
				calculateColors(statement, parentColor, colorArray)
			end
		end
	end

	local function initFunctionProperties()
		local functions = CityModule.getFunctions()
		for k,v in pairs(functions) do
			if(v.meta.type == "function") then
				--v.data = CityModule.getFunctionData(v)
				
				v.rotation = {x = 0 ,y = 0, z = 0}
				v.shape = "cube"
				--v.type = "function"
				v.color = {}

				if(v.data.metrics.statements ~= nil) then
					print("statements not nill")
					local statements = {}
					for key,statement in pairs(v.data.metrics.statements) do
						TableConcat(statements, statement)
					end

					table.sort(statements,compareStatements)
					for key,statement in pairs(statements) do
						calculateColors(statement,  {r=0, g=0, b=0}, v.color)
					end
				end		

				v.size = 
				{
					x = buildingPlatformSize,
					y = buildingPlatformSize,
					z = #v.color + 1 -- at least 1 high
				}

				--[[
				v.color = colors.functionCodeColor
				v.size = 
				{
					x = buildingPlatformSize,
					y = buildingPlatformSize,
					z = (v.data.metrics.LOC.lines_code * buildingHeight) + 1 -- at least 1 high
				}

				if(v.data.metrics.LOC.lines_comment > 0 and v.data.metrics.LOC.lines_blank) then
					--segment showing amoung of comments
					v.children= {}
					v.children[1] = 
					{
						size = 
						{
							x = buildingPlatformSize,
							y = buildingPlatformSize,
							z = (v.data.metrics.LOC.lines_comment * buildingHeight) 
						},
						rotation = {x = 0 ,y = 0, z = 0},
						color = colors.functionCommentColor,
						type = "superstructure",
						shape = "cube",
						children = {}
									
					}
					---segment showing amount of blank lines
					v.children[1].children[1] = 
					{
						size = 
						{
							x = buildingPlatformSize,
							y = buildingPlatformSize,
							z = (v.data.metrics.LOC.lines_blank * buildingHeight) 
						},
						rotation = {x = 0 ,y = 0, z = 0},
						color = colors.functionBlankColor,
						type = "superstructure",
						shape = "cube"					
					}	
				elseif (v.data.metrics.LOC.lines_comment > 0) then
					v.children= {}
					v.children[1] = 
					{
						size = 
						{
							x = buildingPlatformSize,
							y = buildingPlatformSize,
							z = (v.data.metrics.LOC.lines_comment * buildingHeight) 
						},
						rotation = {x = 0 ,y = 0, z = 0},
						color = colors.functionCommentColor,
						type = "superstructure",
						shape = "cube"									
					}
				elseif(v.data.metrics.LOC.lines_blank > 0) then 
					v.children= {}
					v.children[1] = 
					{
						size = 
						{
							x = buildingPlatformSize,
							y = buildingPlatformSize,
							z = (v.data.metrics.LOC.lines_blank * buildingHeight) 
						},
						rotation = {x = 0 ,y = 0, z = 0},
						color = colors.functionBlankColor,
						type = "superstructure",
						shape = "cube"					
					}	
				end ]]

			end	
		end
	end
	local function initVariablesProperties()
		for k,v in pairs(graph.nodes) do
			if(v.meta.type == "local variable") then
				v.data = nil
				v.size = 
				{
					x = buildingPlatformSize,
					y = buildingPlatformSize,
					z = 10
				}
				v.rotation = {x = 0 ,y = 0, z = 0}
				v.shape = "cube"
				v.type = "local variable"
				v.color = colors.localVariableColor			
			end	
			if(v.meta.type == "global variable") then
				v.data = nil
				v.size = 
				{
					x = buildingPlatformSize,
					y = buildingPlatformSize,
					z = 10
				}
				v.rotation = {x = 0 ,y = 0, z = 0}
				v.shape = "cube"
				v.type = "global variable"
				v.color = colors.globalVariableColor
			end	
		end
	end
	local function initInterfaceFunctionsProperties()
		for k,v in pairs(graph.nodes) do
			if(v.meta.type == "interface") then
				v.data = nil
				v.size = 
				{
					x = buildingPlatformSize,
					y = buildingPlatformSize,
					z = 10
				}
				v.rotation = {x = 0 ,y = 0, z = 0}
				v.shape = "cube"
				v.type = v.meta.type
				v.color = colors.interfaceFunctionsColor	
			end	
		end
	end
	local function initFunctionsBaseProperties()
		local functionBase = {}
		functionBase.id = moduleId.."functions"
		functionBase.size = CityModule.calculateFunctionBaseSize()
		functionBase.rotation = {x = 0, y = 0, z = 0}
		functionBase.meta = {type = "function base"}
		functionBase.color = colors.functionBaseColor
		return functionBase
	end
	local function initVariablesBaseProperties()
		local variableBase = {}
		variableBase.id = moduleId.."variables"
		variableBase.size = CityModule.calculateVariableBaseSize()
		variableBase.rotation = {x = 0, y = 0, z = 0}
		variableBase.meta = {type = "variable base"}
		variableBase.color = colors.variableBaseColor
		return variableBase
	end
	local function initInterfaceBaseProperties()
		local interfaceBase = {}
		interfaceBase.id = moduleId.."interfaces"
		interfaceBase.size = CityModule.calculateInterfaceBaseSize()
		interfaceBase.rotation = {x = 0, y = 0, z = 0}
		interfaceBase.meta = {type = "interface base"}
		interfaceBase.color = colors.interfaceBaseColor
		return interfaceBase
	end
	local function calculateFunctionBaseSize()
		local children = CityModule.getFunctions()
		local size = math.floor(math.sqrt(table.getn(children)))

		if(size == 0) then 
			return 
			{
				x = buildingPlatformSize  + (2 * spaceBuffer),
				y = buildingPlatformSize + (2 * spaceBuffer),
				z = platformHeight
			}
		end

		if((size * (size+1)) >= table.getn(children)) then 
			return 
			{
				x = ((buildingPlatformSize * (size+1)) + ((size+2) * spaceBuffer)),
				y = ((buildingPlatformSize * (size)) + ((size+1) * spaceBuffer)),
				z = platformHeight
			}
		end

		return 
		{
			x = ((buildingPlatformSize * (size+1)) + ((size+2) * spaceBuffer)),
			y = ((buildingPlatformSize * (size+1)) + ((size+2) * spaceBuffer)),
			z = platformHeight
		}
	end
	local function calculateVariableBaseSize()
		local children = CityModule.getVariables()
		local size = math.floor(math.sqrt(table.getn(children)))

		if(size == 0) then 
			return 
			{
				x = buildingPlatformSize  + (2 * spaceBuffer),
				y = buildingPlatformSize + (2 * spaceBuffer),
				z = platformHeight
			}
		end

		if((size * (size+1)) >= table.getn(children)) then 
			return 
			{
				x = ((buildingPlatformSize * (size+1)) + ((size+2) * spaceBuffer)),
				y = ((buildingPlatformSize * (size)) + ((size+1) * spaceBuffer)),
				z = platformHeight
			}
		end

		return 
		{
			x = ((buildingPlatformSize * (size+1)) + ((size+2) * spaceBuffer)),
			y = ((buildingPlatformSize * (size+1)) + ((size+2) * spaceBuffer)),
			z = platformHeight
		}
	end
	local function calculateInterfaceBaseSize()
		local children = CityModule.getInterfaceFunctions()
		local size = math.floor(math.sqrt(table.getn(children)))

		if(size == 0) then 
			return 
			{
				x = buildingPlatformSize  + (2 * spaceBuffer),
				y = buildingPlatformSize + (2 * spaceBuffer),
				z = platformHeight
			}
		end

		if((size * (size+1)) >= table.getn(children)) then 
			return 
			{
				x = ((buildingPlatformSize * (size+1)) + ((size+2) * spaceBuffer)),
				y = ((buildingPlatformSize * (size)) + ((size+1) * spaceBuffer)),
				z = platformHeight
			}
		end

		return 
		{
			x = ((buildingPlatformSize * (size+1)) + ((size+2) * spaceBuffer)),
			y = ((buildingPlatformSize * (size+1)) + ((size+2) * spaceBuffer)),
			z = platformHeight
		}
	end
	local function getFunctions()
		local functions = {}
		local i = 1
		for k,v in pairs(graph.edges) do
			if(v.from[1].id == moduleId and v.to[1].meta.type == "function" and v.label == "declares") then
				functions[i] = v.to[1]
				i=i+1
			end
		end
		return functions
	end	
	local function getInterfaceFunctions()
		local functions = {}
		local i = 1
		for k,v in pairs(graph.edges) do
			if(v.from[1].id == moduleId and v.to[1].meta.type == "interface" and v.label == "provides") then
				functions[i] = v.to[1]
				i=i+1
			end
		end
		return functions
	end	
	local function getVariables()
		local variables = {}
		local i = 1
		for k,v in pairs(graph.edges) do
			if(v.from[1].id == moduleId and (v.to[1].meta.type == "local variable" or v.to[1].meta.type == "global variable") and v.label == "initializes") then
				if(not contains(variables, v.to[1].id)) then
					variables[i] = v.to[1]
					i=i+1
				end
			end
		end
		return variables
	end	
	local function getModule()
		local i = 1
		for k,v in pairs(graph.nodes) do
			if(v.id == moduleId) then
				return v
			end
		end
		return nil
	end		
	local function getLayoutedGraph()
		return graph
	end
	local function getFunctionData(oldNode)
		local data = {}
		data.modulePath = oldNode.meta.modulePath
		data.tag = oldNode.data.tag
		data.metrics= {}
		data.metrics.halstead = {}
		data.metrics.halstead.uniqueOperands = oldNode.data.metrics.halstead.unique_operands
		data.metrics.halstead.DIF = oldNode.data.metrics.halstead.DIF
		data.metrics.halstead.LTH = oldNode.data.metrics.halstead.LTH
		data.metrics.halstead.time = oldNode.data.metrics.halstead.time
		data.metrics.halstead.VOL = oldNode.data.metrics.halstead.VOL
		data.metrics.halstead.EFF = oldNode.data.metrics.halstead.EFFh
		data.metrics.halstead.BUG = oldNode.data.metrics.halstead.BUG
		data.metrics.halstead.VOC = oldNode.data.metrics.halstead.VOC
		data.metrics.halstead.number_of_operators = oldNode.data.metrics.halstead.number_of_operators
		data.metrics.halstead.unique_operators = oldNode.data.metrics.halstead.unique_operators
		data.metrics.halstead.number_of_operands = oldNode.data.metrics.halstead.number_of_operands
		data.metrics.cyclomatic = oldNode.data.metrics.cyclomatic
		data.metrics.LOC = oldNode.data.metrics.LOC
		data.metrics.infoflow = oldNode.data.metrics.infoflow
		return data
	end

	local function getModuleSize()
		local var = CityModule.calculateVariableBaseSize()
		local func = CityModule.calculateFunctionBaseSize()
		local interface = CityModule.calculateInterfaceBaseSize()
		return 
		{
			x = var.x + func.x + interface.x,
			y = var.y + func.y + interface.y,
			z = var.z 
		}
	end

	CityModule.doLayout = doLayout
	CityModule.layoutNodes = layoutNodes
	CityModule.layoutAllNodes = layoutAllNodes
	CityModule.layoutBases = layoutBases
	CityModule.layoutModuleBase = layoutModuleBase

	CityModule.initFunctionProperties = initFunctionProperties
	CityModule.initFunctionsBaseProperties = initFunctionsBaseProperties
	CityModule.initModuleProperties = initModuleProperties
	CityModule.initVariablesProperties = initVariablesProperties
	CityModule.initVariablesBaseProperties = initVariablesBaseProperties
	CityModule.initInterfaceFunctionsProperties = initInterfaceFunctionsProperties
	CityModule.initInterfaceBaseProperties = initInterfaceBaseProperties

	CityModule.calculateVariableBaseSize = calculateVariableBaseSize
	CityModule.calculateFunctionBaseSize = calculateFunctionBaseSize
	CityModule.calculateInterfaceBaseSize = calculateInterfaceBaseSize

	CityModule.getFunctions = getFunctions
	CityModule.getVariables = getVariables
	CityModule.getInterfaceFunctions = getInterfaceFunctions
	CityModule.getModule = getModule

	CityModule.getFunctionData = getFunctionData
	CityModule.getModuleSize = getModuleSize
	return CityModule
end


return {
	new = cityModule.create
}