//
//  mCircle.hpp
//  CinderProject
//
//  Created by Shawn Lawson on 8/29/17.
//
//

#ifndef mCircle_h
#define mCircle_h

#include "Drawable.h"

class mCircle : public Drawable{
public:
    
    float radius;
    bool outline;
    float lineWidth;
    
    mCircle() : Drawable() {
        x = ci::app::getWindowCenter().x;
        y = ci::app::getWindowCenter().y;
        z = rX = rY  = 0.0f;
         sX = sY = sZ = rZ = 1.0f;
        outline = false;
        lineWidth = 1.0f;
        radius = 10.f;
        r = g = b = a = 1.0f;
    }
    
    virtual void print(sol::this_state ts) override
    {
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("print('x, y, radius')");
    }
    
    virtual void draw() override
    {
        ci::gl::color(r, g, b, a);
        ci::gl::ScopedModelMatrix modelScope;
        ci::gl::translate(ci::vec3(x, y, z));
        ci::gl::scale(ci::vec3(sX, sY, sZ));
        if (outline)
            ci::gl::drawStrokedCircle(ci::vec2(0,0), radius, lineWidth);
        else
            ci::gl::drawSolidCircle(ci::vec2(0,0), radius);
    }

    
};

#endif /* mCircle_hpp */
