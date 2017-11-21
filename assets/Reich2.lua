r1 = makeList{kind="rect", num=10, pattern="row", max=width}

scene.r1 = r1

changeList{who=r1, what="c", how=vec3.lightGreen}
changeList{who=r1, what="a", how=.3}
changeList{who=r1, what="p.y", how=height/5}

c1 = function (o)
    if( time % 10 < .5 ) then
        x = R.randFloat(width)
        return x
    else 
        return o.p.x
    end
end

function update()
    changeList{who=r1, what="p.x", how=c1}
    changeList{who=r1, what="s.y", how=bands.x * 3 + 1}
end

scene= {}
buildBackground()
