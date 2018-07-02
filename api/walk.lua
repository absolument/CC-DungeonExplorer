-- Moving API

-- Store steps to wayback
local _path = {}

-- Reset path
function pathReset()
	_path = {}
end

-- Run step and store wayback step
local function _move(step, wayback)
	local b = step()
	if b then
		table.insert(_path, wayback)
	end
	return b
end

-- Move forward, store back step
function forward()
	return _move(turtle.forward, turtle.back)
end

-- Move back, store forward step
function back()
	return _move(turtle.back, turtle.forward)
end

-- Move up, store down step
function up()
	return _move(turtle.up, turtle.down)
end

-- Move down, store up step
function down()
	return _move(turtle.down, turtle.up)
end

-- Turn left, store left turn to wayback
function turnLeft()
	turtle.turnLeft()
	table.insert(_path, turtle.turnLeft)
end

-- Turn right, store right turn to wayback
function turnRight()
	turtle.turnRight()
	table.insert(_path, turtle.turnRight)
end

-- Run backward path
function wayback()
	for _,step in pairs(_path) do
		step()
	end
	pathReset()
end
