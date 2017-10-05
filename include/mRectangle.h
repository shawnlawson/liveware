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
        p.x = ci::app::getWindowCenter().x;
        p.y = ci::app::getWindowCenter().y;
        p.z = r.x = r.y =  0.0f;
        s.x = s.y = s.z = r.z = 1.0f;
        outline = false;
        lineWidth = 1.0f;
        radians = 0.0f;
        w = h = 100.f;
        c = ci::Color::white();
//        r = g = b = a = 1.0f;
    }
    
    virtual void print(sol::this_state ts) override
    {
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("print('outline = false \t lineWidth = float \t w = float \t h = float')");
    }
    
    virtual void draw() override
    {
        ci::gl::color(c);
        ci::gl::ScopedModelMatrix modelScope;
        ci::gl::translate(p);
        ci::gl::rotate(radians, r);
        ci::gl::scale(s);
        ci::Rectf rect = ci::Rectf(-w*.5, -h*.5, w*.5, h*.5);
        if (outline)
            ci::gl::drawStrokedRect(rect, lineWidth);
        else
            ci::gl::drawSolidRect(rect);

    }
    
    
};


#endif /* mRectangle_h */
