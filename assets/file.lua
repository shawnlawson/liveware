scene:clear()
t = thing.new()
r = thing.new()

scene:add(t)
--c = t:it()

c = scene[1]:it()

c:add(thing.new())

print(#t.kids)

function d(kids)
    --print("container has:", #kids)
    for k=1,#kids do
        
        v = kids[k]
        v.y = v.y + deltaTime * 600
        v.y = v.y % 200
    end
end

function update()
 --  print("container has:", scene)
    for k=1,#scene do
        v = scene[k]
        v.y = v.y + deltaTime * 60
        v.y = v.y % 200
     --   print(#v.kids)
        d(v.kids)
    end
end

function t:update()


end
