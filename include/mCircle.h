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
        outline = false;
        lineWidth = 1.0f;
        radius = 10.f;
    }
    
    virtual void print(sol::this_state ts) override
    {
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj, 'outline = false \t lineWidth = float \t radius = float')");
    }
    
    virtual void draw() override
    {
        ci::gl::color(c.r, c.g, c.b, a);
        ci::gl::ScopedModelMatrix modelScope;
        ci::gl::translate(p);
        ci::gl::scale(s);
        if (outline)
            ci::gl::drawStrokedCircle(ci::vec2(0,0), radius, lineWidth);
        else
            ci::gl::drawSolidCircle(ci::vec2(0,0), radius);
    }

    
};

#endif /* mCircle_hpp */
