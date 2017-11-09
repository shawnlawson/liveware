-- edit from main assets
--empty table that holds objects
--scene = {}
R = rand.new()
list = require 'lualgorithms.data.list'
lru = require 'lru'
cache = lru.new(100)

function drawChildren(a)
	 r = circle.new()
	for childList, t  in pairs(cache) do 
		if t==a then

			local i=0
			while i < childList:size() do
				local l = childList:get(i)

				if type(l)==type(r) then
						l:draw()
--						print(l.p)
				else
					drawChildren(l)
				end
				i=i+1
			end

		end
	end
end

function update()

end

--called every frame from c++
function draw()
    background:draw()
	drawChildren("Object")
end




--function makeGrid(gridType, gridWidth, gridHeight, minW, maxW, minH,maxH)

--"picture"
--"nyan.jpg"

--function makeList(listType, listSize, display, even, maxmin, directory/name)

function makeList(listType, listSize, display, even, maxmin,imageFile)
--listType = rect/circle
--listSize = how many
--display =  row, column
--even  = yes/no, if yes then distribule even using min and man
--even  = yes/no, if no then do random
--max-min/(#items-1) = distribution
--imageFile = image.open(imageFile)

	local numParam = 2
	local clear = true
	--default makeList(listType, listSize)
	if display == nil and even == nil and maxmin == nil then
		numParam = 2
	end

	if display ~= nil and not(display == "row" or display == "column" or type(display)== type("a")) then
		--throw error, invalid display type
		print("invalid display")
		clear =false
	end

	if display ~= nil and ((even ~= nil and not(even == "yes" or even == "no")) or even==nil or type(even)~= type("a")) then
		--throw error, invalid even type/missing even
		print("invalid/missing even")
		clear =false
	end

	if display ~= nil and even ~= nil and (maxmin == nil or type(maxmin)~= type("a")) then
		--throw error, invalid even type/missing even
		print("invalid/missing maxmin")
		clear =false
	end
	if listType=="Image" and (imageFile==nil or type(imageFile) ~= type("s")) then
		print("invalid/missing imageFile")
		clear = false
	end

	if display ~= nil and even ~= nil and even == "no" then
		numParam = 4
	end
	if display ~= nil and even ~= nil and even == "yes" then
		numParam = 5
	end

	local minValue, maxValue
	if maxmin ~= nil then
		local values = split(maxmin, " ")
		minValue = values[1]
		maxValue = values[2]
	end	
	if maxValue ==nil then
		maxValue = minValue
		minValue = 0
	end

	--default makeList(listType, listSize)
	if numParam == 2 and clear then
		local aList = list.create()
		if listType == "Image" then
			for i=1, listSize do
				local aSampleObj = image.new()
				aList:add(aSampleObj)
			end
			--providing cache is global
			cache:set(aList,"Image")
			return aList
		end	
		if listType == "Rect" then
			for i=1, listSize do
				local aSampleObj = rect.new()
				aList:add(aSampleObj)
			end
			--providing cache is global
			cache:set(aList,"Rect")
			return aList
		end
		if listType == "Circle" then
			for i=1, listSize do
				local aSampleObj = circle.new()
				aList:add(aSampleObj)
			end
			--providing cache is global
			cache:set(aList,"Circle")
			return aList
		end
	end

	--if its random
	if numParam == 4 and display == "row" and clear then
		local aList = list.create()
		if listType == "Image" then
			for i=1, listSize do
				local aSampleObj = image.new()
				aSampleObj:open(imageFile)
				aSampleObj.p.x = math.random(minValue,maxValue)
				aList:add(aSampleObj)
			end
			--providing cache is global
			cache:set(aList,"Image")
			return aList
		end	
		if listType == "Rect" then
			for i=1, listSize do
				local aSampleObj = rect.new()
				--if the max is nill range is form 0-Max
				--math.randomsee(os.time()) is not working. lua does not know what os is
				aSampleObj.p.x = math.random(minValue,maxValue)
				--aSampleObj.x = math.random(minValue+aSampleObj.w/2,maxValue)
				aList:add(aSampleObj)
			end
			--providing cache is global
			cache:set(aList,"Rect")
			return aList
		end
		if listType == "Circle" then
			for i=1, listSize do
				local aSampleObj = circle.new()
				aSampleObj.p.x = math.random(minValue,maxValue)
				--aSampleObj.x = math.random(minValue+aSampleObj.radius,maxValue)
				aList:add(aSampleObj)
			end
			--providing cache is global
			cache:set(aList,"Circle")
			return aList
		end
	end
	--if its even
	--max-min/(#items-1) = distribution
	--xloction = to spaction*(i-1)
	if numParam == 5 and display == "row"and clear then
		local aList = list.create()
		local dist = math.floor((maxValue - minValue)/(listSize-1))
		local aList = list.create()
		if listType == "Image" then
			for i=1, listSize do
				local aSampleObj = image.new()
				aSampleObj:open(imageFile)
				aSampleObj.p.x = (i-1)*dist+ minValue
				aList:add(aSampleObj)
			end
			--providing cache is global
			cache:set(aList,"Image")
			return aList
		end	
		if listType == "Rect" then
			for i=1, listSize do
				local aSampleObj = rect.new()
				--if the max is nill range is form 0-Max
				--math.randomsee(os.time()) is not working. lua does not know what os is
				aSampleObj.p.x = (i-1)*dist+ minValue
				--aSampleObj.x = (i-1)*dist+ minValue + aSampleObj.w/2
				aList:add(aSampleObj)
			end
			--providing cache is global
			cache:set(aList,"Rect")
			return aList
		end
		if listType == "Circle" then
			for i=1, listSize do
				local aSampleObj = circle.new()
				aSampleObj.p.x = (i-1)*dist + minValue
				--aSampleObj.x = math.random(minValue+aSampleObj.radius,maxValue)
				aList:add(aSampleObj)
			end
			--providing cache is global
			cache:set(aList,"Circle")
			return aList
		end
	end
	if numParam == 4 and display == "column" and clear then
		local aList = list.create()
		if listType == "Image" then
			for i=1, listSize do
				local aSampleObj = image.new()
				aSampleObj:open(imageFile)
				aSampleObj.p.y = math.random(minValue,maxValue)
				aList:add(aSampleObj)
			end
			--providing cache is global
			cache:set(aList,"Image")
			return aList
		end	
		if listType == "Rect" then
			for i=1, listSize do
				local aSampleObj = rect.new()
				--if the max is nill range is form 0-Max
				--math.randomsee(os.time()) is not working. lua does not know what os is
				aSampleObj.p.y = math.random(minValue,maxValue)
				--aSampleObj.y = math.random(minValue+aSampleObj.w/2,maxValue)
				aList:add(aSampleObj)
			end
			--providing cache is global
			cache:set(aList,"Rect")
			return aList
		end
		if listType == "Circle" then
			for i=1, listSize do
				local aSampleObj = circle.new()
				aSampleObj.p.y = math.random(minValue,maxValue)
				--aSampleObj.y = math.random(minValue+aSampleObj.radius,maxValue)
				aList:add(aSampleObj)
			end
			--providing cache is global
			cache:set(aList,"Circle")
			return aList
		end
	end
	--if its even
	--max-min/(#items-1) = distribution
	--xloction = to spaction*(i-1)
	if numParam == 5 and display == "column" and clear then
		local dist = math.floor((maxValue - minValue)/(listSize-1))
		local aList = list.create()
		if listType == "Image" then
			for i=1, listSize do
				local aSampleObj = image.new()
				aSampleObj:open(imageFile)
				aSampleObj.p.y = (i-1)*dist+ minValue
				aList:add(aSampleObj)
			end
			--providing cache is global
			cache:set(aList,"Image")
			return aList
		end	
		if listType == "Rect" then
			for i=1, listSize do
				local aSampleObj = rect.new()
				--if the max is nill range is form 0-Max
				--math.randomsee(os.time()) is not working. lua does not know what os is
				aSampleObj.p.y = (i-1)*dist+ minValue
				--aSampleObj.y = (i-1)*dist+ minValue + aSampleObj.w/2
				aList:add(aSampleObj)
			end
			--providing cache is global
			cache:set(aList,"Rect")
			return aList
		end
		if listType == "Circle" then
			for i=1, listSize do
				local aSampleObj = circle.new()
				aSampleObj.p.y = (i-1)*dist + minValue
				--aSampleObj.y = math.random(minValue+aSampleObj.radius,maxValue)
				aList:add(aSampleObj)
			end
			--providing cache is global
			cache:set(aList,"Circle")
			return aList
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
-----------------------------------
--how to handle "outline = false"
------------------------------------
function changeList(theList, whatToChange, howToChangeIt, changeValues)

	-- changeTypes will include ["x","y"...
	local changeTypes = split(whatToChange, " ")

	-- change values will be "200"{range from 0 to 200} or "3 300"{range from 0 to 200} or "30 300 20 200"{range for the first is 30 to 300 and second is 20 200 and so on}
	local changeValues = split(changeValues, " ")

	--check if the list is null
	if theList == nil then
		print("Invalid list input")
		return nil
	end

	--check if list is empty
	if theList:isEmpty() then
		print("Empty list input")
		return nil
	end

	-- check if we know how to change the list
	if howToChangeIt == "random" or howToChangeIt == "set" then 

		--check if we set but there are more than 1 value
		if #changeValues ~= 1  and howToChangeIt == "set" then
			print("Make sure to only have 1 set value. #input values =",#changeValues)

		--check if the change values are 1,2, or 2* number of changtypes
		elseif #changeValues==1 or #changeValues ==2 or #changeValues == 2*#changeTypes then 

			--go through every change type. "a" is just a random variable, "word" is the change type
			for a,word in ipairs(changeTypes) do

				--check if the change type is legal 
---------------------
--TODO
--or word=="rX" or word=="rY" or word== "sX" or word=="sY" or word=="sZ" or word== "rZ" or
----------------------
				if word =="Image" then
					local i=0
					while i < theList:size() do
							local anObj = theList:get(i)
							local justAtemporaryVariable = image.new()
							--make sure we are chang a rect or circle
							--TODO add more stuff
							if type(anObj)==type(justAtemporaryVariable)then
								anObj:setImage(math.random(changeValues[1]))
							else
								print("Attempting to change values of type:",type(anObj))
							end
							i=i+1;
						end

				elseif word=="radius" or word == "radians" or word == "outline" or word=="lineWidth" or word== "radians" or word== "w" or word== "h" then

					--w,h,radians,a, linWidth, outline, radius
					if howToChangeIt == "random" then
						--go through the list
						local i=0
						while i < theList:size() do
							local anObj = theList:get(i)
							local justAtemporaryVariable = circle.new()
							--make sure we are chang a rect or circle
							--TODO add more stuff
							if type(anObj)==type(justAtemporaryVariable)then
								if #changeValues == 1 then
									anObj[word]= math.random(0,changeValues[1])
								end
								if #changeValues == 2 then
									anObj[word]= math.random(changeValues[1],changeValues[2])
								end
								if #changeValues == 2*#changeTypes then
									anObj[word]= math.random(changeValues[a*2-1],changeValues[a*2])
								end
							else
								print("Attempting to change values of type:",type(anObj))
							end
							i=i+1;
						end

					elseif howToChangeIt == "set" then
						local i=0
						while i < theList:size() do
							local anObj = theList:get(i)
							local justAtemporaryVariable = circle.new()
							if type(anObj)==type(justAtemporaryVariable)then
								anObj[word]= changeValues[1]
							else
								print("Attempting to change values of type:",type(anObj))
							end
							i=i+1;
						end
					end
				elseif word=="x" or word== "y" or word== "z" then

					if howToChangeIt == "random" then
						--go through the list
						local i=0
						while i < theList:size() do
							local anObj = theList:get(i)
							local justAtemporaryVariable = circle.new()
							--make sure we are chang a rect or circle
							--TODO add more stuff
							if type(anObj)==type(justAtemporaryVariable)then
								if #changeValues == 1 then
									anObj.p[word]= math.random(0,changeValues[1])
								end
								if #changeValues == 2 then
									anObj.p[word]= math.random(changeValues[1],changeValues[2])
								end
								if #changeValues == 2*#changeTypes then
									anObj.p[word]= math.random(changeValues[a*2-1],changeValues[a*2])
								end
							else
								print("Attempting to change values of type:",type(anObj))
							end
							i=i+1;
						end

					elseif howToChangeIt == "set" then
						local i=0
						while i < theList:size() do
							local anObj = theList:get(i)
							local justAtemporaryVariable = circle.new()
							if type(anObj)==type(justAtemporaryVariable)then
								anObj.p[word]= changeValues[1]
							else
								print("Attempting to change values of type:",type(anObj))
							end
							i=i+1;
						end
					end

				elseif  word== "g" or word== "b" or word== "r" then
					if howToChangeIt == "random" then
						--go through the list
						local i=0
						while i < theList:size() do
							local anObj = theList:get(i)
							local justAtemporaryVariable = circle.new()
							--make sure we are chang a rect or circle
							--TODO add more stuff
							if type(anObj)==type(justAtemporaryVariable)then
								if #changeValues == 1 then
									anObj.c[word]= math.random(0,changeValues[1])
								end
								if #changeValues == 2 then
									anObj.c[word]= math.random(changeValues[1],changeValues[2])
								end
								if #changeValues == 2*#changeTypes then
									anObj.c[word]= math.random(changeValues[a*2-1],changeValues[a*2])
								end
							else
								print("Attempting to change values of type:",type(anObj))
							end
							i=i+1;
						end

					elseif howToChangeIt == "set" then
						local i=0
						while i < theList:size() do
							local anObj = theList:get(i)
							local justAtemporaryVariable = circle.new()
							if type(anObj)==type(justAtemporaryVariable)then
								anObj.c[word]= changeValues[1]
							else
								print("Attempting to change values of type:",type(anObj))
							end
							i=i+1;
						end
					end

				else
					print("Unknown variable to change:",word)
				end
			end
		else 
			print("Wrong number of Min/Max")
		end
	else
		print("Unknown change type:",howToChangeIt)
	end
end

--Drawable
--Vec3 p      = position x,y,z
--Vec3 c      = color x,y,z
--Vec3 r      = for rotation
--vec3 s  

--float a     = alpha
--float radians??


background = rect.new()
background.c = vec3.new(0.0)
background.a = 1.0
background.w = width
background.h = height



--instantiate a new circle
--add to scene could also be done like, scene["c"] = c
--scene.r = r
local circleList = list.create()
objList = list.create()


objList:add("Rect")
objList:add("Circle")
objList:add("Image")
cache:set(objList,"Object")	

-- makes a list of 3 images from "cats" 
-- images will be in a row in random order from 0 to 600
-- imgList = makeList("Image", 2, "row", "no", "300", "cats")

-- changeList(imgList, "x","random","600")
-- changeList(imgList, "r g b","random","1")

-- makes a list of 3 images from "cats" 
-- images will be in a row from 0 to 600 spaced out evenly
--imgList = makeList("Image", 3, "row", "yes", "600", "cats")

-- in my Cats folder there are only 3 images
-- changeList(imgList, "Image","random","3")

-- all of the following works:
--anotherlist = makeList("Rect",3)
--anotherlist = makeList("Rect",3, "row", "no", "600")
--anotherlist = makeList("Rect",3, "row", "yes", "600")
--anotherlist = makeList("Circle",3, "column", "no", "600")
--anotherlist = makeList("Circle",3, "column", "yes", "600")














--Below are just some code I used for debuging

--cache:set(imgList,"Image")	

--testList = list.create()
--testObj = rect.new()

--testList:add(testObj)


--testImg = image.new()
--testImg:open("cats")
--testImg:setImage(math.random(3))

--testList:add(testImg)



--makeList(listType, listSize, display, even, maxmin)
--rectList = makeList("Rect",7, "column","no", "300")
--rectList = makeList("Rect",7, "column","no", "300")


--changeList(rectList, "x y r g radians b a", "random", "0 500 0 500 0 1 0 1 0 90 0 1 0 1")
--changeList(rectList, "outline", "set", "false")

--changeList(rectList, "outline", "random", "true")  <-- this will fail, make sure "outline" is by itself and it is only with "set"


--changeList(theList, whatToChange, howToChangeIt, changeValues)
--changeList(rectList, "x y r g b", "random", "0 300 0 300 0 1 0 1 0 1")

--circleList = makeList("Circle",3)
--changeList(circleList, "outline", "set", "true")

--changeList(circleList, "x y r g b radius", "random", "0 500 0 500 0 1 0 1 0 1 0 20")

