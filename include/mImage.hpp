//
//  mImage.h
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 9/28/17.
//
//

#include "Drawable.hpp"
#include "mImageSrc.hpp"

#ifndef mImage_h
#define mImage_h

class mImage : public Drawable{

private:
    int image = - 1;

public:
    
    mImageSrc *images = nil;
    float w;
    float h;
    
    
    mImage() : Drawable() {
        w = 100.f;
        h = 100.f;
        images = nil;
    }
    
    mImage(mImageSrc *imageSrc) : Drawable() {
        w = 100.f;
        h = 100.f;
        images = imageSrc;
        setImage(1);
    }
    
    mImage(float width, float height, mImageSrc *imageSrc) : Drawable() {
        w = width;
        h = height;
        images = imageSrc;
        setImage(1);
    }
    
    bool setImage(float which){
//        return setImage((int)which);
//    }
    
//    bool setImage(int which){
        int whichOne = (int)which;
        if( images == NULL)
            return false;
        if (0 == images->numImages)
            return false;
        else if (images->numImages < which)
            return false;
        else if (whichOne < 1)
            return false;
        else
            image = whichOne - 1;
        
        return true;
    }
    
    int getImage(){
        return image;
    }
    
    virtual void print(sol::this_state ts) override
    {
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj, ' \t w = float \t h = float')");
    }
    
    virtual void draw() override
    {
        if (image >= 0 && images != NULL) {
            w = images->images[image]->getWidth();
            h = images->images[image]->getHeight();
        }
        ci::gl::color(c.r, c.g, c.b, a);
        ci::gl::ScopedModelMatrix modelScope;
        if (image >= 0&& images != NULL) {
            ci::gl::translate(p);
            ci::gl::pushModelView();
            ci::gl::rotate(radians, r);
            ci::gl::scale(s);
            ci::gl::translate(-w*.5, -h*.5, 0);
            ci::gl::draw(images->images[image]);
            ci::gl::popModelView();
        }else {
            ci::gl::translate(p);
            ci::gl::rotate(radians, r);
            ci::gl::scale(s);
              ci::Rectf rect = ci::Rectf(-w*.5, -h*.5, w*.5, h*.5);
            ci::gl::drawSolidRect(rect);
        }
        

    }
    
    
};


#endif /* mImage_h */
