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

    float x, y, z;
    float rX, rY, rZ;
    float radians;
    float sX, sY, sZ;
    float r, g, b, a;
    

    Drawable(){}
    
    virtual void print(sol::this_state ts){}
    
    virtual void draw(){}
    
};


#endif /* Drawable_h */
