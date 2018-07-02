--Way
--author: SukaiPoppuGo

if not _POSAPI and not os.loadAPI("/api/pos/turtle.lua") then
	error("Pos API required", 2)
	return
end

if not utils then os.loadAPI("/api/utils.lua") end
utils.require_once("/class/Point.lua")

-- shortcuts
local _insert = table.insert

-- Way
-- waypoints = List of Point
Way = {}
Way.__index = Way

Way.new = function (self, ...)
	local tArgs = {...}
	local rx, ry, rz = getPos()
	local o, i = {}
	setmetatable(o,Way)
	o.type = "Way"
	o.iterator = 1
	o.waypoints = {}
	for i=1,#tArgs do
		if utils.isInstanceOf(tArgs[i], "Point") then
			_insert(o.waypoints, Point:new(tArgs[i].x, tArgs[i].y,  tArgs[i].z) )
		else
			error("Way argument must be a Point instance", 2)
			return
		end
	end
	return o
end

-- getWaypoint( current )
-- (table)	current	Current position
--					example: { x=10, y=50, z=-10 }
-- return: <bool>, <Point>, <Goal|Continue|Next>
-- (bool)	keep running
-- (Point)	current destination
-- (enum)	"Goal" destination reached, "Continue" waypoint didn't change, "Next" new waypoint (reset axisPriority)
Way.getWaypoint = function (self, current)
	local target = self.waypoints[self.iterator]
	if  current.x == target.x
	and current.y == target.y
	and current.z == target.z then
		if self.waypoints[self.iterator + 1] then
			self.iterator = self.iterator + 1
			return true, self.waypoints[self.iterator], "Next"
		else
			return false, self.waypoints[self.iterator], "Goal"
		end
	else
		return true, self.waypoints[self.iterator], "Continue"
	end
end