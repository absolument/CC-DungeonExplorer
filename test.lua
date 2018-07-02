os.loadAPI("/api/utils.lua")
os.loadAPI("/api/inventory.lua")

utils.require_once("/class/Point.lua")
utils.require_once("/class/Way.lua")
utils.require_once("/class/Move.lua")

local SLOT_TORCH = 1
local SLOT_BLOCK = 2
local LIGHT_SPACER = 8

local function hasInventory(name)
	return name and (
		   name == "minecraft:chest"
		or name == "minecraft:trapped_chest"
		or name == "minecraft:dispenser"
		or name == "minecraft:dropper"
		or name == "minecraft:hopper"
		or name == "minecraft:furnace"
		or name == "minecraft:jukebox"
		or name == "ironchest:ironchest"
	)
end

--Preserve loot when digging a block with inventory
local function safeDigUp()
	local b,d = turtle.inspectUp()
	if b and d and d.name and hasInventory(d.name) then
		while turtle.suckUp() do end
		b = turtle.digUp()
		while turtle.suckUp() do end
		return b
	else
		return turtle.digUp()
	end
	return false
end
local function safeDig()
	local b,d = turtle.inspect()
	if b and d and d.name and hasInventory(d.name) then
		while turtle.suck() do end
		b = turtle.dig()
		while turtle.suck() do end
		return b
	else
		return turtle.dig()
	end
	return false
end
local function safeDigDown()
	local b,d = turtle.inspectDown()
	if b and d and d.name and hasInventory(d.name) then
		while turtle.suckDown() do end
		b = turtle.digDown()
		while turtle.suckDown() do end
		return b
	else
		return turtle.digDown()
	end
	return false
end

local function lightSource(name)
	return name and (
		   name == "minecraft:torch"
		or name == "minecraft:glowstone"
		or name == "minecraft:lit_pumpkin"
		or name == "minecraft:lit_redstone_lamp"
		or name == "minecraft:sea_lantern"
		or name == "chisel:glowstone"
		or name == "chisel:glowstone1"
	)
end

-- Place torch every LIGHT_SPACER steps or as next as possible
local forceLight = false
local function light(step)
    if step%LIGHT_SPACER == 0 or forceLight then
        inventory.selectSlot(SLOT_TORCH)
		if not turtle.placeDown() then
			local b,d = turtle.inspectDown()
			forceLight = not (b and d and d.name and lightSource(d.name))
		else
			forceLight = false
		end
    end
end

-- Place torch, setup block under if needed
local function safeLight()
	inventory.selectSlot(SLOT_TORCH)
	if not turtle.placeDown() then
		if turtle.detectDown() then
			if safeDigDown() then
				return safeLight()
			else
				--
				return false
			end
		else
			if turtle.down() then
				if turtle.detectDown() then
					--A block where torch cant stand
					if safeDigDown() then
						inventory.selectSlot(SLOT_BLOCK)
						if turtle.placeDown() then
							turtle.up()
							inventory.selectSlot(SLOT_TORCH)
							return turtle.placeDown()
						else
							--
							return false
						end
					else
						--
						return false
					end
				else
					inventory.selectSlot(SLOT_BLOCK)
					if turtle.placeDown() then
						turtle.up()
						inventory.selectSlot(SLOT_TORCH)
						return turtle.placeDown()
					else
						--
						return false
					end
				end
			else
				--
				return false
			end
		end
	else
		return true
	end
end

local function lightMobSpawner()
	local moveCount = 0
	for i=1,4 do
		if turtle.back() then
			moveCount = moveCount + 1
		end
	end
	safeLight()
	for i=1,moveCount do
		turtle.forward()
	end
	turtle.turnLeft()
	moveCount = 0
	for i=1,4 do
		if turtle.back() then
			moveCount = moveCount + 1
		end
	end
	safeLight()
	for i=1,moveCount do
		turtle.forward()
	end
	moveCount = 0
	for i=1,4 do
		if turtle.forward() then
			moveCount = moveCount + 1
		end
	end
	safeLight()
	for i=1,moveCount do
		turtle.back()
	end
	turtle.turnRight()
	local moveCount = 0
	for i=1,4 do
		if turtle.forward() then
			moveCount = moveCount + 1
		end
	end
	safeLight()
	return moveCount
end

local function attackLoop()
	while turtle.attack() do end
        --local loop = 0
        --while turtle.attack() do
        --    attack = attack+1
        --    turtle.turnLeft()
        --    loop = loop+1
        --end
        --for i=1,loop%4 do
        --    turtle.attack()
        --    turtle.turnRight()
        --end
end

local b, data = turtle.inspect()
local start = false

if b and data and data.name == "minecraft:iron_bars" then
    start = true
end

if start then
	local explore = true
    local step = 0
	local posY = 0
    local attack = 0
    safeDig() --Break iron_bars
    while explore do
		if posY > 0 and turtle.down() then
			posY = posY - 1
		end
		if turtle.detect() then
			b, data = turtle.inspect()
			--Try to preserve cakes
			if utils.compareData(data, {name="minecraft:cake"}) then
				if turtle.up() then
					posY = posY + 1
				else
					safeDig()
				end
			end
		end
		attackLoop()
        
		b, data = turtle.inspectDown()
		if utils.compareData(data, {name="minecraft:mob_spawner"}) then
			step = step + lightMobSpawner()
		end
		if turtle.forward() then
			light(step)
			step = step+1
		end
    end
    b, data = turtle.inspect()
    if b then
        print("steps: "..step)
        print("attacks: "..attack)
        print("stop: "..data.name)
    end
end
    

os.pullEvent("key")
