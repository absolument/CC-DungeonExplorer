--API utils
--author: SukaiPoppuGo

-- shortcuts
local _abs  = math.abs
local _sqrt = math.sqrt
local _pow  = math.pow
local _max  = math.max
local _min  = math.min
local _rand = math.random
local _sub  = string.sub
local _len  = string.len
local _rep  = string.rep
local _char = string.char

--Extensions
math.round = function(n, m)
	m = m and 10 ^ m or 1
	return math.floor((n * m) + 0.5) / m
end

--
function var_dump(v,pad)
	pad = pad or ""
	local _t = type(v)
	if _t == "table" then
		local _k,_v
		local _r = ""
		for _k,_v in pairs(v) do
			_r = _r..pad.."  ".._k.."="..var_dump(_v,pad.."  ")..",\n"
		end
		if string.len(_r)>0 then
			return "{\n".._r..pad.."}"
		else
			return "{}"
		end
	elseif _t == "function" then
		return "function()"
	elseif _t == "string" then
		return "\""..v.."\""
	elseif _t == "nil" or _t == "number" or _t == "boolean" then
		return tostring(v)
	else 
		return _t
	end
end

-- 
local _loadedFiles = {}
function include(filename)
	if fs.exists(filename) then
		dofile(filename)
		_loadedFiles[filename] = true
		return true
	else
		print(string.format("Include file \"%s\" not found", filename))
		return false
	end
end
function require(filename, error_level)
	error_level = error_level or 1
	if fs.exists(filename) then
		dofile(filename)
		_loadedFiles[filename] = true
		return true
	else
		error(string.format("Required file \"%s\" not found", filename), error_level + 1)
		return false
	end
end
function include_once(filename)
	if not _loadedFiles[filename] then
		return include(filename)
	end
	return _loadedFiles[filename]
end
function require_once(filename)
	if not _loadedFiles[filename] then
		return require(filename, 2)
	end
end

--
function file_get_contents(filename)
	if not fs.exists(filename) then
		error(string.format("File \"%s\" not found", filename), 2)
		return false
	end
	local handler = fs.open(filename, "r")
	local contents = handler.readAll()
	handler.close()
	return contents
end

-- POO
function isInstanceOf(o, sType)
	return type(o) == "table" and o.type and o.type == sType
end

-- Parse MC coords format
-- absolute / ~relative
function parseCoords(v, r)
	local s = tostring(v)
	if _sub(s, 1, 1) == "~" then
		if _len(s) == 1 then
			return r
		else
			return r + tonumber(_sub(s, 2))
		end
	else
		return v
	end
end

-- Constraint value
function constraint(v, a, b)
	return _max(a > b and b or a, _min(a > b and a or b, v))
end

function coordInside(A, B, C)
	return A.x >= _min(B.x, C.x) and A.x <= _max(B.x, C.x) and A.y >= _min(B.y, C.y) and A.y <= _max(B.y, C.y) and A.z >= _min(B.z, C.z) and A.z <= _max(B.z, C.z)
end

--Taxicab geometry
--https://en.wikipedia.org/wiki/Taxicab_geometry
-- d(A,B) = |B.x - A.x| + |B.y - A.y|
function fuelCost(A, B)
	return _abs(B.x - A.x) + _abs(B.y - A.y) + _abs(B.z - A.z)
end

--https://math.stackexchange.com/questions/42640/calculate-distance-in-3d-space
function distance(A, B)
	return _sqrt(_pow(B.x - A.x, 2) + _pow(B.y - A.y, 2) + _pow(B.z - A.z, 2))
end

--Randomize table
function shuffle( t )
    local it = #t
    local j
    for i = it, 2, -1 do
        j = _rand(i)
        t[i], t[j] = t[j], t[i]
    end
	return t
end

function keySort( t )
	local tkeys = {}
	for k in pairs( t ) do table.insert(tkeys, k) end -- populate the table that holds the keys
	table.sort( tkeys ) -- sort the keys
	local temp = {}
	for _, k in ipairs( tkeys ) do table.insert( temp, t[k] ) end -- use the keys to retrieve the values in the sorted order
	return temp
end

--Copy table
-- if more than one merge them 
-- in case of overwriting values last one gets its way
function copyTable(...) 
	tArgs = {...}
	local B = {}
		for _, A in pairs(tArgs) do
			if A and type(A) == "table" then
				for i, k in pairs(A) do
					if type(k) == "table" then B[i] = copyT( B[i] or {}, k)
					else B[i] = k end
				end
			end
		end
	return B
end

-- compareData
-- Compare every data from _2 to data from _1
-- @param	_1	(mixed)	data to compare
-- @param	_2	(mixed)	reference
-- @param	strict	(bool)	Compare every data from _2 and every data from _1
-- @return	(bool)
function compareData(_1,_2, strict)
	strict = strict or false
	if type(_1) == type(_2) then
		if type(_1) == "table" then
			local test, total, k, v = 0,0
			for k,v in pairs(_2) do
				total = total+1
				if compareData(_1[k], v, strict) then
					test = test+1
				end
			end
			if strict then
				for k,v in pairs(_1) do
					total = total+1
					if compareData(_2[k], v, true) then
						test = test+1
					end
				end
			end
			return test == total
		elseif type(_1) == "string"
		or type(_1) == "number"
		or type(_1) == "boolean" then
			return _1 == _2
		else
			error("Cant compare "..type(_1),2)
		end
	end
	return false
end
-- Compare every data from B to data from A
-- function compareData(A, B)
-- 	if type(A) == type(B) then
-- 		if type(A) == "table" then
-- 			local test, total, k, v = 0, 0
-- 			for k,v in pairs(B) do
-- 				total = total + 1
-- 				if compareData(A[k], v) then
-- 					test = test + 1
-- 				end
-- 			end
-- 			return test == total
-- 		elseif type(A) == "string"
-- 		or type(A) == "number"
-- 		or type(A) == "boolean" then
-- 			return A == B
-- 		else
-- 			error("Cant compare "..type(A),2)
-- 		end
-- 	end
-- 	return false
-- end


-- Run a function after X update iteration
-- CountdownFunction = {}
-- CountdownFunction.__index = CountdownFunction
-- CountdownFunction.new = function(self, count, func)
--    local o = {}
--    setmetatable(o, CountdownFunction)
--    o.count = count
--    o.func = func
--    return o
-- end
-- CountdownFunction.update = function(self, ...)
-- 	if self.count > 0 then
-- 		self.count = self.count - 1
-- 	elseif self.count == 0 then
-- 		slef.count = -1
-- 		return self.func(...)
-- 	end
-- end