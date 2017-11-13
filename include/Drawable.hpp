//
//  Drawable.h
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 9/21/17.
//
//

#ifndef Drawable_h
#define Drawable_h

class Drawable {
public:

    ci::vec3 p, r, s;
    ci::vec3 c;
    float a;
    float radians;
    int drawMode = 2;

    Drawable(){
        p.x = ci::app::getWindowCenter().x;
        p.y = ci::app::getWindowCenter().y;
        p.z = r.x = r.y = 0.0f;
        a = s.x = s.y = s.z = r.z = 1.0f;
        radians = 0.0f;
        c = ci::vec3(1.0f);
    }
    
    virtual void print(sol::this_state ts){}
    
    virtual void draw(){}
    
    void set_p(ci::vec3 newP){ p = newP; }
    ci::vec3 * get_p(){ return &p; }
    
    void set_r(ci::vec3 newR){ r = newR; }
    ci::vec3 * get_r(){ return &r; }
    
    void set_s(ci::vec3 newS){ s = newS; }
    ci::vec3 * get_s(){ return &s; }
    
    void set_c(ci::vec3 newC){ c = newC; }
    ci::vec3 * get_c(){ return &c; }
    
    void set_a(float newA){ a = newA; }
    float get_a(){ return a; }
    
    void set_radians(float newRadians){ radians = newRadians; }
    float get_radians(){ return radians; }
    
    void set_drawMode(int newDrawMode){ drawMode = newDrawMode; }
    int get_drawMode(){ return drawMode; }
};


#endif /* Drawable_h */
