--
-- Position Turtle extension API
-- Keep x,y,z position
-- Update between each movements
-- author: SukaiPoppuGo
--
if not turtle then
	error("API pos Turtle only", 2)
	return false
end

local super = turtle.native or turtle

--Globals
_G._POSAPI = true
_G.NORTH, _G.EAST, _G.SOUTH, _G.WEST = 0, 1, 2, 3
--ini
--helper
local dirs = {"north", "east", "south", "west"}
local deltaX = { [0] =  0, [1] = 1, [2] = 0, [3] = -1 }
local deltaZ = { [0] = -1, [1] = 0, [2] = 1, [3] =  0 }
--Structure
local pos = {
	x = 0, y = 0, z = 0, d = 0,
	dx = 0, -- +X east ; -X west
	dz = 0, -- +Z south ; -Z north
}
local posMetatable = {
	__tostring = function(pos)
		return string.format("Pos={x=%s,y=%s,z=%s,facing=%s}", pos.x, pos.y, pos.z, dirs[pos.d + 1])
	end,
}
setmetatable(pos,posMetatable)

local function _get(name, default) return settings.get("TurtlePos."..name, default) end
local function _set(name, value) settings.set("TurtlePos."..name, value) end
local settingsFile = "/settings/TurtlePos"
local function _load() return settings.load("/settings/TurtlePos") end
local function _save() return settings.save("/settings/TurtlePos") end

local function updateTurn(value)
	pos.d = (pos.d + value) % 4
	pos.dx = deltaX[pos.d]
	pos.dz = deltaZ[pos.d]
	_set("d", pos.d)
	_save()
end
local function updateMove(d)
	d = d and d or 1
	pos.x = pos.x + (pos.dx * d)
	pos.z = pos.z + (pos.dz * d)
	_set("x", pos.x)
	_set("z", pos.z)
	_save()
end

function _G.getPos(b) if b then return pos else return pos.x, pos.y, pos.z, pos.d, pos.dx, pos.dz end end
function _G.getPosX() return pos.x end
function _G.getPosY() return pos.y end
function _G.getPosZ() return pos.z end
function _G.getPosD() return pos.d end
function _G.getPosDX() return pos.dx end
function _G.getPosDZ() return pos.dz end
function _G.setPosX(v) pos.x = v   _set("x",v)     _save() end
function _G.setPosY(v) pos.y = v   _set("y",v)     _save() end
function _G.setPosZ(v) pos.z = v   _set("z",v)     _save() end
function _G.setPosD(v) pos.d = v % 4 _set("d", pos.d) _save() updateTurn(0) end
function _G.setPos(x,y,z,d)
	pos.x, pos.y, pos.z, pos.d = x, y, z, d % 4
	_set("x", pos.x)
	_set("y", pos.y)
	_set("z", pos.z)
	_set("d", pos.d)
	updateTurn(0)
	_save()
end

_G.getAdjacentPos = {}
function getAdjacentPos.forward(b)
	local p = getPos(true)
	if b then return { x = (p.x + p.dx), y = (p.y), z = (p.z + p.dz) } else return p.x + p.dx, p.y, p.z + p.dz end
end
function getAdjacentPos.back(b)
	local p = getPos(true)
	if b then return { x = (p.x - p.dx), y = (p.y), z = (p.z - p.dz) } else return p.x - p.dx, p.y, p.z - p.dz end
end
function getAdjacentPos.up(b)
	local p = getPos(true)
	if b then return { x = p.x, y = p.y + 1, z = p.z } else return p.x, p.y + 1, p.z end
end
function getAdjacentPos.down(b)
	local p = getPos(true)
	if b then return { x = p.x, y = p.y - 1, z = p.z } else return p.x, p.y - 1, p.z end
end
function getAdjacentPos.left(b)
	local p = getPos(true)
	if p.d == NORTH then
		if b then return {p.x - 1, p.y, p.z} else return p.x - 1, p.y, p.z end
	elseif p.d == EAST then
		if b then return {p.x, p.y, p.z - 1} else return p.x, p.y, p.z - 1 end
	elseif p.d == SOUTH then
		if b then return {p.x + 1, p.y, p.z} else return p.x + 1, p.y, p.z end
	elseif p.d == WEST then
		if b then return {p.x, p.y, p.z + 1} else return p.x, p.y, p.z + 1 end
	end
end
function getAdjacentPos.right(b)
	local p = getPos(true)
	if p.d == NORTH then
		if b then return {p.x + 1, p.y, p.z} else return p.x + 1, p.y, p.z end
	elseif p.d == EAST then
		if b then return {p.x, p.y, p.z + 1} else return p.x, p.y, p.z + 1 end
	elseif p.d == SOUTH then
		if b then return {p.x - 1, p.y, p.z} else return p.x - 1, p.y, p.z end
	elseif p.d == WEST then
		if b then return {p.x, p.y, p.z - 1} else return p.x, p.y, p.z - 1 end
	end
end

function turnLeft()
	updateTurn(-1)
	return super.turnLeft()
end

function turnRight()
	updateTurn(1)
	return super.turnRight()
end

function forward()
	local test,err = super.forward()
	if test then updateMove() end
	return test, err
end

function back()
	local test, err = super.back()
	if test then updateMove(-1) end
	return test, err
end

function up()
	local test, err = super.up()
	if test then pos.y = pos.y + 1 end
	_set("y", pos.y)
	return test, err
end

function down()
	local test, err = super.down()
	if test then pos.y = pos.y - 1 end
	_set("y", pos.y)
	return test, err
end

native = super
getSelectedSlot = super.getSelectedSlot
getFuelLimit = super.getFuelLimit
suckUp = super.suckUp
getItemSpace = super.getItemSpace
suckDown = super.suckDown
transferTo = super.transferTo
suck = super.suck
equipLeft = super.equipLeft
equipRight = super.equipRight
refuel = super.refuel
getFuelLevel = super.getFuelLevel
attack = super.attack
attackUp = super.attackUp
attackDown = super.attackDown
getItemDetail = super.getItemDetail
getItemCount = super.getItemCount
compareTo = super.compareTo
drop = super.drop
dropUp = super.dropUp
dropDown = super.dropDown
select = super.select
inspect = super.inspect
inspectUp = super.inspectUp
inspectDown = super.inspectDown
detect = super.detect
detectUp = super.detectUp
detectDown = super.detectDown
place = super.place
placeUp = super.placeUp
placeDown = super.placeDown
compare = super.compare
compareUp = super.compareUp
compareDown = super.compareDown
dig = super.dig
digUp = super.digUp
digDown = super.digDown

--init
_load()
setPos(_get("x", 0), _get("y", 0), _get("z", 0), _get("d", 0))
_set("x", pos.x)
_set("y", pos.y)
_set("z", pos.z)
_set("d", pos.d)
_save()
updateTurn(0) -- dx, dz
