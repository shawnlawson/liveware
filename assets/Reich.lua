r1 = makeList{kind="rect", num=25, pattern="row", max=width}

scene.r1 = r1

changeList{who=r1, what="c", how=vec3.lightGreen}
changeList{who=r1, what="a", how=.3}
changeList{who=r1, what="p.y", how=R.randFloat(height)}

c1 = function (o) if( time % 10 < .5 ) then x = R.randFloat(width) return x else return o.p.x end end


function update()
    changeList{who=r1, what="p.x", how=c1}
     changeList{who=r2, what="s.y", how=bands.y * 3 + 2+ audioNN.y + P:noise(time)}
end

scene= {}
buildBackground()

P = perlin.new()