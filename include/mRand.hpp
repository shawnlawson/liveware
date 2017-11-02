//
//  mRand.h
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 10/7/17.
//
//

#include "glm/gtc/random.hpp"
#include "cinder/Rand.h"

#ifndef mRand_h
#define mRand_h

class mRand {
    
public:

    
    float linear(float min, float max) { return glm::linearRand(min, max); }
    
    float gauss(float mean, float dev) { return glm::gaussRand(mean, dev); }
    
    ci::vec2 circular(float radius) { return glm::circularRand(radius); }
    
    ci::vec3 spherical(float radius) { return glm::sphericalRand(radius); }
    
    ci::vec2 disk(float radius) { return glm::diskRand(radius); }
    
    ci::vec3 ball(float radius) { return glm::ballRand(radius); }
    
    void print(sol::this_state ts){
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj,'float<-linear(float min, float max) \t float<-gauss(float mean, float dev) \t vec2<-circular(float) \t vec3<-spherical(float) \t vec2<-disk(float) \t vec3<-ball(float)')");
    }

};
#endif /* mRand_h */
