//
//  mImage.h
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 9/28/17.
//
//

#include "Drawable.hpp"

#ifndef mImage_h
#define mImage_h

class mImage : public Drawable{

private:
    int image = -1;

public:
    
    float w, h;
    std::vector<ci::gl::Texture2dRef> images;
    
    
    
    mImage() : Drawable() {
        w = h = 100.f;
    }
    
    //not safe against non-images and angry files
    void open(std::string filename)
    {
        //TODO, get proper filepath separator
        ci::fs::path p(ci::app::getAssetPath("").string() + "/" + filename);
        if (ci::fs::exists(p))
        {
            if (ci::fs::is_directory(p) )
            {
                if (images.size() > 0)
                    images.clear();
            
                int i = 0;
                for (ci::fs::directory_iterator itr(p); itr!=ci::fs::directory_iterator(); ++itr)
                {
                    std::cout << itr->path().filename() << std::endl;
                    
                    std::string fileToLoad = filename + "/" + itr->path().filename().string();
                    
                    auto format = ci::gl::Texture::Format{};
                    format.loadTopDown(false);
                    images.push_back(ci::gl::Texture::create(
                                                             ci::loadImage(
                                                           ci::app::loadAsset(fileToLoad)
                                                           ), format));
                    images[i]->setTopDown(true);
                    i++;
                }
                
                image = 0;
                
            } else {
                if (images.size() > 0)
                    images.clear();
                
                auto format = ci::gl::Texture::Format{};
                format.loadTopDown(false);
                images.push_back(ci::gl::Texture::create(
                                                         ci::loadImage(
                                                                       ci::app::loadAsset(filename)
                                                                       ), format));
                image = 0;
                images[0]->setTopDown(true);
            }
            
        } //end file exists
    } //end open
    
    bool setImage(int which){
        int num = images.size();
        if (0 == num)
            return false;
        else if (num < which)
            return false;
        else if (which < 1)
            return false;
        else
            image = which - 1;
        
        return true;
    }
    
    virtual void print(sol::this_state ts) override
    {
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj, 'open(filname.ext or directory) \t w = float \t h = float')");
    }
    
    virtual void draw() override
    {
        if (image >= 0) {
            w = images[image]->getWidth();
            h = images[image]->getHeight();
        }
        ci::gl::color(c.r, c.g, c.b, a);
        ci::gl::ScopedModelMatrix modelScope;
        ci::gl::translate(p - ci::vec3(w, h, 0.0f) * 0.5f);
        ci::gl::rotate(radians, r);
        ci::gl::scale(s);
      
        //TODO:: not centered?
        
        
        if (image >= 0)
            ci::gl::draw(images[image]);
        else {
            ci::Rectf rect = ci::Rectf(0, 0, w, h);
            ci::gl::drawSolidRect(rect);
        }
        
    }
    
    
};


#endif /* mImage_h */
