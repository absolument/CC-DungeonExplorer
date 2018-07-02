--MobSpawner room builder
os.loadAPI("move.lua")

local MOB_SPAWNER = "minecraft:mob_spawner"

local function testBlock(name, data)
	return data and data.name and data.name == name
end

local function scan()
	return turtle.inspect(), turtle.inspectUp(), turtle.inspectDown()
end

while true do
	local event, key, isHeld = os.pullEvent("key")
	if key == keys.up then
		
	