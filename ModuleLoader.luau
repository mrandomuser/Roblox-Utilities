-- Module loader

-- Initialise
for _, mod in pairs(script:GetDescendants()) do
	if not mod:IsA("ModuleScript") then
		continue
	end

	mod = require(mod)

	if not mod.Init then
		continue
	end

	xpcall(mod.Init, function(err)
		warn(`Error: {err}\n\nTraceback:\n{debug.traceback()}`)
	end)
end

-- Start
for _, mod in pairs(script:GetDescendants()) do
	if not mod:IsA("ModuleScript") then
		continue
	end

	mod = require(mod)

	if not mod.Start then
		continue
	end

	task.spawn(function()
		xpcall(mod.Start, function(err)
			warn(`Error: {err}\n\nTraceback:\n{debug.traceback()}`)
		end)
	end)
end
