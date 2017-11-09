R = rand.new()

scene = {}

background = rect.new()
background.c = vec3.new(0.0)
background.a = 1.0
background.w = width
background.h = height


function update()
    
end

function draw()
	background:draw()

    if scene then
        for i, o in pairs(scene) do
            if o.draw then
                o:draw()
            end
        end
    end
end
