l = makeList{kind="line", min=10, max=300, num=100, pattern="rand"}

fym = function(o) return R.randFloat(height) end
changeList{who=l, what="p.y", how=fym}

fyl = function(o) return o.p.x + width/2 - 150 end
changeList{who=l, what="p.x", how=fyl}

scene.l = l
P = perlin.new()

fy = function(o) 
    t = o.p1.y + P:noise(o.p.x * .05) * 100
    if t > 100 then
        return 100
    elseif t < -100 then
        return -100
    else
        return t
    end
end

fy2 = function(o) 
    t = o.p1.y + P:noise(o.p.x  * .05) * 100
    if t > 100 then
        return 100
    elseif t < -100 then
        return -100
    else
        return t
    end
end

fpy = function(o)
    return (o.p.y + P:noise(time * .01 + o.p.x * .1) * 1) % height
end

fx = function(o) return (o.p.x + deltaTime * 5) % width end

function update()
    changeList{who=l, what="p1.y", how=fy}
    changeList{who=l, what="p2.y", how=fy2}
    changeList{who=l, what="p.x", how=fx}
    changeList{who=l, what="p.y", how=fpy}
    changeList{who=l, what="s.x", how=1 + bands.x}
end

cc = function(o)
    local t = R.randFloat(3)
    if(t >2.0 ) then
        return vec3.powderBlue()
    elseif(t > 1.0) then
        return vec3.cornflowerBlue()
    else
        return vec3.skyBlue()
    end
end

changeList{who=l, what="c", how=cc}

background.a = .03125
clearBackground = false
scene = {}
buildBackground()