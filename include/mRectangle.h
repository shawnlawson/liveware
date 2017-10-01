//
//  mRectangle.h
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 9/28/17.
//
//

#ifndef mRectangle_h
#define mRectangle_h

#include "Drawable.h"

class mRectangle : public Drawable{
public:
    
    bool outline;
    float lineWidth;
    float w, h;
    
    
    mRectangle() : Drawable() {
        x = ci::app::getWindowCenter().x;
        y = ci::app::getWindowCenter().y;
        z = rX = rY =  0.0f;
        sX = sY = sZ = rZ = 1.0f;
        outline = false;
        lineWidth = 1.0f;
        radians = 0.0f;
        w = h = 100.f;
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
        ci::gl::rotate(radians, ci::vec3(rX, rY, rZ));
        ci::gl::scale(ci::vec3(sX, sY, sZ));
        ci::Rectf rect = ci::Rectf(-w*.5, -h*.5, w*.5, h*.5);
        if (outline)
            ci::gl::drawStrokedRect(rect, lineWidth);
        else
            ci::gl::drawSolidRect(rect);

    }
    
    
};


#endif /* mRectangle_h */
