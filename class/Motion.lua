--Motion
--Turtle movement manager class
--author: SukaiPoppuGo

--Global
_G.SIDE_FORWARD = "SIDE_FORWARD"
_G.SIDE_DOWN    = "SIDE_DOWN"
_G.SIDE_UP      = "SIDE_UP"
_G.SIDE_NONE    = "SIDE_NONE"

--Const
local MOTION = "MOTION"
local POINT  = "POINT"

--Check types
local function _isType(o,_type) return (o and o.type) and o.type == _type or false end
local function _isMotion(o) return _isType(o, MOTION) end
local function _isPoint(o) return _isType(o, POINT) end

Motion = {
	position = {
		current = {}, --Up to date position of turtle
		start = {},   --First keypoint of travel
		target = false,  --Next keypoint
		goal = {},    --Last keypoint (goal destination)
	},
	axis = "xyz",
	fuelLevel = 0, --Fuel level after the last step
	state = "Stop",
	lastMove = SIDE_NONE,
}
Motion.__index = Motion

Motion.new = function ()
	--if not _isMotion(self) then error("Argument error: obj:new()", 2) end
	local o = {}
	setmetatable(o, Motion)
	o.type = MOTION
	o.way = {} --List of keypoints
	o.position.current = Point:new(getPos())
	o.position.start = {}
	o.position.goal	= {}
	o.log = "init"
	o.bInit = false
	--o.fuelLevel = turtle.getFuelLevel()
	return o
end

-- init
-- Initialize keypoints
Motion.init = function(self)
	if #self.way > 0 then
		self.state = "Init"
		self.position.start = self.way[1]
		self.position.goal = self.way[#self.way]
		self.position.target = table.remove(self.way, 1)
		self.bInit = true
	end
end

-- addWaypoint
-- Insert waypoint then init (start, target and goal keypoints)
-- @param (Point)
Motion.addWaypoint = function(self, ...)
	local w = {...}
	--local self = table.remove(w, 1)
	if not _isMotion(self) then error(string.format("Argument error: obj:addWaypoint( Point, ... )\ntype: %s", self.type or type(self)), 2) end
	for k, point in pairs( w ) do
		if not _isPoint(point) then error("Argument #"..k.." error: obj:addWaypoint( Point, ... )\nExpect "..POINT.." type, Found "..(point.type or type(point)), 2) end
		table.insert(self.way, point)
	end
	self:init()
end

-- farest
-- Project from target point, a keypoint on each axis as :
-- -keypoint to reach X coordinate
-- -keypoint to reach Y coordinate
-- -keypoint to reach Z coordinate
-- returns: (table) keypoints ordered by longest distance
Motion.farest = function(self)
	if not _isMotion(self) then error("Argument error: obj:farest()", 2)
	elseif not self.position.target then error("Error: obj:farest() self.position.target not set yet", 2) end
	local xLen = math.abs(self.position.current.x - self.position.target.x)
	local yLen = math.abs(self.position.current.y - self.position.target.y)
	local zLen = math.abs(self.position.current.z - self.position.target.z)
	local temp = {}
	table.insert(temp, xLen, Point:new(self.position.target.x, self.position.current.y, self.position.current.z) )
	table.insert(temp, zLen, Point:new(self.position.current.x, self.position.current.y, self.position.target.z) )
	table.insert(temp, yLen, Point:new(self.position.current.x, self.position.target.y, self.position.current.z) )
	utils.keySort( temp )
	return temp
end

-- facedir
-- Turns to facing ref direction
-- @param: (int) dir --Direction 0-3 as NORTH, EAST, SOUTH, WEST
-- return: true
Motion.facedir = function(self, dir)
	if not _isMotion(self) then error("Argument error: obj:facedir( Number )", 2) end
	local d = getPosD()
	if d ~= dir then
		if (d - 1) % 4 == dir then
			return turtle.turnLeft()
		elseif (d + 2) % 4 == dir then
			turtle.turnRight()
		end
		turtle.turnRight()
	end
	return true
end

-- align
-- Try to align to reduce
-- return: (function) move or false
Motion.align = function(self, point)
	if not _isMotion(self) or not _isPoint(point) then error("Argument error: obj:align( Point )", 2) end
	    if self.position.current.z > point.z then self:facedir(NORTH) self.lastDir = SIDE_FORWARD return turtle.forward
	elseif self.position.current.x < point.x then self:facedir(EAST)  self.lastDir = SIDE_FORWARD return turtle.forward
	elseif self.position.current.z < point.z then self:facedir(SOUTH) self.lastDir = SIDE_FORWARD return turtle.forward
	elseif self.position.current.x > point.x then self:facedir(WEST)  self.lastDir = SIDE_FORWARD return turtle.forward
	elseif self.position.current.y > point.y then self.lastDir = SIDE_DOWN return turtle.down
	elseif self.position.current.y < point.y then self.lastDir = SIDE_UP   return turtle.up
	end
	return false
end

-- step
-- Execute 1 move to next destination
-- @param (function) fBefore  -- function executed Before align
-- @param (function) fBetween -- function executed After each align tries before moving (could be executed 1, 2 or 3 times if moving fail)
-- @param (function) fAfter   -- function executed After moving
-- returns: (bool) continue, (mixed) fBefore return, (mixed) fBetween return, (mixed) fAfter return
Motion.step = function(self, fBefore, fBetween, fAfter)
	if not _isMotion(self) then error("Argument error: obj:step()", 2) end
	if not self.bInit then error("Waypoints must be initialized", 2) end
	fBefore  = type(fBefore)  == "function" and fbefore  or false --To execute Before align
	fBetween = type(fBetween) == "function" and fBetween or false --To execute Between align and moving
	fAfter   = type(fAfter)   == "function" and fAfter   or false --To execute After moving
	local rBefore, rBetween, rAfter
	self.position.current = Point:new(getPos())
	
	if #self.way == 0 and self.position.current == self.position.goal then
		self.state = "Goal"
		self.log = "0 to "..tostring(self.position.goal)
		return false, self.state
	elseif self.position.current == self.position.target then
		--Next keypoint
		self.state = "Next keypoint"
		self.position.target = table.remove(self.way, 1)
	end
	
	--priority to farest coord
	local temp = self:farest()
	if not temp then return false, "Empty" end
	self.state = "Moving"
	if type(fBefore) == "function" then rBefore = fBefore() end
	for length, point in pairs(temp) do
		self.log = length.." to "..tostring(point)
		local f = self:align(point)
		if type(fBetween) == "function" then rBetween = fBetween() end
		if f and f() then
			--self.fuelLevel = turtle.getFuelLevel()
			self.state = "Success"
			if type(fAfter) == "function" then rAfter = fAfter() end
			return true, rBefore, rBetween, rAfter
		end
	end
	--fails for each direction
	self.state = "Fail"
	if type(fAfter) == "function" then rAfter = fAfter() end
	return false, rBefore, rBetween, rAfter
end