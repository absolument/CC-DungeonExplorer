-- API inventory
-- @author SukaiPoppuGo
-- Turtle inventory manager

-- require utils API
if not utils then
	os.loadAPI("/api/utils.lua")
end

-- slectSlot
-- @param	n	(number)	slot number
-- Faster turtle.select when n slot is already selected
function selectSlot(n)
	if n > 16 then n = n%16+1 end
	if turtle.getSelectedSlot() ~= n then
		turtle.select(n)
	end
end


-- findSlot
-- @param	ref	(mixed) data of searched item
-- @param	strict	(bool)	strict compare
-- @return	success	(bool)
-- @return	slot	(number)
-- @return 	count	(number)
function findSlot(ref, strict)
	local strict = strict or false
	local data
	for slot=1,16 do
		data = turtle.getItemDetail(slot)
		if utils.compareData(ref, data, strict) then
			return true, slot, data.count
		end
	end
	return false, nil, 0
end
