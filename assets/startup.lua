R = rand.new()

scene = {}

background = rect.new()
background.c = vec3.new(0.0)
background.a = 1.0
background.w = width
background.h = height


function buildBackground()
    background = rect.new()
    background.c = vec3.new(0.0)
    background.a = 1.0
    background.w = width
    background.h = height
end

function update()

end

function draw()
	if background and background.draw then
		background:draw()
	end

    drawKids(scene)
end

function drawKids(kids)
	if kids then
		for i, o in pairs(kids) do
			if o.draw then
                if o.drawMode == 2 then
                    o:draw()
                elseif o.drawMode == 1 then
                    o:draw()
                    o.drawMode = 0
                end
            else
            	drawKids(o)
            end
        end
    end
end

--takes a string "x y a " and separates and returns a list ["x","y","a"]
function split(str, sep)
   local result = {}
   local regex = ("([^%s]+)"):format(sep)
   for each in str:gmatch(regex) do
      table.insert(result, each)
   end
   return result
end

function changeList( ... )
    local who 
    local what
    local how

    if type(...)=='table' then
        local t = ...
        who = assert(t.who or nil)
        what = assert(t.what or nil)
        how = assert(t.how or nil)
        local whatExact = split(what, '.')

        for i,o in pairs(who) do
            if type(t.how) == "function" then
                if #whatExact > 1 then
                    o[whatExact[1]][whatExact[2]] = how(o)
                else
                    o[what] = how(o)
                end
            else
                if #whatExact > 1 then
                    o[whatExact[1]][whatExact[2]] = how
                else
                    o[what] = how
                end
            end
        end
    end
end

function makeList( ... )
    local list = {}
    local kind --what time of list: Default=circle.new()   others  circle.new() image.new()
    local num --how many to make: Default=1     others 3,19,100
    local pattern --how you want it to be: Default="zero"  others "row", "col", "rand"
    local min,max --values used for the pattern:Default=0,100   others -122, 300
    local img --image array pointer
    if type(...)=='table' then 
        local t = ...
        kind =assert(t.kind or "circle")
        num = assert(t.num or 1)
        pattern = assert(t.pattern or "zero")
        min = assert(t.min or 0)
        max = assert(t.max or 100)

        for i=1, num do

            local aSampleObj     

            if t.kind == "rect" then
                aSampleObj = rect.new()
            elseif t.kind == "line" then
                aSampleObj = line.new()
            elseif t.kind == "cube" then
                aSampleObj = cube.new()
            elseif t.kind == "image" then
                img = assert(t.img or nil)
                aSampleObj = image.new(t.img)
            else
                aSampleObj = circle.new()
            end

            if pattern == "rand" then
                aSampleObj.p.x = R.randFloat(min,max)
                aSampleObj.p.y = R.randFloat(min,max)
                --aSampleObj.p.z = math.random(min,max)
            else
                local dist = ((max - min)/(num-1))
                if pattern == "row" then
                    aSampleObj.p.x = (i-1)*dist + min
                elseif pattern == "col" then
                    aSampleObj.p.y = (i-1)*dist + min
                end
            end
            -- list:add(aSampleObj)
            list[#list + 1] = aSampleObj
        end
    end
    return list
end
