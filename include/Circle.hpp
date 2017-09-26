//
//  thing.hpp
//  CinderProject
//
//  Created by Shawn Lawson on 8/29/17.
//
//

#ifndef thing_hpp
#define thing_hpp

#include "Drawable.h"

class mCircle : public Drawable{
public:
    
    float radius = 10.0f;
    
    mCircle() : Drawable() {
        x = ci::app::getWindowCenter().x;
        y = ci::app::getWindowCenter().y;
    }
    
    virtual void print(sol::this_state ts) override
    {
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("print('x, y, radius')");
    }
    
    virtual void draw() override
    {
        ci::gl::color(1.0, 1.0, 1.0, .25);
        ci::gl::drawSolidCircle(ci::vec2(x, y), radius);
    }

    
};

#endif /* thing_hpp */
