c = image.new()
scene.c = c
c:open('nyan.png')

function update()

end

function circleStuff()
    c.y = (c.y + deltaTime * 10) % (width/2)
end


