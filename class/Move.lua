--Move
--author: SukaiPoppuGo

if not _POSAPI and not os.loadAPI("/api/pos/turtle.lua") then
	error("Pos API required", 2)
	return
end

if not utils then os.loadAPI("/api/utils.lua") end
utils.require_once("/class/Point.lua")
utils.require_once("/class/Way.lua")

-- shortcuts
_format = string.format
_concat = table.concat

-- Move
-- Movement manager
Move = {}
Move.__index = Move

Move.new = function (self, way)
	local o = {}
	setmetatable(o, Move)
	if utils.isInstanceOf(way, "Way") then
		o.way = way
	else
		error("Move argument must be a Way instance", 2)
		return
	end
	o.axisIterator = 1
	o.axisPriority = {"x", "z", "y"}
	o.running = false
	o.target = nil
	o.state = "Null"
	return o
end

Move.setAxisPriority = function (self, t)
	if type(t) ~= "table" or #t < 3 then
		error("move:setAxisPriority(t)\nMust be a table\nexample: {\"x\",\"z\",\"y\"}", 2)
		return
	end
	self.axisPriority = {}
	for i=1,#t do
		if t[i] == "x" or t[i] == "y" or t[i] == "z" then
			self.axisPriority[i] = t[i]
		else
			error(_format("move:setAxisPriority(t)\n\"%s\" is not a valid axis reference\nexample: {\"x\",\"z\",\"y\"}", t[i]), 2)
			return
		end
	end
end

Move.getAxis = function (self)
	return self.axisPriority[self.axisIterator]
end
Move.nextAxis = function (self)
	self.axisIterator = (self.axisIterator % #self.axisPriority) + 1
end

Move.step = function (self)
	local tCurrent = getPos(true)
	self.running, self.target, self.state = self.way:getWaypoint(tCurrent)
	if self.running then
		if self.state == "Next" then
			self:nextAxis()
		end
		local sAxis,count = self:getAxis(), 0
		while count < 3 and tCurrent[sAxis] == self.target[sAxis] do
			self:nextAxis()
			sAxis = self:getAxis()
			count = count + 1
		end
		if sAxis == "y" then
			if tCurrent.y > self.target.y then
				self.running = turtle.down()
			elseif tCurrent.y < self.target.y then
				self.running = turtle.up()
			end
		elseif sAxis == "x" then
			if tCurrent.x < self.target.x then --> +X East
				if tCurrent.d == NORTH then
					turtle.turnRight()
				elseif tCurrent.d == WEST then
					turtle.turnRight() turtle.turnRight()
				elseif tCurrent.d == SOUTH then
					turtle.turnLeft()
				end
				self.running = turtle.forward()
			elseif tCurrent.x > self.target.x then --> -X West
				if tCurrent.d == NORTH then
					turtle.turnLeft()
				elseif tCurrent.d == EAST then
					turtle.turnRight() turtle.turnRight()
				elseif tCurrent.d == SOUTH then
					turtle.turnRight()
				end
				self.running = turtle.forward()
			end
		elseif sAxis == "z" then
			if tCurrent.z < self.target.z then --> +Z South
				if tCurrent.d == EAST then
					turtle.turnRight()
				elseif tCurrent.d == NORTH then
					turtle.turnRight() turtle.turnRight()
				elseif tCurrent.d == WEST then
					turtle.turnLeft()
				end
				self.running = turtle.forward()
			elseif tCurrent.z > self.target.z then --> -Z North
				if tCurrent.d == EAST then
					turtle.turnLeft()
				elseif tCurrent.d == SOUTH then
					turtle.turnRight() turtle.turnRight()
				elseif tCurrent.d == WEST then
					turtle.turnRight()
				end
				self.running = turtle.forward()
			end
		end
	end
	if not self.running and self.state == "Continue" then
		self:nextAxis()
	end
	return self.running, self.target, self.state
end


