imgs = imageSrc.new("pat1")
imgs2 = imageSrc.new("pat2")
imgs3 = imageSrc.new("pat3")
imgs4 = imageSrc.new("pat4")

i = image.new(imgs)
i.drawMode = 1
scene.i = i

counter = 0
whenToChange = 0

background.a = 0
clearBackground = false
buildBackground()

function update()
    if counter > 3 then 
        i.drawMode = 1
        i.p.x = R.randFloat(width)
        i.p.y = R.randFloat(height)

        i.which = R.randInt(6)

        if(R.randInt(2) > 0 ) then
            i.radians = PI
        else
            i.radians = 0
        end
        whenToChange = R.randInt(8)
        counter = 0
    end
     
    counter = counter + deltaTime
end

