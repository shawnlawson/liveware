//
//  mSphere.h
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 10/9/17.
//
//

#include "Drawable.hpp"

#ifndef mSphere_h
#define mSphere_h


class mSphere : public Drawable{
public:
    
    float radius;

    
    mSphere() : Drawable() {
        radius = 10.f;
    }
    
    virtual void print(sol::this_state ts) override
    {
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj, '\t lineWidth = float \t radius = float')");
    }
    
    virtual void draw() override
    {
        ci::gl::color(c.r, c.g, c.b, a);
        ci::gl::ScopedModelMatrix modelScope;
        ci::gl::translate(p);
        ci::gl::scale(s);
 
        ci::gl::drawSphere(ci::vec3(0), radius);
    }
    
    
};

#endif /* mSphere_h */
