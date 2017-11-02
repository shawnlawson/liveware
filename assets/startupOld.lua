scene = {}

function update()
    
end

function draw()
    if scene then
        for i, o in pairs(scene) do
            if o.draw then
                o:draw()
            end
        end
    end
end
