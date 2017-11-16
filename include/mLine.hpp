//
//  mLine.h
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 10/3/17.
//
//

#include "Drawable.hpp"

#ifndef mLine_h
#define mLine_h

class mLine : public Drawable{
public:
    
    float lineWidth;
    ci::vec3 p1, p2;
    
    
    mLine() : Drawable() {
        lineWidth = 1.0f;
        radians = 0.0f;
        p1.x = -50.0f;
        p2.x = 50.0f;
        p1.y = p2.y = p1.z = p2.z = 0.0f;
    }
    
    virtual void print(sol::this_state ts) override
    {
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj, 'lineWidth = float \t p1 and p2 = vec3')");
    }
    
    virtual void draw() override
    {
        ci::gl::color(c.r, c.g, c.b, a);
        ci::gl::ScopedModelMatrix modelScope;
        ci::gl::translate(p);
        ci::gl::rotate(radians, r);
        ci::gl::scale(s);
        
        ci::gl::ScopedLineWidth scp(lineWidth);
        ci::gl::drawLine(p1, p2);
    }
    
    void set_lineWidth(float l){ lineWidth = l; }
    float get_lineWidth(){ return lineWidth; }
    
    void set_p1(ci::vec3 newP1){ p1 = newP1; }
    ci::vec3 * get_p1(){ return &p1; }
    
    void set_p2(ci::vec3 newP2){ p2 = newP2; }
    ci::vec3 * get_p2(){ return &p2; }
};


#endif /* mLine_h */
