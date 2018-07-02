--Cell
--author: SukaiPoppuGo

Cell = {}
Cell.__index = Cell
function Cell:new(x,y)
	local self = {}
	setmetatable(self,Cell)
	self.x = x
	self.y = y
	self.bg = false
	self.highlight = false
	self.infos = {"None"}
	return self
end