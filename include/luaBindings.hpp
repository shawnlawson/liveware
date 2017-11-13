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

#ifndef luaBindings_hpp
#define luaBindings_hpp

class LuaBindings {
    
    
public:
    void bind(sol::state *lua);
};

#endif /* luaBindings_hpp */
