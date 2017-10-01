//
//  mImage.h
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 9/28/17.
//
//

#ifndef mImage_h
#define mImage_h

class mImage : public Drawable{

private:
    int image = -1;

public:
    
    bool outline;
    float lineWidth;
    float w, h;
    std::vector<ci::gl::Texture2dRef> images;
    
    
    
    mImage() : Drawable() {
        x = ci::app::getWindowCenter().x;
        y = ci::app::getWindowCenter().y;
        z = rX = rY = 0.0f;
        sX = sY = sZ = rZ = 1.0f;
        radians = 0.0f;
        w = h = 100.f;
        r = g = b = a = 1.0f;
    }
    
    
    void open(std::string filename)
    {
        //TODO, get proper filepath separator
        ci::fs::path p(ci::app::getAssetPath("").string() + "/" + filename);
        if (ci::fs::exists(p))
        {
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
         else if (ci::fs::is_directory(p) )
        {
            if (images.size() > 0)
                images.clear();
        
            
        }
        
        
    }
    
                             
    
    virtual void print(sol::this_state ts) override
    {
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj, 'x, y, radians')");
    }
    
    virtual void draw() override
    {
        ci::gl::color(r, g, b, a);
        ci::gl::ScopedModelMatrix modelScope;
        ci::gl::translate(ci::vec3(x - w*.5, y - h* .5, z));
        ci::gl::rotate(radians, ci::vec3(rX, rY, rZ));
        ci::gl::scale(ci::vec3(sX, sY, sZ));
        if (image >= 0) {
            w = images[image]->getWidth();
            h = images[image]->getHeight();
        }
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
