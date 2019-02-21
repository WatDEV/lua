local colorSetup = {}

function colorSetup:create()
	local colors = {}

	colors.functionCodeColor = {r=255, g=0, b=0}
	colors.functionCommentColor = {r=0, g=120, b=0}
	colors.functionBlankColor = {r=0, g=0, b=0}
	colors.functionBaseColor = {r=200, g=0, b=0}
	
	colors.localVariableColor = {r=236, g=117, b=5}
	colors.globalVariableColor = {r=67, g=127, b=151}
	colors.variableBaseColor = {r=216, g=74, b=5}

	colors.interfaceFunctionsColor = {r=255, g=179, b=15}
	colors.interfaceBaseColor = {r=255, g=179, b=15}

	colors.moduleColor = {r=120, g=0, b=0}
	colors.fileColor = {r=3, g=71, b=50}
	colors.directoryColor = {r=150, g=150, b=150}
	
	--TODO fill corrctly
	colors.statementColors = 
	{
		["FunctionCall"] = {r = 20, g = 0, b = 0},
		["GenericFor"] = {r = 0, g = 0, b = 20},
		["NumericFor"] = {r = 20, g = 0, b = 0},
		["Assign"] = {r = 0, g = 20, b = 0},
		["LocalAssign"] = {r = 0, g = 20, b = 0},
		["keyword"] = {r = 0, g = 20, b = 0},
		["If"] = {r = 20, g = 20, b = 0},
		["LocalFunction"] = {r = 20, g = 0, b = 0},
	}

	return colors
end


return {
	new = colorSetup.create
}