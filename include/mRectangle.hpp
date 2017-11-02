//
//  mRectangle.h
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 9/28/17.
//
//

#include "Drawable.hpp"

#ifndef mRectangle_h
#define mRectangle_h


class mRectangle : public Drawable{
public:
    
    bool outline;
    float lineWidth;
    float w, h;
    
    mRectangle() : Drawable() {
        outline = false;
        lineWidth = 1.0f;
        w = h = 100.f;
    }
    
    virtual void print(sol::this_state ts) override
    {
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj, 'outline = false \t lineWidth = float \t w = float \t h = float')");
    }
    
    virtual void draw() override
    {
        ci::gl::color(c.r, c.g, c.b, a);
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
    
    void set_outline(bool b){ outline = b; }
    bool get_outline(){ return outline; }
    
    void set_lineWidth(float l){ lineWidth = l; }
    float get_lineWidth(){ return lineWidth; }
    
    void set_w(float newW){ w = newW; }
    float get_w(){ return w; }
    
    void set_h(float newH){ h = newH; }
    float get_h(){ return h; }

};


#endif /* mRectangle_h */
