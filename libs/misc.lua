function lerp(st,ed,t)
	return st+t*(ed-st)
end

function math.round(num)
    return math.floor(num+0.5)
end

function math.clamp(val, lower, upper)
    return math.max(lower, math.min(upper, val))
end

function getIndex(tab, val)
    local index = nil
    for i, v in ipairs (tab) do 
        if (v == val) then
          index = i 
        end
    end
    return index
end

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function strsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

function distanceFrom(x1,y1,x2,y2)
	return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end

--[[function pixelToWhite(x, y, r, g, b, a)
    return 255,255,255,a/1.2
end

function vit(imagePath, transR, transG, transB)
   local imageData = love.image.newImageData( imagePath )
   imageData:mapPixel( pixelToWhite )
   return love.graphics.newImage( imageData )
end]]

function table.shuffle(t)
  local tbl = {}
  for i = 1, #t do
    tbl[i] = t[i]
  end
  for i = #tbl, 2, -1 do
    local j = love.math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

function table.shift(table)
  local temp={}
  for k=1,#table do
    if k==#table then
      temp[1]=v
    else
      temp[k+1]=v
    end
  end
  return temp
end