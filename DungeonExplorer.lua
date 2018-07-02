--TestMove
--author: SukaiPoppuGo

local tArgs = {...}

--
local programName = fs.getName( shell.getRunningProgram() )
settings.load("/settings/"..programName)

os.loadAPI("/api/pos/turtle.lua")
os.loadAPI("/api/utils.lua")
os.loadAPI("/api/ui.lua")

--os.loadAPI("move")
utils.require_once("/class/Point.lua")
utils.require_once("/class/Way.lua")
utils.require_once("/class/Move.lua")

local screenW, screenH = term.getSize()
local dirs = {"north", "east", "south", "west"}
local MENU_EDITPOS = 1
local MENU_DRIVE = 2
local MENU_FUELLEVEL = 3
local MENU_INVENTORY = 4
local MENU_SETTARGET = 5
local MENU_EXIT = 6
local MENU_DISTANCE = 7
local MENU_GOTO = 8

if not os.getComputerLabel() then
	shell.run("label set turtle_"..os.getComputerID())
end

local function header()
	ui.output(os.getComputerLabel().."#"..os.getComputerID(), 1)
	ui.output(getPos(true), 2)
end

local tMenu = {}
local function _exit() return false end


-- Custom keys
local _myKeysIndex = {"up", "down", "left", "right", "pageUp", "pageDown"}
local myKeys = {
	up       = settings.get(programName..".keys.up"      , keys.up      ),
	down     = settings.get(programName..".keys.down"    , keys.down    ),
	left     = settings.get(programName..".keys.left"    , keys.left    ),
	right    = settings.get(programName..".keys.right"   , keys.right   ),
	pageUp   = settings.get(programName..".keys.pageUp"  , keys.pageUp  ),
	pageDown = settings.get(programName..".keys.pageDown", keys.pageDown),
}

-- ----
-- Help
-- ----
if #tArgs and tArgs[1] == "help" then
	print(string.format("Usage:\n%s [opt]\n  help   Display this help\n  config Edit keys config\n", programName))
	return
-- -----------
-- Keys config
-- -----------
elseif #tArgs and tArgs[1] == "config" then
	local tmp = os.startTimer(0.2)
	while true do
		local e, p = os.pullEvent()
		if e == "key_up" or e == "timer" then
			break
		end
	end
	local keyMap = {}
	for _,name in ipairs(_myKeysIndex) do
		table.insert(keyMap, name.." : "..keys.getName(myKeys[name]))
	end
	while true do
		term.clear()
		ui.output("> "..programName.." config", 1)
		ui.output("Controls :", 2)
		term.setCursorPos(2, 3)
		ui.box(keyMap)
		ui.output("Press [E] to edit", #keyMap + 5)
		ui.output("Press [Enter] to confirm", #keyMap + 6)
		local e, p = os.pullEvent("key_up")
		if p == keys.enter then
			for name,v in pairs(myKeys) do
				settings.set(programName..".keys."..name, v)
			end
			settings.save("/settings/"..programName)
			print("Config saved")
			return
		elseif p == keys.e then
			--Edit
			keyMap = {}
			for _,name in ipairs(_myKeysIndex) do
				term.clear()
				ui.output("> "..programName.." config", 1)
				ui.output("Controls :", 2)
				term.setCursorPos(2, 3)
				ui.box({
					"Press "..name.." key",
				})
				sleep(0.2)
				local e, p = os.pullEvent("key_up")
				term.setCursorPos(2, 3)
				ui.box({
					"Set "..name.." key to "..keys.getName(p),
				})
				table.insert(keyMap, name.." : "..keys.getName(p))
				myKeys[name] = p
				sleep(0.8)
			end
		end
	end
end

local function editPos()
	local p = getPos(true)
	term.clear()
	header()
	term.setCursorPos(2, 3)
	ui.box({
		"Edit positions:",
		"X:"..p.x,
		"Y:"..p.y,
		"Z:"..p.z,
		"facing:"..dirs[p.d+1],
	})
	local i, input, str = 1, {p.x, p.y, p.z, p.d}
	term.setCursorBlink(true)
	term.setCursorPos(string.len(tostring(input[i])) + 5, i + 4)
	while true do
		local e, param = os.pullEvent()
		--Confirm
		if e == "key_up" and param == keys.enter and string.len(tostring(input[i])) > 0 then
			input[i] = tonumber(input[i])
			if i == 4 then break else i = i+1 end
		--Suppr
		elseif e == "key" and param == keys.backspace then
			str = tostring(input[i])
			input[i] =(string.len(str) > 1) and string.sub(str, 0, math.max(0, string.len(str)-1)) or ""
		--Edit facing value
		elseif  i == 4 and e == "key" and param == keys.n then
			input[4] = 0
		elseif  i == 4 and e == "key" and param == keys.e then
			input[4] = 1
		elseif  i == 4 and e == "key" and param == keys.s then
			input[4] = 2
		elseif  i == 4 and e == "key" and param == keys.w then
			input[4] = 3
		elseif  i == 4 and e == "key" and param == myKeys.up then
			input[4] = (input[4] ~= 0) and 0 or 2
		elseif  i == 4 and e == "key" and param == myKeys.right then
			input[4] = (input[4] ~= 1) and 1 or 3
		elseif  i == 4 and e == "key" and param == myKeys.down then
			input[4] = (input[4] ~= 2) and 2 or 0
		elseif  i == 4 and e == "key" and param == myKeys.left then
			input[4] = (input[4] ~= 3) and 3 or 1
		--Edit number value
		elseif i <= 3 and e == "char" and param == "-" then
			input[i] = (i ~= 2) and math.abs(tonumber(input[i])) * -1 or math.abs(tonumber(input[i]))
		elseif i <= 3 and e == "char" and param == "+" then
			input[i] = math.abs(tonumber(input[i]))
		elseif i <= 3 and e == "char" and tonumber(param) then
			str = tostring(input[i])
			input[i] = str..param
		end
		term.setCursorPos(2, 3)
		ui.box({
			"Edit positions:",
			"X:"..input[1],
			"Y:"..input[2],
			"Z:"..input[3],
			"facing:"..dirs[input[4]+1],
		})
		term.setCursorPos(i == 4 and 9 or string.len(tostring(input[i]))+5, i+4)
		term.setCursorBlink(true)
	end
	term.setCursorBlink(false)
	sleep(0.2)
	setPos(input[1], input[2], input[3], input[4])
	term.clear()
	return true
end

local function fuelLevel()
	local percent = math.round(turtle.getFuelLevel() * 1000 / turtle.getFuelLimit()) / 10
	term.clear()
	header()
	term.setCursorPos(2, 3)
	ui.box({
		"Fuel level: "..turtle.getFuelLevel(),
		"Fuel limit: "..turtle.getFuelLimit(),
		"Fuel tank: "..percent.."%",
	})
	ui.outputEndScreen("-Press any Key-")
	ui.waitPressAnyKey()
	ui.outputEndScreen(" ")
	--Exit
	return true
end

target = false
local function setTarget()
	local p = target and target or getPos(true)
	term.clear()
	header()
	term.setCursorPos(2, 3)
	ui.box({
		"Set target:",
		"X:"..p.x,
		"Y:"..p.y,
		"Z:"..p.z,
	})
	local i, input, str = 1, {p.x, p.y, p.z, p.d}
	term.setCursorBlink(true)
	term.setCursorPos(string.len(tostring(input[i])) + 5, i + 4)
	while true do
		local e, param = os.pullEvent()
		if e == "key_up" and param == keys.enter and string.len(tostring(input[i])) > 0 then
			input[i] = tonumber(input[i])
			if i == 3 then
				break
			else
				i = i+1
			end
		elseif e == "key" and param == keys.backspace then
			str = tostring(input[i])
			input[i] = (string.len(str) > 1) and string.sub(str, 0, math.max(0, string.len(str) - 1)) or ""
		elseif e == "char" and param == "-" then
			input[i] = (i ~= 2) and math.abs(tonumber(input[i])) * -1 or math.abs(tonumber(input[i]))
		elseif e == "char" and param == "+"  then
			input[i] = math.abs(tonumber(input[i]))
		elseif e == "char" and tonumber(param) then
			str = tostring(input[i])
			input[i] = str..param
		end
		term.setCursorPos(2, 3)
		ui.box({
			"Set target:",
			"X:"..input[1],
			"Y:"..input[2],
			"Z:"..input[3],
		})
		term.setCursorPos(string.len(tostring(input[i])) + 5, i + 4)
		term.setCursorBlink(true)
	end
	term.setCursorBlink(false)
	sleep(0.2)
	target = {}
	target.x = tonumber(input[1])
	target.y = tonumber(input[2])
	target.z = tonumber(input[3])
	
	tMenu[7] = 	{
		id = MENU_EXIT,
		name = "exit",
		action = _exit
	}
	
	tMenu[6] = {
		id = MENU_GOTO,
		name = string.format("Go to X:%s,Y:%s,Z:%s", target.x, target.y, target.z),
		action = function()
			term.clear()
			header()
			ui.output(string.format("Go  X:%s,Y:%s,Z:%s", target.x, target.y, target.z), 3)
			ui.output(" ", 4)
			local A = Point:new(getPos())
			local B = Point:new(target.x, target.y, target.z)
			local toB = Way:new(B)
			local trip = Move:new(toB)
			local count = 0
			while true do
				count = count+1
				local bRun, tTarget, sState = trip:step()
				term.setCursorPos(2,4)
				ui.box({
					"Loop: "..count,
					"bRun: "..tostring(bRun),
					"tTarget: "..tostring(tTarget),
					"sState: "..tostring(sState),
					"axisIterator:"..trip.axisIterator,
				})
				if sState == "Goal" then
					ui.outputEndScreen("-Press any key-")
					ui.waitPressAnyKey()
					ui.outputEndScreen(" ")
					target = A
					tMenu[6].name = string.format("Go to X:%s,Y:%s,Z:%s", target.x, target.y, target.z)
					return true
				end
				ui.outputEndScreen("-Continue: Enter ; Stop: S-")
				local e, p = os.pullEvent("key")
				while true do
					if p == keys.enter then
						break
					elseif p == keys.s then
						ui.outputEndScreen("-Move aborted-")
						sleep(.5)
						return true
					end
				end
			end
			return false
		end,
	}
	
	tMenu[5] = {
		id = MENU_DISTANCE,
		name = "distance",
		action = function()
			local distance = math.round(utils.distance(p, target) * 100) / 100
			local fuelCost = utils.fuelCost(p, target)
			local percent = math.ceil(fuelCost * 1000 / turtle.getFuelLevel()) / 10
			term.clear()
			header()
			term.setCursorPos(2, 3)
			ui.box({
				string.format("To X:%s,Y:%s,Z:%s", target.x, target.y, target.z),
				string.format("Distance = %s", distance),
				string.format("Fuel cost = %s (%s)", fuelCost, percent.."%"),
			})
			ui.outputEndScreen("-Press any Key-")
			ui.waitPressAnyKey()
			ui.outputEndScreen(" ")
			--Exit			
			return true
		end,
	}
	term.clear()
	return true
end

local function inventoryDetail(selection)
	local padX, padY = 1, 7
	local item = turtle.getItemDetail(selection + 1)
	term.setCursorPos(padX, padY)
	term.clearLine()
	if item then term.write(item.count.."x"..item.name) end
	term.setCursorPos(padX, padY + 1)
	term.clearLine()
	if item and item.damage ~= nil then
		term.write("damage: "..item.damage)
	end
end

local function inventoryMenu(selection, action)
	local padX, padY, _ = 8, 3, string.char(149)
	term.setCursorPos(padX, padY)
	ui.btn("Suck", action == 1)
	term.setCursorPos(padX, padY + 1)
	ui.btn("Drop", action == 2)
	term.setCursorPos(padX, padY + 2)
	ui.btn("Move", action == 3)
	if action == 3 then
		local selectedSlot = turtle.getSelectedSlot()
		local destinationSlot = selectedSlot == selection + 1 and "?" or selection
		term.write(string.format(" (Slot %s to %s)", selectedSlot, destinationSlot))
	else
		term.write(string.rep(" ", screenW))
	end
	term.setCursorPos(padX, padY + 3)
	ui.btn("Exit", action == 4)
end

local inventoryAction = 0
local function cap(n) return math.max(0, math.min(15, n)) end
local function inventoryMgr()
	term.clear()
	header()
	local selection = turtle.getSelectedSlot()-1
	while true do
		inventoryDetail(selection)
		ui.drawTurtleInventory(selection)
		inventoryMenu(selection, inventoryAction)
		local e, p, p2 = os.pullEvent()
		if e == "key" and p == myKeys.up then
			selection = cap(math.max(selection%4 , selection - 4))
		elseif e == "key" and  p == myKeys.down then
			selection = cap(math.min(selection%4 + 12, selection + 4))
		elseif e == "key" and  p == myKeys.left then
			selection = cap(selection - 1)
		elseif e == "key" and  p == myKeys.right then
			selection = cap(selection + 1)
		elseif e == "key" and  p == keys.s then --Suck
			inventoryAction = (inventoryAction == 1) and 0 or 1
		elseif e == "key" and  p == keys.d then --Drop
			inventoryAction = (inventoryAction == 2) and 0 or 2
		elseif e == "key" and  p == keys.m then --Move
			inventoryAction = (inventoryAction == 3) and 0 or 3
		elseif e == "key" and p == keys.enter then
			if inventoryAction == 1 then
				local qty = p2 and 64 or 1
				if turtle.suck(qty) or turtle.suckUp(qty) or turtle.suckDown(qty) then end
			elseif inventoryAction == 2 then
				turtle.select(selection + 1)
				local qty = p2 and 64 or 1
				if turtle.drop(qty) or turtle.dropUp(qty) or turtle.dropDown(qty) then end
			elseif inventoryAction == 3 then
				local selectedSlot = turtle.getSelectedSlot()
				if selectedSlot ~= selection + 1 then
					local qty = p2 and 64 or 1
					turtle.transferTo(selection + 1, qty)
				end
			else
				turtle.select(selection + 1)
			end
		elseif e == "key" and  p == keys.e then
			selection, inventoryAction = 0, 0
			inventoryMenu(selection, 4)
			sleep(0.2)
			return true --Exit inventoryMgr
		end
	end
end

local pathChars = {
	yUp = string.char(30),
	yDown = string.char(31),
	up = string.char(24),
	right = string.char(26),
	down = string.char(25),
	left = string.char(27),
}
local rMoves = {
	[0] = {
		up = {turtle.forward},
		right = {turtle.turnRight, turtle.forward},
		down = {turtle.turnRight, turtle.turnRight, turtle.forward},
		left = {turtle.turnLeft, turtle.forward},
	},
	[1] = {
		right = {turtle.forward},
		down = {turtle.turnRight, turtle.forward},
		left = {turtle.turnRight, turtle.turnRight, turtle.forward},
		up = {turtle.turnLeft, turtle.forward},
	},
	[2] = {
		down = {turtle.forward},
		left = {turtle.turnRight, turtle.forward},
		up = {turtle.turnRight, turtle.turnRight, turtle.forward},
		right = {turtle.turnLeft, turtle.forward},
	},
	[3] = {
		left = {turtle.forward},
		up = {turtle.turnRight, turtle.forward},
		right = {turtle.turnRight, turtle.turnRight, turtle.forward},
		down = {turtle.turnLeft, turtle.forward},
	},
}
local rMovesCode = {
	[0] = {
		up = {"forward"},
		right = {"turnRight","forward"},
		down = {"turnRight","turnRight","forward"},
		left = {"turnLeft","forward"},
	},
	[1] = {
		right = {"forward"},
		down = {"turnRight","forward"},
		left = {"turnRight","turnRight","forward"},
		up = {"turnLeft","forward"},
	},
	[2] = {
		down = {"forward"},
		left = {"turnRight","forward"},
		up = {"turnRight","turnRight","forward"},
		right = {"turnLeft","forward"},
	},
	[3] = {
		left = {"forward"},
		up = {"turnRight","forward"},
		right = {"turnRight","turnRight","forward"},
		down = {"turnLeft","forward"},
	},
}

local function readPath(buffer,dir)
	local b, temp = 0
	term.setCursorPos(1,6)
	term.clearLine()
	for i,p in pairs(buffer) do
		b = true
		if p == keys.up then
			for _,f in pairs(rMoves[dir].up) do
				temp = f()
				b = not b and false or temp 
			end
			term.blit(pathChars.up, b and "0" or "f", b and "f" or "7")
			dir = 0
		elseif p == keys.right then
			for _,f in pairs(rMoves[dir].right) do
				temp = f()
				b = not b and false or temp
			end
			term.blit(pathChars.right, b and "0" or "f", b and "f" or "7")
			dir = 1
		elseif p == keys.down then
			for _,f in pairs(rMoves[dir].down) do
				temp = f()
				b = not b and false or temp
			end
			term.blit(pathChars.down, b and "0" or "f", b and "f" or "7")
			dir = 2
		elseif p == keys.left then
			for _,f in pairs(rMoves[dir].left) do
				temp = f()
				b = not b and false or temp
			end
			term.blit(pathChars.left, b and "0" or "f", b and "f" or "7")
			dir = 3
		elseif p == keys.pageUp then
			temp = turtle.up()
			b = not b and false or temp
			term.blit(pathChars.yUp, b and "0" or "f", b and "f" or "7")
		elseif p == keys.pageDown then
			temp = turtle.down()
			b = not b and false or temp
			term.blit(pathChars.yDown, b and "0" or "f", b and "f" or "7")
		end
		local x,y = term.getCursorPos()
		if x >= screenW then
			x = 1
			y = y + 1
		end
		if y > screenH then
			term.scroll(1)
			y = screenH - 1
		end
		term.setCursorPos(x,y)
	end
	return dir
end

local function recordPath(buffer, path)
	local str = ""
	while true do
		ui.output("Count: "..#buffer, 5)
		str = ui.screenCutString(path)
		ui.output(str, 6)
		term.setCursorPos(math.max(1, string.len(str)+1), 6)
		term.setCursorBlink(true)
		local e, p = os.pullEvent("key")
		if p == keys.enter then
			term.setCursorBlink(false)
			term.setCursorPos(2, 4)
			ui.btn("Record", true)
			return buffer, path
		elseif p == keys.backspace then
			path = string.sub(path, 0, math.max(0,string.len(path)-1))
			table.remove(buffer)
		elseif p == myKeys.up then
			path = path..pathChars.up
			table.insert(buffer, keys.up)
		elseif p == myKeys.right then
			path = path..pathChars.right
			table.insert(buffer, keys.right)
		elseif p == myKeys.down then
			path = path..pathChars.down
			table.insert(buffer, keys.down)
		elseif p == myKeys.left then
			path = path..pathChars.left
			table.insert(buffer, keys.left)
		elseif p == myKeys.pageUp then
			path = path..pathChars.yUp
			table.insert(buffer, keys.pageUp)
		elseif p == myKeys.pageDown then
			path = path..pathChars.yDown
			table.insert(buffer, keys.pageDown)
		end
	end
end

local function compile(filename,buffer,dir)
	local source = string.format("--Path generator: %s\n\n--Correct facing:\n--turtle.turnLeft()\n--turtle.turnRight()\n--turtle.turnRight()\n\n-- fuelCost = %s\n-- Path\n", programName, #buffer )
	local tbl = {}
	for i,p in pairs(buffer) do
		if p == keys.up then
			tbl = rMovesCode[dir].up
			dir = 0
		elseif p == keys.right then
			tbl = rMovesCode[dir].right
			dir = 1
		elseif p == keys.down then
			tbl = rMovesCode[dir].down
			dir = 2
		elseif p == keys.left then
			tbl = rMovesCode[dir].left
			dir = 3
		elseif p == keys.pageUp then
			tbl = {"up"}
		elseif p == keys.pageDown then
			tbl = {"down"}
		end
		source = source.."turtle."..table.concat(tbl, "()\nturtle.").."()\n"
	end
	return source
end

local function savePath(buffer, dir)
	sleep(.1)
	local filename = ""
	term.setCursorBlink(true)
	local filename = ui.inputFilename("Filename: ", 6, "")
	term.setCursorBlink(false)
	ui.output("Compile path", 7)
	local source = compile(filename, buffer, dir)
	local file = fs.open(filename, "w")
	ui.output("Write path", 7)
	file.write(source)
	ui.output("Save path", 7)
	file.close()
	ui.output("Saved: "..filename, 6)
	sleep(.2)
end

local function driveMgr(e, p, p2)
	if e=="key" then
		if p == myKeys.up then
			os.pullEvent("key_up") --Clears key event
			turtle.forward()
			return true
		elseif p == myKeys.down then
			os.pullEvent("key_up")
			turtle.back()
			return true
		elseif p == myKeys.left then
			os.pullEvent("key_up")
			turtle.turnLeft()
			return true
		elseif p == myKeys.right then
			os.pullEvent("key_up")
			turtle.turnRight()
			return true
		elseif p == myKeys.pageUp then
			os.pullEvent("key_up")
			turtle.up()
			return true
		elseif p == myKeys.pageDown then
			os.pullEvent("key_up")
			turtle.down()
			return true
		end
	end
	return false
end

local function drive()
	local fuelLimit = turtle.getFuelLimit()
	local path, buffer, dir = "", {}, 0
	while true do
		local fuelLevel = turtle.getFuelLevel()
		term.clear()
		header()
		ui.output(string.format("Fuel %s", fuelLevel < 100 and ": "..fuelLevel or "tank: "..(math.round(fuelLevel * 1000 / fuelLimit) / 10).."%"), 3)
		term.setCursorPos(2, 4)
		ui.btn("Help", false)
		ui.btn("Record", false)
		if #buffer > 0 then
			ui.btn("Play", false)
			ui.btn("Save", false)
		end
		ui.btn("Exit", false)
		ui.output("Count: "..string.len(path), 5)
		ui.output(ui.screenCutString(path), 6)
		local e, p, p2 = os.pullEvent()
		if driveMgr(e, p, p2) then
			--nothing else
		elseif e == "key" and p == keys.r then
			term.setCursorPos(8, 4)
			ui.btn("Record", true)
			buffer, path = recordPath(buffer, path)
		elseif e ==	"key_up" and p == keys.h then
			term.setCursorPos(2, 4)
			ui.btn("Help", true)
			term.setCursorPos(2, 5)
			ui.box({
				string.char(24).." Move forward",
				string.char(25).." Move back",
				string.char(27)..string.char(26).." Turn left/right",
				"pageUp Move up",
				"pageDown Move down",
			})
			ui.outputEndScreen("-Press any Key-")
			ui.waitPressAnyKey()
			ui.outputEndScreen(" ")
		elseif e == "key" and p == keys.p then
			term.setCursorPos(16, 4)
			ui.btn("Play", true)
			dir = readPath(buffer, dir)
		elseif e == "key" and p == keys.s then
			term.setCursorPos(22, 4)
			ui.btn("Save", true)
			savePath(buffer, dir)
			ui.outputEndScreen("-Press any Key-")
			ui.waitPressAnyKey()
			ui.outputEndScreen(" ")
		elseif e == "key" and p == keys.e then
			term.setCursorPos(2, 4)
			ui.btn("Help", false)
			ui.btn("Record", false)
			if #buffer > 0 then
				ui.btn("Play", false)
				ui.btn("Save", false)
			end
			ui.btn("Exit", true)
			sleep(0.2)
			--Exit
			break
		end
	end
	return true
end

tMenu = {
	{
		id = MENU_EDITPOS,
		name = "editPos",
		action = editPos,
	},
	{
		id = MENU_DRIVE,
		name = "drive",
		action = drive,
	},
	{
		id = MENU_FUELLEVEL,
		name = "fuelLevel",
		action = fuelLevel,
	},
	{
		id = MENU_INVENTORY,
		name = "inventory",
		action = inventoryMgr,
	},
	{
		id = MENU_SETTARGET,
		name = "setTarget",
		action = setTarget,
	},
	{
		id = MENU_EXIT,
		name = "exit",
		action = _exit,
	}
}

local function mainMenu(selection)
	selection = selection or 1
	for i=1, #tMenu do
		local enabled = selection == i
		term.setCursorPos(2, i + 2)
		term.clearLine()
		ui.btn(string.sub((enabled and ">" or " ")..tMenu[i].name..string.rep(" ", screenW), 0, 30), enabled)
	end
end

local init = false
local continue = true
local selection = 1
while continue do
	term.clear()
	header()
	mainMenu(selection)
	local e, p = os.pullEvent()
	if e == "key" then init = true end
	if e == "key" and p == myKeys.up then
		selection = (selection - 2) % #tMenu + 1
		mainMenu(selection)
	elseif e == "key" and p == myKeys.down then
		selection = selection % #tMenu + 1
		mainMenu(selection)
	elseif init and e == "key_up" and p == keys.enter then
		continue = tMenu[selection].action()
	--Reset target
	elseif init and tMenu[selection].id == MENU_GOTO and e == "key_up" and p == keys.backspace then
		setTarget()
	--Add waypoints
	elseif init and tMenu[selection].id == MENU_GOTO and e == "char" and p == "+" then
		--
	end
end
-- if target and #target > 0 then
-- 	print("...")
-- 	read()
-- end
print("Terminated")
sleep(.2)