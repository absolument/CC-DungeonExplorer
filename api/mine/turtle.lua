--
-- Digging Turtle extension API
-- Digging loops per count or timeout
-- author: SukaiPoppuGo
--
if not turtle then
	error("API mine Turtle only",2)
	return false
end

local super = turtle

--Globals
_G._DIGAPI = true
_G.DIG_MODE_DEFAULT   = "DIG_MODE_DEFAULT"
_G.DIG_MODE_TRIES     = "DIG_MODE_TRIES"
_G.DIG_MODE_TIMEOUT   = "DIG_MODE_TIMEOUT"
_G.DIG_MODE_UNLIMITED = "DIG_MODE_UNLIMITED"
_G.SIDE_UP      = "SIDE_UP"
_G.SIDE_DOWN    = "SIDE_DOWN"
_G.SIDE_FORWARD = "SIDE_FORWARD"
-- Const
local SIDE_UP, SIDE_FORWARD, SIDE_DOWN = 1, 2, 3

--ini
local function _get(name, default) return settings.get("TurtleDig."..name, default) end
local function _set(name, value) settings.set("TurtleDig."..name,value)end
local settingsFile = "/settings/TurtleDig"
local function _save() return settings.save("/settings/TurtleDig") end

--params
_G.digSettings = {
	setMode = function(mode)
		if mode == DIG_MODE_TIMEOUT then
			_set("mode", DIG_MODE_TIMEOUT)
		elseif mode == DIG_MODE_TRIES then
			_set("mode", DIG_MODE_TRIES)
		elseif mode == DIG_MODE_UNLIMITED then
			_set("mode", DIG_MODE_UNLIMITED)
		else
			_set("mode", DIG_MODE_DEFAULT)
		end
		_save()
	end,
	setLimit = function(n)
		_set("limit", math.abs(n))
		_save()
	end,
}

--helper

--utils
local blacklist = { init = false, str = {}, func = {} }
local whitelist = { init = false, str = {}, func = {} }
local function has(tbl, data)
	if tbl.str[data.name] then
		return true
	end
	for _, f in pairs(tbl.func) do
		if f(data) then
			return true
		end
	end
	return false
end


--Main
local function _dig(dir, toolSide)
	toolSide = toolSide or nil
	local _inspect, _superDig = super.inspect, super.dig
	if dir == SIDE_UP then
		_inspect, _superDig = super.inspectUp, super.digUp
	elseif dir == SIDE_DOWN then
		_inspect, _superDig = super.inspectDown, super.digDown
	end
	if blacklist.init or whitelist.init then
		local b, data = _inspect()
		if b and blacklist.init and has(blacklist, datae) then
			return false, "Blacklist: "..data.name
		elseif b and whitelist.init and not has(whitelist, data) then
			return false, "Not whitelisted: "..data.name
		elseif not b then
			return false, "Nothing to dig here"
		end
	end
	local mode = _get("mode", DIG_MODE_DEFAULT)
	local limit = _get("limit", 1)
	local b, msg, count, e, p, timeout, tick, result
	if mode == DIG_MODE_UNLIMITED then
		b = true
		while b do
			b,msg = _superDig(toolSide)
		end
		return b,msg
	elseif mode == DIG_MODE_TRIES then
		if limit > 0 then
			b,count = true, 0
			while b and count < limit do
				b,msg = _superDig(toolSide)
				count = count+1
			end
			return b,msg
		else
			return false, "digSettings.setLimit 0"
		end
	elseif mode == DIG_MODE_TIMEOUT then
		if limit > 0 then
			b,timeout = true, os.clock()+limit
			while b and os.clock() < timeout do
				b,msg = _superDig(toolSide)
			end
			return b,msg
		else
			return false, "digSettings.setLimit 0"
		end
	else
		return _superDig(toolSide)
	end
end

--Append
function dig(toolSide)     return _dig(SIDE_FORWARD, toolSide) end
function digUp(toolSide)   return _dig(SIDE_UP,      toolSide) end
function digDown(toolSide) return _dig(SIDE_DOWN,    toolSide) end

native = super.native
--Moves
turnLeft = super.turnLeft
turnRight = super.turnRight
forward = super.forward
back = super.back
up = super.up
down = super.down
--Tools
attack = super.attack
attackUp = super.attackUp
attackDown = super.attackDown
equipLeft = super.equipLeft
equipRight = super.equipRight
--Block
place = super.place
placeUp = super.placeUp
placeDown = super.placeDown
compare = super.compare
compareUp = super.compareUp
compareDown = super.compareDown
--Items
suck = super.suck
suckUp = super.suckUp
suckDown = super.suckDown
drop = super.drop
dropUp = super.dropUp
dropDown = super.dropDown
--Inventory
select = super.select
getItemSpace = super.getItemSpace
getItemCount = super.getItemCount
getItemDetail = super.getItemDetail
getSelectedSlot = super.getSelectedSlot
transferTo = super.transferTo
compareTo = super.compareTo
--Inspections
inspect = super.inspect
inspectUp = super.inspectUp
inspectDown = super.inspectDown
detect = super.detect
detectUp = super.detectUp
detectDown = super.detectDown
--Fuel
getFuelLimit = super.getFuelLimit
refuel = super.refuel
getFuelLevel = super.getFuelLevel

settings.load(settingsFile)