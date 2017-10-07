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
    
};


#endif /* Drawable_h */
