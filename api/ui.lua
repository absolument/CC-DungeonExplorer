--API ui
--author: SukaiPoppuGo

local screenW, screenH = term.getSize()

function screenCutString(str)
	return string.len(str) >= screenW - 1 and string.sub(str, string.len(str) - screenW +2) or str
end

function output(str, ln)
	term.setCursorPos(1, ln)
	term.clearLine()
	term.write(str)
	term.setCursorPos(1, ln+1)
end

function outputEndScreen(str)
	output(string.rep(" ", screenW - string.len(str))..str, screenH)
end

function clearLines(startY, endY)
	for i=startY,endY,1 do
		term.setCursorPos(1,i)
		term.clearLine()
	end
end

function blit(text, textColor, backgroundColor)
	text = string.sub(text..string.rep(" ", screenW), 0, screenW)
	textColor = string.sub(string.rep(textColor, screenW), 0, screenW)
	backgroundColor = string.sub(string.rep(backgroundColor, screenW), 0, screenW)
	term.blit(text, textColor, backgroundColor)
end

function btn(str, enabled)
	local C, L = string.char(149), string.len(str)
	local SF, S8, S0 = string.rep("f", L), string.rep("8", L), string.rep("0", L)
	if enabled then
		term.blit(C..str..C, "f"..SF.."8", "8"..S8.."f")
	else
		term.blit(" "..str.." ", "0"..S0.."0", "f"..SF.."f")
	end
end

function waitPressAnyKey()
	os.pullEvent("key")
	os.pullEvent("key_up")
end

function box(msg, minWidth, title, _debug)
	_debug = _debug or false
	minWidth = minWidth or 0
	msg = (type(msg) == "string") and {msg} or msg
	local x,y = term.getCursorPos()
	local txtColor, bgColor = "0", "7"
	local maxLen = minWidth
	for k,v in pairs(msg) do
		maxLen = (maxLen < string.len(tostring(v))) and string.len(tostring(v)) or maxLen
	end
	maxLen = math.min(maxLen, screenW - 2)
	local pad = string.rep(" ", screenW)
	local borderColor = "8"
	local txtColorLine, bgColorLine = string.rep(txtColor, maxLen), string.rep(bgColor, maxLen)
	term.blit(
		string.char(151)..string.rep(string.char(131), maxLen)..string.char(148),
		string.rep(borderColor, maxLen + 1)..bgColor,
		bgColor..bgColorLine..borderColor
	)
	for k,v in pairs(msg) do
		term.setCursorPos(x, y + k)
		local line1 = string.char(149)..string.sub(tostring(v)..pad, 0, maxLen)..string.char(149)
		local line2 = borderColor..txtColorLine..bgColor
		local line3 = bgColor..bgColorLine..borderColor
		if _debug then
			print("line1="..string.len(line1))
			print("line2="..string.len(line2))
			print("line3="..string.len(line3))
			sleep(.1)
			os.pullEvent("none")
		end
		term.blit( line1, line2, line3)
	end
	term.setCursorPos(x, y + #msg + 1)
	term.blit(
		string.char(138)..string.rep(string.char(143), maxLen)..string.char(133),
		bgColor..bgColorLine..bgColor,
		string.rep(borderColor, maxLen + 2)
	)
	if title then
		term.setCursorPos(x, y)
		term.blit(
			string.sub(title, 0, maxLen + 2),
			string.sub(string.rep(txtColor, #title), 0, maxLen + 2),
			string.sub(string.rep(bgColor, #title), 0, maxLen + 2)
		)
	end
	term.setCursorPos(x, y + #msg + 2)
end

function inputFilename(msg, line, filename)
	filename = filename or ""
	while true do
		output(msg..filename, line)
		term.setCursorPos(string.len(msg..filename) + 1, line)
		local e, p = os.pullEvent()
		if e == "key" and p == keys.backspace then
			filename = string.sub(filename, 0, math.max(0, string.len(filename) - 1))
		elseif e == "key_up" and p == keys.enter and string.len(filename) > 0 then
			if fs.exists(filename) then
				output("File already exists. Overwrite ? Y/N", line+1)
				while true do
					local e2, p2 = os.pullEvent("key")
					if p2 == keys.y then
						return filename
					elseif p2 == keys.n then
						output("", line+1)
						break
					end
				end
			else
				return filename
			end
		elseif e == "char" then
			filename = filename..p
		end
	end
end

function drawTurtleInventory(selection)
	local padX, padY = 2, 3
	local txtLine, txtColor, bgColor = "","","ffffff"
	for i = 0, 15 do
		local sLen = (i % 2 == 0) and 1 or 2
		local sBox = (sLen == 1) and string.char(143) or string.char(138)..string.char(133)
		txtLine = txtLine..sBox
		local boxColor = (turtle.getItemCount(i + 1) > 0) and "8" or "7"
		boxColor = (i == selection) and "0" or boxColor
		txtColor = txtColor..string.rep(boxColor, sLen)
		if i%4 == 3 then
			term.setCursorPos(padX, padY + math.floor(i / 4))
			term.blit(txtLine, txtColor, bgColor)
			txtLine, txtColor, bgColor = "","","ffffff"
		end
	end
	term.setTextColor(colors.white)
	term.setBackgroundColor(colors.black)
end