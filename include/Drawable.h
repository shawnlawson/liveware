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
    ci::Color c;
    float radians;
//    float r, g, b, a;
    

    Drawable(){}
    
    virtual void print(sol::this_state ts){}
    
    virtual void draw(){}
    
};


#endif /* Drawable_h */
