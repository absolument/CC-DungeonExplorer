--Point
--author: SukaiPoppuGo

if not _POSAPI and not os.loadAPI("/api/pos/turtle.lua") then
	error("Pos API required", 2)
	return
end

if not utils then os.loadAPI("/api/utils.lua") end

-- shortcuts
local _abs = math.abs
local _pow = math.pow
local _max = math.max
local _min = math.min
local _sqrt = math.sqrt
local _rep = string.rep
local _len = string.len

--
_G.Point = {}
Point.__index = Point

Point.new = function(self, x, y, z)
   local o = {}
   local rx, ry, rz = getPos()
   setmetatable(o, Point)
   o.type = "Point"
   o.x = utils.parseCoords(x, rx)
   o.y = utils.parseCoords(y, ry)
   o.z = utils.parseCoords(z, rz)
   return o
end

Point.__add = function(A, B)
	return Point:new(A.x + B.x, A.y + B.y, A.z + B.z)
end

Point.__sub = function(A, B)
	return Point:new(A.x - B.x, A.y - B.y, A.z - B.z)
end

Point.__eq = function(A, B)
	return A.x == B.x and A.y == B.y and A.z == B.z
end

Point.__lt = function(A, B) -- <
	return A:distance() < B:distance()
end

Point.__le = function(A, B) -- <=
	return A:distance() <= B:distance()
end

Point.__concat = function(self)
	return "{"..self.x..","..self._y..","..self._z.."}"
end

Point.__tostring = function(self)
	local _x = _rep(" ", _max(0, 5 - _len(self.x)))..self.x
	local _y = _rep(" ", _max(0, 5 - _len(self.y)))..self.y
	local _z = _rep(" ", _max(0, 5 - _len(self.z)))..self.z
	return "{".._x..",".._y..",".._z.."}"
end

Point.fuelCost = function (A, B)
	B = B and B or getPos(true)
	--print("")
	--print("_abs(B.x - A.x) + _abs(B.y - A.y) + _abs(B.z - A.z)")
	--print(string.format("(%s) B = (%s) %s, (%s) %s, (%s) %s", type(B), type(B.x), tostring(B.x), type(B.y), tostring(B.y), type(B.z), tostring(B.z)))
	--print(string.format("(%s) A = (%s) %s, (%s) %s, (%s) %s", type(A), type(A.x), tostring(A.x), type(A.y), tostring(A.y), type(A.z), tostring(A.z)))
	return _abs(B.x - A.x) + _abs(B.y - A.y) + _abs(B.z - A.z)
end

Point.distance = function (A, B)
	B = B and B or getPos(true)
	return _sqrt(_pow(B.x - A.x, 2) + _pow(B.y - A.y, 2) + _pow(B.z - A.z, 2))
end

Point.size = function(A, B)
	return _abs(B.x - A.x) + 1, _abs(B.y - A.y) + 1, _abs(B.z - A.z) + 1
end

Point.volume = function(A, B)
	local _x, _y, _z = A:size(B)
	return _x * _y * _z
end
