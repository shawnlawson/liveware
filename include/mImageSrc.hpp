//
//  mImageSrc.h
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 11/5/17.
//
//

#ifndef mImageSrc_h
#define mImageSrc_h

class mImageSrc {
    
public:
    
    std::vector<ci::gl::Texture2dRef> images;
    int numImages = 0;
    
    mImageSrc(){}
    
    //not safe against non-images and angry files
    mImageSrc(std::string filename)
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
                
                numImages = i;
                
            } else {
                if (images.size() > 0)
                    images.clear();
                
                auto format = ci::gl::Texture::Format{};
                format.loadTopDown(false);
                images.push_back(ci::gl::Texture::create(
                                                         ci::loadImage(
                                                                       ci::app::loadAsset(filename)
                                                                       ), format));
                numImages = 1;
                images[0]->setTopDown(true);
            }
            
        } //end file exists
    } //end open

    
    void print(sol::this_state ts)
    {
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj, 'open(filname.ext or directory)')");
    }
    
    
};

#endif /* mImageSrc_h */
