c = mCircle.new()
scene.c = c

function update()

end

function circleStuff()
    c.y = (c.y + deltaTime * 10) % (width/2)
end


