local cityModule = require "city.cityModule"

local function TableConcat(t1,t2)
	for i=1,#t2 do
		t1[#t1+1] = t2[i]
	end
	return t1
end

local city = {}

function city:create(graph)
	local City = {}
	local graph = graph

	local nodesArray = {}
	local edgesArray = {}
	local buildingHeight = 1
	local buildingPlatformSize = 5
	local spaceBetweenBuildings = 1 -- function and variables
	local spaceBetweenPlatforms = 5   --directories and files
	local platformHeight = 2
	local spaceBuffer = 1 --how much is left over the edge of platform

	local functionCodeColor = {r=255, g=0, b=0}
	local functionCommentColor = {r=0, g=120, b=0}
	local functionBlankColor = {r=0, g=0, b=0}
	local functionBaseColor = {r=200, g=0, b=0}
	
	local localVariableColor = {r=236, g=117, b=5}
	local globalVariableColor = {r=67, g=127, b=151}
	local variableBaseColor = {r=216, g=74, b=5}

	local interfaceFunctionsColor = {r=255, g=179, b=15}
	local interfaceBaseColor = {r=255, g=179, b=15}

	local moduleColor = {r=120, g=0, b=0}
	local fileColor = {r=3, g=71, b=50}
	local directoryColor = {r=150, g=150, b=150}

	local function doLayout()
		nodesArray = {}
		edgesArray = {}
		local highestDirectory = City.getRootDirectory()
		local rootDirectory = City.initDirectoryProperties(highestDirectory)
		City.layoutNodes(rootDirectory, 0, 0, 0)
		--City.layoutEdges()
	end
	
	local function compare( a,b )
			return a.size.x * a.size.y  * a.size.z> b.size.x * b.size.y * b.size.z
	end

	local function layoutEdges()
		for _,v in pairs(graph.edges) do 
			if(v.from[1].meta and v.to[1].meta) then
				--[[if(v.from[1].meta.type == "function" and v.to[1].meta.type == "interface" and v.label == "represents") then
					local e = City.insertFunctionToInterfaceEdge(v.from[1].id,v.to[1].id)
					if(e) then 
						edgesArray[#edgesArray +1] = e 
					end
				elseif((v.from[1].meta.type == "local variable" or v.from[1].meta.type == "global variable") and v.to[1].meta.type == "interface" and v.label == "represents") then
					local e = City.insertVariableToInterfaceEdge(v.from[1].id, v.to[1].id)
					if(e) then 
						edgesArray[#edgesArray +1] = e 
					end]]--
				if(v.from[1].meta.type == "function" and v.to[1].meta.type == "function" and v.label == "calls") then
					local e = City.insertFunctionToFunctionEdge(v.from[1].id, v.to[1].id)
					if(e) then 
						edgesArray[#edgesArray +1] = e 
					end
				end
			end
		end
	end

	local function layoutNodes(node, startX, startY, startZ)
		node.position = {}

		if(node.type == "directory")then
			node.size = City.calculateDirectorySize(node.children)
		end


		--if node type == module
		if(node.meta.type == "module") then

			node.position.x = startX 
			node.position.y = startY
			node.position.z = startZ
			local m = cityModule:new(graph, node.position, node.id)
			m.doLayout()
			return
		end

		node.position.x = startX + (node.size.x /2)
		node.position.y = startY + (node.size.y /2)
		node.position.z = startZ + (node.size.z /2)

		if(node.children == nil or table.getn(node.children) == 0) then
			--node.meta = nil
			--nodesArray[#nodesArray + 1] = node
			return
		end
		
		--table.sort(node.children, compare)

		local size = math.floor(math.sqrt(table.getn(node.children)))
		if(size * size == table.getn(node.children)) then size = size - 1 end

		local x = 0
		local y = 0
		local previousX = startX
		local previousY = startY
		local maxY = 0
		local spaceModifier = 0

		if(node.meta.type == "directory") then spaceModifier = spaceBetweenPlatforms 
		else spaceModifier = spaceBetweenBuildings end

		for index,n in pairs(node.children) do
			--if it is superstruture we do not want to add space between buildings
			--if(n.type == "superstructure") then 
			--	City.layoutNodes(n, previousX, previousY, startZ + node.size.z )
			--else
			if(x == 0 and y == 0) then 
				City.layoutNodes(n, previousX + spaceBuffer, previousY + spaceBuffer, startZ + node.size.z )
			elseif(x == 0) then
				City.layoutNodes(n, previousX + spaceBuffer, previousY + spaceModifier, startZ + node.size.z )
			elseif(y == 0) then
				City.layoutNodes(n, previousX + spaceModifier, previousY + spaceBuffer, startZ + node.size.z )
			else
				City.layoutNodes(n, previousX + spaceModifier, previousY + spaceModifier, startZ + node.size.z )
			end
			--end

			if(n.size.y > maxY) then maxY = n.size.y end

			x = x + 1
			previousX = previousX + n.size.x + spaceModifier
			if(x > size) then
				previousX = startX
				previousY = previousY + maxY + spaceModifier
				maxY = 0
				x = 0
				y = y + 1
			end
		end

		node.children = nil
		--node.meta = nil
		--nodesArray[#nodesArray + 1] = node
	end

	local function initDirectoryProperties(directory)
		local innerDirectories = City.getDirectoriesInDirectory(directory)
		local layoutedDirectories = {}
		if next(innerDirectories) ~= nil then
			local i = 1
			for k,v in pairs(innerDirectories) do
				local d = City.initDirectoryProperties(v)
				if(d) then
					layoutedDirectories[i] = d
					i = i + 1
				end
			end
		end

		local innerFiles = City.getFilesInDirectory(directory)
		local layoutedFiles = {}
		if next(innerFiles) ~= nil then
			local i = 1
			for k,v in pairs(innerFiles) do
				local f = City.initFileProperties(v)
				if(f) then
					layoutedFiles[i] = f
					i = i + 1
				end
			end
		end
		local children = TableConcat(layoutedFiles,layoutedDirectories)
		if(#children == 0) then
			return nil
		end

		--order by size
		--table.sort(children, compare)
		directory.children = children
		directory.size = City.calculateDirectorySize(directory.children)
		directory.rotation = {x = 0, y = 0, z = 0}
		directory.color = directoryColor
		return directory
	end

	local function calculateDirectorySize(children)		
		local m = math.floor(math.sqrt(table.getn(children)))

		if(m*m == table.getn(children)) then m = m -1 end

		local maxX = 0
		local maxY = 0
		local currentX = 0
		local localMaxY = 0

		local x = 0
		local y = 0
		for k,v in pairs(children) do 
			currentX = currentX + v.size.x + spaceBetweenPlatforms

			if(currentX > maxX) then maxX = currentX end
			if(v.size.y > localMaxY) then localMaxY = v.size.y end

			x = x + 1
			if x > m or k == table.getn(children) then
				currentX = 0
				maxY = maxY + localMaxY + spaceBetweenPlatforms
				localMaxY = 0
				x = 0
				y = y + 1
			end
		end
		local size = 
		{
			x = maxX + spaceBuffer, -- a little left over to not be stacked directly on top of each other
			y = maxY + spaceBuffer,
			z = platformHeight
		}
		return size
	end

	local function calculateFileSize(children)
		local m = math.floor(math.sqrt(table.getn(children)))

		if(m*m == table.getn(children)) then m = m -1 end

		local maxX = 0
		local maxY = 0
		local currentX = 0
		local localMaxY = 0

		local x = 0
		local y = 0
		for k,v in pairs(children) do 
			currentX = currentX + v.size.x + spaceBetweenPlatforms

			if(currentX > maxX) then maxX = currentX end
			if(v.size.y > localMaxY) then localMaxY = v.size.y end

			x = x + 1
			if x > m or k == table.getn(children) then
				currentX = 0
				maxY = maxY + localMaxY + spaceBetweenPlatforms
				localMaxY = 0
				x = 0
				y = y + 1
			end
		end
		local size = 
		{
			x = maxX + spaceBuffer, -- a little left over to not be stacked directly on top of each other
			y = maxY + spaceBuffer,
			z = platformHeight
		}
		return size
	end

	local function initFileProperties(file)
		local m = City.getModulesInFile(file)

		--local functions = City.getFunctionsInFile(file)
		--City.initFunctionProperties(functions)

		--local variables = City.getVariablesInFile(file)
		--City.initVariablesProperties(variables)

		--local all = TableConcat(modules,functions,variables)

		local fileToReturn = {}
		file.size = cityModule:new(graph, {x=0;y=0;z=0}, m[1].id).getModuleSize()
		file.rotation = {x = 0, y = 0, z = 0}
		file.color = fileColor
		file.children = City.getModulesInFile(file)
		return file
	end	

	local function getRootDirectory()
		for k,v in pairs(graph.nodes) do 
			if (v.id == "N1") then
				return v
			end
		end
	end

	local function contains(array, id)
		for i,v in pairs(array) do
			if(v.id == id) then
				return true
			end
		end
		return false
	end

	local function getModulesInFile(file)
		local modules = {}
		local i = 1
		for k,v in pairs(graph.edges) do
			if(v.from[1].id == file.id and v.to[1].meta.type == "module" and v.label == "implements") then
				modules[i] = v.to[1]
				i=i+1
			end
		end
		return modules
	end

	local function getFunctionsInModule(module)
		local functions = {}
		local i = 1
		for k,v in pairs(graph.edges) do
			if(v.from[1].id == module.id and v.to[1].meta.type == "function" and v.label == "declares") then
				functions[i] = v.to[1]
				i=i+1
			end
		end
		return functions
	end	

	local function getInterfaceFunctionsInModule(module)
		local functions = {}
		local i = 1
		for k,v in pairs(graph.edges) do
			if(v.from[1].id == module.id and v.to[1].meta.type == "interface" and v.label == "provides") then
				functions[i] = v.to[1]
				i=i+1
			end
		end
		return functions
	end	

	local function getVariablesInModule(module)
		local variables = {}
		local i = 1
		for k,v in pairs(graph.edges) do
			if(v.from[1].id == module.id and (v.to[1].meta.type == "local variable" or v.to[1].meta.type == "global variable") and v.label == "initializes") then
				if(not contains(variables, v.to[1].id)) then
					variables[i] = v.to[1]
					i=i+1
				end
			end
		end
		return variables
	end		

	local function getVariablesInFile(file)
		local variables = {}
		local i = 1
		for k,v in pairs(graph.edges) do
			if(v.from[1].id == file.id and (v.to[1].meta.type == "local variable" or v.to[1].meta.type == "global variable")) then
				variables[i] = v.to[1]
				i=i+1
			end
		end
		return variables
	end	

	local function getFunctionsInFile(file)
		local functions = {}
		local i = 1
		for k,v in pairs(graph.edges) do
			if(v.from[1].id == file.id and v.to[1].meta.type == "function") then
				functions[i] = v.to[1]
				i=i+1
			end
		end
		return functions
	end	

	local function getFilesInDirectory(directory)
		local files = {}
		local i = 1
		for k,v in pairs(graph.edges) do
			if(v.from[1].id == directory.id and v.to[1].meta.type == "file" and v.label == "contains") then
				files[i] = v.to[1]
				i = i + 1
			end
		end
		return files
	end

	local function getDirectoriesInDirectory(directory)
		local directories = {}
		local i = 1
		for k,v in pairs(graph.edges) do
			if(v.from[1].id == directory.id and v.to[1].meta.type == "directory" and v.label == "contains") then
				directories[i] = v.to[1]
				i = i + 1
			end
		end
		return directories
	end
	
	local function insertFunctionToInterfaceEdge(functionId, interfaceId)
		local f = City.getNodeById(functionId)		
		local i = City.getNodeById(City.getInterfaceId(interfaceId))

		if(f == nil or i == nil) then
			return nil 
		end

		local edge = {}
		edge.from = {f}
		edge.to = {i}
		edge.color = functionCodeColor
		edge.radius = 2
		edge.type = "cube"
		return edge
	end

	local function insertVariableToInterfaceEdge(variableId, interfaceId)
		local v = City.getNodeById(variableId)
		local i = City.getNodeById(City.getInterfaceId(interfaceId))

		if(v == nil or i == nil) then 
			return nil 
		end

		local edge = {}
		edge.from = {v}
		edge.to = {i}
		edge.color = variableBaseColor
		edge.radius = 2
		edge.type = "cube"
		return edge
	end

	local function insertFunctionToFunctionEdge(f1Id, f2Id)
		local v = City.getNodeById(f1Id)
		local i = City.getNodeById(f2Id)

		if(v == nil or i == nil) then 
			return nil 
		end

		local edge = {}
		edge.from = {v}
		edge.to = {i}
		edge.color = functionBaseColor
		edge.radius = 2
		edge.type = "cube"
		return edge
	end

	--to get id of second interface node (for some reason between module and function are 2 interface nodes)
	local function getInterfaceId(interfaceId)
		for _,v in pairs(graph.edges) do
			if(v.label == "provides" and v.to[1].id == interfaceId) then
				return v.from[1].id
			end
		end
		return nil
	end

	local function getNodeById(id)
		if(id == nil) then
			return nil
		end

		for _,v in pairs(nodesArray) do
			if(v.id == id) then 
				return v 
			end
		end
		return nil
	end

	local function getNodes()
		return nodesArray
	end	

	local function getGraph()
		return graph
	end	
	local function getEdges()
		return edgesArray
	end	
	local function setBuildingHeight(bh)
		buildingHeight = bh
	end	
	local function getBuildingHeight()
		return buildingHeight
	end	
	local function setBuildingPlatformSize(bps)
		buildingPlatformSize = bps
	end	
	local function getBuildingPlatformSize()
		return buildingPlatformSize
	end	

	--getters and setters
	City.getGraph = getGraph
	City.getNodes = getNodes
	City.getEdges = getEdges
	City.setBuildingHeight = setBuildingHeight
	City.getBuildingHeight = getBuildingHeight
	City.setBuildingPlatformSize = setBuildingPlatformSize
	City.getBuildingPlatformSize = getBuildingPlatformSize
	City.getNodeById = getNodeById
	City.getInterfaceId = getInterfaceId

	--main layout function
	City.doLayout = doLayout

	--retrieve functions
	City.getRootDirectory = getRootDirectory
	City.getFunctionsInModule = getFunctionsInModule
	City.getVariablesInModule = getVariablesInModule
	City.getVariablesInFile = getVariablesInFile
	City.getInterfaceFunctionsInModule = getInterfaceFunctionsInModule
	City.getFunctionsInFile = getFunctionsInFile
	City.getModulesInFile = getModulesInFile
	City.getDirectoriesInDirectory = getDirectoriesInDirectory
	City.getFilesInDirectory = getFilesInDirectory

	--init functions
	City.initFileProperties = initFileProperties
	City.initDirectoryProperties = initDirectoryProperties

	--size functions
	City.calculateDirectorySize = calculateDirectorySize
	City.calculateFileSize = calculateFileSize

	--edge functions
	City.insertVariableToInterfaceEdge = insertVariableToInterfaceEdge
	City.insertFunctionToInterfaceEdge = insertFunctionToInterfaceEdge
	City.insertFunctionToFunctionEdge = insertFunctionToFunctionEdge

	City.layoutNodes = layoutNodes
	City.layoutEdges = layoutEdges
	return City
end


return {
	new = city.create
}