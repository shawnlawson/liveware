//
//  mLine.h
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 10/3/17.
//
//

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
        lua.safe_script("prnt(obj, 'lineWidth = float \t p1, p2 = vec3')");
    }
    
    virtual void draw() override
    {
        ci::gl::color(c.r, c.g, c.b, a);
        ci::gl::ScopedModelMatrix modelScope;
        ci::gl::translate(p);
        ci::gl::rotate(radians, r);
        ci::gl::scale(s);
        
        ci::gl::drawLine(p1, p2);
    }
    
    
};


#endif /* mLine_h */
