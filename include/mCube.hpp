//
//  mCube.h
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 10/9/17.
//
//

#include "Drawable.hpp"

#ifndef mCube_h
#define mCube_h


class mCube : public Drawable{
public:
    
    bool outline;
    float lineWidth;
    float w, h, d;
    
    
    mCube() : Drawable() {
        outline = false;
        lineWidth = 1.0f;
        w = h = d = 100.f;
    }
    
    virtual void print(sol::this_state ts) override
    {
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj, 'outline = false \t lineWidth = float \t w = float \t h = float \t d = float')");
    }
    
    virtual void draw() override
    {
        ci::gl::color(c.r, c.g, c.b, a);
        ci::gl::ScopedModelMatrix modelScope;
        ci::gl::translate(p);
        ci::gl::rotate(radians, r);
        ci::gl::scale(s);
        if (outline)
            ci::gl::drawStrokedCube(ci::vec3(0), ci::vec3(w, h, d));
        else
            ci::gl::drawCube(ci::vec3(0), ci::vec3(w, h, d));
                
    }
    
    void set_outline(bool b){ outline = b; }
    bool get_outline(){ return outline; }
    
    void set_lineWidth(float l){ lineWidth = l; }
    float get_lineWidth(){ return lineWidth; }
    
    void set_w(float newW){ w = newW; }
    float get_w(){ return w; }
    
    void set_h(float newH){ h = newH; }
    float get_h(){ return h; }
    
    void set_d(float newD){ d = newD; }
    float get_d(){ return d; }
};


#endif /* mCube_h */
