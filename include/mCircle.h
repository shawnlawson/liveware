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
        p.x = ci::app::getWindowCenter().x;
        p.y = ci::app::getWindowCenter().y;
        p.z = r.x = r.y  = 0.0f;
         s.x = s.y = s.z = r.z = 1.0f;
        outline = false;
        lineWidth = 1.0f;
        radius = 10.f;
        c = ci::Color::white();
//        r = g = b = a = 1.0f;
    }
    
    virtual void print(sol::this_state ts) override
    {
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("print('outline = false \t lineWidth = float \t radius = float')");
    }
    
    virtual void draw() override
    {
        ci::gl::color(c);
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
