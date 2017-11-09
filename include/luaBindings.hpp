//
//  luaBindings.hpp
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 10/9/17.
//
//

#define __OBJC__

#define SOL_CHECK_ARGUMENTS
#include "sol.hpp"


#include "cinder/CinderMath.h"
#include "cinder/Perlin.h"
#include "cinder/Rand.h"
#include "cinder/Easing.h"

#include "Drawable.hpp"
#include "mCircle.hpp"
#include "mRectangle.hpp"
#include "mImageSrc.hpp"
#include "mImage.hpp"
#include "mLine.hpp"
#include "mRand.hpp"
#include "mCube.hpp"
#include "mSphere.hpp"


#include "PostProcess.h"
#include "BuiltinPostProcesses.h"


#ifndef luaBindings_hpp
#define luaBindings_hpp

class LuaBindings {
    
    
public:
    void bind(sol::state *lua);
};

#endif /* luaBindings_hpp */
