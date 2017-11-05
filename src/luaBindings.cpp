//
//  luaBindings.cpp
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 10/9/17.
//
//

#include "luaBindings.hpp"



void luaBindings::bind(sol::state *lua)
{
    
    lua->set_function("easeInQuad", &ci::easeInQuad);
    lua->set_function("easeOutQuad", &ci::easeOutQuad);
    lua->set_function("easeInOutQuad", &ci::easeInOutQuad);
    lua->set_function("easeOutInQuad", &ci::easeOutInQuad);
    lua->set_function("easeInCubic", &ci::easeInCubic);
    lua->set_function("easeOutCubic", &ci::easeOutCubic);
    lua->set_function("easeInOutCubic", &ci::easeInOutCubic);
    lua->set_function("easeOutInCubic", &ci::easeOutInCubic);
    lua->set_function("easeInQuart", &ci::easeInQuart);
    lua->set_function("easeOutQuart", &ci::easeOutQuart);
    lua->set_function("easeInOutQuart", &ci::easeInOutQuart);
    lua->set_function("easeOutInQuart", &ci::easeOutInQuart);
    lua->set_function("easeInQuint", &ci::easeInQuint);
    lua->set_function("easeOutQuint", &ci::easeOutQuint);
    lua->set_function("easeInOutQuint", &ci::easeInOutQuint);
    lua->set_function("easeOutInQuint", &ci::easeOutInQuint);
    lua->set_function("easeInSine", &ci::easeInSine);
    lua->set_function("easeOutSine", &ci::easeOutSine);
    lua->set_function("easeInOutSine", &ci::easeInOutSine);
    lua->set_function("easeOutInSine", &ci::easeOutInSine);
    lua->set_function("easeInExpo", &ci::easeInExpo);
    lua->set_function("easeOutExpo", &ci::easeOutExpo);
    lua->set_function("easeInOutExpo", &ci::easeInOutExpo);
    lua->set_function("easeOutInExpo", &ci::easeOutInExpo);
    lua->set_function("easeInCirc", &ci::easeInCirc);
    lua->set_function("easeOutCirc", &ci::easeOutCirc);
    lua->set_function("easeInOutCirc", &ci::easeInOutCirc);
    lua->set_function("easeOutInCirc", &ci::easeOutInCirc);
    lua->set_function("easeInBounce", &ci::easeInBounce); //time, 1->7
    lua->set_function("easeOutBounce", &ci::easeOutBounce);
    lua->set_function("easeInOutBounce", &ci::easeInOutBounce);
    lua->set_function("easeOutInBounce", &ci::easeOutInBounce);
    lua->set_function("easeInBack", &ci::easeInBack);
    lua->set_function("easeOutBack", &ci::easeOutBack);
    lua->set_function("easeInOutBack", &ci::easeInOutBack);
    lua->set_function("easeOutInBack", &ci::easeOutInBack);
    lua->set_function("easeInElastic", &ci::easeInElastic); //time, amplitude, period
    lua->set_function("easeOutElastic", &ci::easeOutElastic);
    lua->set_function("easeInOutElastic", &ci::easeInOutElastic);
    lua->set_function("easeOutInElastic", &ci::easeOutInElastic);
    lua->set_function("easeInAtan", &ci::easeInAtan); //time, 15
    lua->set_function("easeOutAtan", &ci::easeOutAtan);
    lua->set_function("easeInOutAtan", &ci::easeInOutAtan);
    
    //GLM Math
    
    lua->set_function("toRadians", sol::overload(sol::resolve<float(float)>(&ci::toRadians))); //check glm for options
    lua->set_function("toDegrees", sol::overload(sol::resolve<float(float)>(&ci::toDegrees)));
    lua->set_function("lerp", sol::overload(sol::resolve<int(const int &, const int &, int)>(&ci::lerp),
                                            sol::resolve<float(const float &, const float &, float)>(&ci::lerp)
                                            )
                      );
    lua->set_function("lmap", sol::overload(sol::resolve<int(int, int , int, int, int)>(&ci::lmap),
                                            sol::resolve<float(float, float, float, float, float)>(&ci::lmap)
                                            )
                      );
    lua->set_function("constrain", sol::overload(sol::resolve<int(int, int, int)>(&ci::constrain),
                                                 sol::resolve<float(float, float, float)>(&ci::constrain)
                                                 )
                      );
    //there's a lot more in cinderMath we're not using yet.
    
    lua->set_function("length", sol::overload(sol::resolve<float(const ci::vec2 &)>(&glm::length),
                                              sol::resolve<float(const ci::vec3 &)>(&glm::length),
                                              sol::resolve<float(const ci::vec4 &)>(&glm::length)
                                              )
                      );
    lua->set_function("distance", sol::overload(sol::resolve<float(const ci::vec2& l, const ci::vec2& r)>(&glm::distance),
                                                sol::resolve<float(const ci::vec3& l, const ci::vec3& r)>(&glm::distance),
                                                sol::resolve<float(const ci::vec4& l, const ci::vec4& r)>(&glm::distance)
                                                )
                      );
    lua->set_function("dot", sol::overload(sol::resolve<float(const ci::vec3& l, const ci::vec3& r)>(&glm::dot),
                                           sol::resolve<float(const ci::vec4& l, const ci::vec4& r)>(&glm::dot)
                                           )
                      );
    lua->set_function("normalize", sol::overload(sol::resolve<ci::vec2(const ci::vec2&)>(&glm::normalize),
                                                 sol::resolve<ci::vec3(const ci::vec3&)>(&glm::normalize),
                                                 sol::resolve<ci::vec4(const ci::vec4& )>(&glm::normalize)
                                                 )
                      );
    lua->set_function("cross", sol::overload(sol::resolve<ci::vec3(const ci::vec3& l, const ci::vec3& r)>(&glm::cross)
                                             )
                      );
    lua->set_function("faceForward", sol::overload(sol::resolve<ci::vec3(const ci::vec3& N, const ci::vec3& I, const ci::vec3& Nref)>(&glm::faceforward)
                                                   )
                      );
    lua->set_function("refract", sol::overload(sol::resolve<ci::vec3(const ci::vec3& I, const ci::vec3& N, float eta)>(&glm::refract)
                                               )
                      );
    lua->set_function("abs", sol::overload(sol::resolve<int(const int)>(&glm::abs),
                                           sol::resolve<float(float)>(&glm::abs),
                                           sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::abs),
                                           sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::abs),
                                           sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::abs)
                                           )
                      );
    lua->set_function("acos", sol::overload(sol::resolve<float(const float)>(&glm::acos),
                                            sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::acos),
                                            sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::acos),
                                            sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::acos)
                                            )
                      );
    lua->set_function("asin", sol::overload(sol::resolve<float(const float)>(&glm::asin),
                                            sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::asin),
                                            sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::asin),
                                            sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::asin)
                                            )
                      );
    lua->set_function("atan", sol::overload(sol::resolve<float(const float)>(&glm::atan),
                                            sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::atan),
                                            sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::atan),
                                            sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::atan)
                                            )
                      );
    
    lua->set_function("cos", sol::overload(sol::resolve<float(const float)>(&glm::cos),
                                           sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::cos),
                                           sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::cos),
                                           sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::cos)
                                           )
                      );
    lua->set_function("cosh", sol::overload(sol::resolve<float(const float)>(&glm::cosh),
                                            sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::cosh),
                                            sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::cosh),
                                            sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::cosh)
                                            )
                      );
    lua->set_function("sin", sol::overload(sol::resolve<float(const float)>(&glm::sin),
                                           sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::sin),
                                           sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::sin),
                                           sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::sin)
                                           )
                      );
    lua->set_function("sinh", sol::overload(sol::resolve<float(const float)>(&glm::sinh),
                                            sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::sinh),
                                            sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::sinh),
                                            sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::sinh)
                                            )
                      );
    lua->set_function("tan", sol::overload(sol::resolve<float(const float)>(&glm::tan),
                                           sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::tan),
                                           sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::tan),
                                           sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::tan)
                                           )
                      );
    lua->set_function("tanh", sol::overload(sol::resolve<float(const float)>(&glm::tanh),
                                            sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::tanh),
                                            sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::tanh),
                                            sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::tanh)
                                            )
                      );
    lua->set_function("exp", sol::overload(sol::resolve<float(const float)>(&glm::exp),
                                           sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::exp),
                                           sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::exp),
                                           sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::exp)
                                           )
                      );
    lua->set_function("exp2", sol::overload(sol::resolve<float(const float)>(&glm::exp2),
                                            sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::exp2),
                                            sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::exp2),
                                            sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::exp2)
                                            )
                      );
    lua->set_function("log", sol::overload(sol::resolve<float(const float)>(&glm::log),
                                           sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::log),
                                           sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::log),
                                           sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::log)
                                           )
                      );
    lua->set_function("log2", sol::overload(sol::resolve<float(const float)>(&glm::log2),
                                            sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::log2),
                                            sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::log2),
                                            sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::log2)
                                            )
                      );
    lua->set_function("pow", sol::overload(sol::resolve<float(const float, const float)>(&glm::pow),
                                           sol::resolve<ci::vec2(const ci::vec2 &, const ci::vec2 &)>(&glm::pow),
                                           sol::resolve<ci::vec3(const ci::vec3 &, const ci::vec3 &)>(&glm::pow),
                                           sol::resolve<ci::vec4(const ci::vec4 &, const ci::vec4 &)>(&glm::pow)
                                           )
                      );
    lua->set_function("sqrt", sol::overload(sol::resolve<float(const float)>(&glm::sqrt),
                                            sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::sqrt),
                                            sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::sqrt),
                                            sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::sqrt)
                                            )
                      );
    lua->set_function("inversesqrt", sol::overload(sol::resolve<float(const float)>(&glm::inversesqrt),
                                                   sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::inversesqrt),
                                                   sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::inversesqrt),
                                                   sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::inversesqrt)
                                                   )
                      );
    lua->set_function("sign", sol::overload(sol::resolve<int(const int)>(&glm::sign),
                                            sol::resolve<float(const float)>(&glm::sign),
                                            sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::sign),
                                            sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::sign),
                                            sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::sign)
                                            )
                      );
    lua->set_function("floor", sol::overload(sol::resolve<float(float)>(&floorf),
                                             sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::floor),
                                             sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::floor),
                                             sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::floor)
                                             )
                      );
    lua->set_function("trunc", sol::overload(sol::resolve<float(const float)>(&glm::trunc),
                                             sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::trunc),
                                             sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::trunc),
                                             sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::trunc)
                                             )
                      );
    lua->set_function("round", sol::overload(sol::resolve<float(const float)>(&glm::round),
                                             sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::round),
                                             sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::round),
                                             sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::round)
                                             )
                      );
    lua->set_function("roundEven", sol::overload(sol::resolve<float(const float)>(&glm::roundEven),
                                                 sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::roundEven),
                                                 sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::roundEven),
                                                 sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::roundEven)
                                                 )
                      );
    lua->set_function("ceil", sol::overload(sol::resolve<float(const float)>(&glm::ceil),
                                            sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::ceil),
                                            sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::ceil),
                                            sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::ceil)
                                            )
                      );
    lua->set_function("fract", sol::overload(sol::resolve<float(const float)>(&glm::fract),
                                             sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::fract),
                                             sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::fract),
                                             sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::fract)
                                             )
                      );
    lua->set_function("mod", sol::overload(sol::resolve<float(const float, const float)>(&glm::mod),
                                           sol::resolve<ci::vec2(const ci::vec2 &, const ci::vec2 &)>(&glm::mod),
                                           sol::resolve<ci::vec3(const ci::vec3 &, const ci::vec3 &)>(&glm::mod),
                                           sol::resolve<ci::vec4(const ci::vec4 &, const ci::vec4 &)>(&glm::mod)
                                           )
                      );
    //                                               sol::resolve<float(const float, const float &)>(&glm::modf),
    lua->set_function("min", sol::overload(sol::resolve<int(const int, const int)>(&glm::min),
                                           sol::resolve<float(const float, const float)>(&glm::min),
                                           sol::resolve<ci::vec2(const ci::vec2 &, const ci::vec2 &)>(&glm::min),
                                           sol::resolve<ci::vec3(const ci::vec3 &, const ci::vec3 &)>(&glm::min),
                                           sol::resolve<ci::vec4(const ci::vec4 &, const ci::vec4 &)>(&glm::min)
                                           )
                      );
    lua->set_function("max", sol::overload(sol::resolve<int(const int, const int)>(&glm::max),
                                           sol::resolve<float(const float, const float)>(&glm::max),
                                           sol::resolve<ci::vec2(const ci::vec2 &, const ci::vec2 &)>(&glm::max),
                                           sol::resolve<ci::vec3(const ci::vec3 &, const ci::vec3 &)>(&glm::max),
                                           sol::resolve<ci::vec4(const ci::vec4 &, const ci::vec4 &)>(&glm::max)
                                           )
                      );
    lua->set_function("clamp", sol::overload(sol::resolve<float(const float, const float, const float)>(&glm::clamp),
                                             sol::resolve<ci::vec2(const ci::vec2 &, const ci::vec2 &, const ci::vec2 &)>(&glm::clamp),
                                             sol::resolve<ci::vec2(const ci::vec2 &, const float, const float)>(&glm::clamp),
                                             sol::resolve<ci::vec3(const ci::vec3 &, const ci::vec3 &, const ci::vec3 &)>(&glm::clamp),
                                             sol::resolve<ci::vec3(const ci::vec3 &, const float, const float)>(&glm::clamp),
                                             sol::resolve<ci::vec4(const ci::vec4 &, const ci::vec4 &, const ci::vec4 &)>(&glm::clamp),
                                             sol::resolve<ci::vec4(const ci::vec4 &, const float, const float)>(&glm::clamp)
                                             )
                      );
    lua->set_function("mix", sol::overload(sol::resolve<float(const float, const float, const float)>(&glm::mix),
                                           sol::resolve<ci::vec2(const ci::vec2 &, const ci::vec2 &, const ci::vec2 &)>(&glm::mix),
                                           sol::resolve<ci::vec2(const ci::vec2 &, const ci::vec2 &, const float)>(&glm::mix),
                                           sol::resolve<ci::vec3(const ci::vec3 &, const ci::vec3 &, const ci::vec3 &)>(&glm::mix),
                                           sol::resolve<ci::vec3(const ci::vec3 &, const ci::vec3 &, const float)>(&glm::mix),
                                           sol::resolve<ci::vec4(const ci::vec4 &, const ci::vec4 &, const ci::vec4 &)>(&glm::mix),
                                           sol::resolve<ci::vec4(const ci::vec4 &, const ci::vec4 &, const float)>(&glm::mix)
                                           )
                      );
    lua->set_function("step", sol::overload([](const float e, const float x){if (x < e) return 0.0f; else return 1.0f;},
                                            sol::resolve<ci::vec2(const float, const ci::vec2 &)>(&ci::step),
                                            sol::resolve<ci::vec2(const ci::vec2 &, const ci::vec2 &)>(&ci::step),
                                            sol::resolve<ci::vec3(const float, const ci::vec3 &)>(&ci::step),
                                            sol::resolve<ci::vec3(const ci::vec3 &, const ci::vec3 &)>(&ci::step),
                                            sol::resolve<ci::vec4(const float, const ci::vec4 &)>(&ci::step),
                                            sol::resolve<ci::vec4(const ci::vec4 &, const ci::vec4 &)>(&ci::step)
                                            )
                      );
    lua->set_function("smoothstep", sol::overload(sol::resolve<float(const float, const float, const float)>(&glm::smoothstep),
                                                  sol::resolve<ci::vec2(const float, const float, const ci::vec2 &)>(&ci::smoothstep),
                                                  sol::resolve<ci::vec2(const ci::vec2 &, const ci::vec2 &, const ci::vec2 &)>(&ci::smoothstep),
                                                  sol::resolve<ci::vec3(const float, const float, const ci::vec3 &)>(&ci::smoothstep),
                                                  sol::resolve<ci::vec3(const ci::vec3 &, const ci::vec3 &, const ci::vec3 &)>(&ci::smoothstep),
                                                  sol::resolve<ci::vec4(const float, const float, const ci::vec4 &)>(&ci::smoothstep),
                                                  sol::resolve<ci::vec4(const ci::vec4 &, const ci::vec4 &, const ci::vec4 &)>(&ci::smoothstep)
                                                  )
                      );
    lua->set_function("isnan", sol::overload(sol::resolve<glm::bvec2(const ci::vec2 &)>(&glm::isnan),
                                             sol::resolve<glm::bvec3(const ci::vec3 &)>(&glm::isnan),
                                             sol::resolve<glm::bvec4(const ci::vec4 &)>(&glm::isnan)
                                             )
                      );
    //etc to end of glm::func_common.hpp
    
    lua->set_function("hsvToRgb", [](const ci::vec3 &hsv){
        float hue = hsv.x;
        float sat = hsv.y;
        float val = hsv.z;
        
        float x = 0.0f, y = 0.0f, z = 0.0f;
        
        if( hue == 1 ) hue = 0;
        else
            hue *= 6;
        
        int i = static_cast<int>( floorf( hue ) );
        float f = hue - i;
        float p = val * ( 1 - sat );
        float q = val* ( 1 - ( sat * f ) );
        float t = val* ( 1 - ( sat * ( 1 - f ) ) );
        
        switch( i ) {
            case 0: x = val; y = t; z = p; break;
            case 1: x = q; y = val; z = p; break;
            case 2: x = p; y = val; z = t; break;
            case 3: x = p; y = q; z = val; break;
            case 4: x = t; y = p; z = val; break;
            case 5: x = val; y = p; z = q; break;
        }
        return ci::vec3(x, y, z);
    });
    
    lua->set_function("rgbToHsv", [](const ci::vec3 &c){const float &x = c.r;
        const float &y = c.g;
        const float &z = c.b;
        
        float max = (x > y) ? ((x > z) ? x : z) : ((y > z) ? y : z);
        float min = (x < y) ? ((x < z) ? x : z) : ((y < z) ? y : z);
        float range = max - min;
        float val = max;
        float sat = 0;
        float hue = 0;
        
        if( max != 0 )
            sat = range/max;
        
        if( sat != 0 ) {
            float h;
            
            if( x == max )
                h = (y - z) / range;
            else if( y == max )
                h = 2 + ( z - x ) / range;
            else
                h = 4 + ( x - y ) / range;
            
            hue = h / 6.0f;
            
            if( hue < 0.0f )
                hue += 1.0f;
        }
        
        return ci::vec3( hue, sat, val );
    });
    
    
    lua->new_usertype<ci::vec2>("vec2",
                                sol::constructors<ci::vec2(), ci::vec2(float), ci::vec2(float, float)>(),
                                "__add", sol::overload([](const float l, const ci::vec2 & r) {return l + r; },
                                                       [](const ci::vec2& l, const float & r) {return l + r; },
                                                       [](const ci::vec2& l, const ci::vec2& r) { return l + r; }
                                                       ),
                                "__sub",  sol::overload([](const float l, const ci::vec2 & r) {return l - r; },
                                                        [](const ci::vec2& l, const float & r) {return l - r; },
                                                        [](const ci::vec2& l, const ci::vec2& r) { return l - r; }
                                                        ),
                                "__mul",  sol::overload([](const float l, const ci::vec2 & r) {return l * r; },
                                                        [](const ci::vec2& l, const float & r) {return l * r; },
                                                        [](const ci::vec2& l, const ci::vec2& r) { return l * r; }
                                                        ),
                                "__div",  sol::overload([](const float l, const ci::vec2 & r) {return l / r; },
                                                        [](const ci::vec2& l, const float & r) {return l / r; },
                                                        [](const ci::vec2& l, const ci::vec2& r) { return l / r; }
                                                        ),
                                "__mod",  sol::overload([](const ci::vec2& l, const float & r) {return glm::mod(l, r); },
                                                        [](const ci::vec2& l, const ci::vec2& r) { return glm::mod(l, r); }
                                                        ),
                                //swizzles?
                                "x", &ci::vec2::x,
                                "y", &ci::vec2::y);
    
    lua->new_usertype<ci::vec3>("vec3",
                                sol::constructors<ci::vec3(), ci::vec3(float), ci::vec3(float, float, float)>(),
                                "__add", sol::overload([](const float l, const ci::vec3 & r) {return l + r; },
                                                       [](const ci::vec3& l, const float & r) {return l + r; },
                                                       [](const ci::vec3& l, const ci::vec3& r) { return l + r; }
                                                       ),
                                "__sub", sol::overload([](const float l, const ci::vec3 & r) {return l - r; },
                                                       [](const ci::vec3& l, const float & r) {return l - r; },
                                                       [](const ci::vec3& l, const ci::vec3& r) { return l - r; }
                                                       ),
                                "__mul", sol::overload([](const float l, const ci::vec3 & r) {return l * r; },
                                                       [](const ci::vec3& l, const float & r) {return l * r; },
                                                       [](const ci::vec3& l, const ci::vec3& r) { return l * r; }
                                                       ),
                                "__div", sol::overload([](const float l, const ci::vec3 & r) {return l / r; },
                                                       [](const ci::vec3& l, const float & r) {return l / r; },
                                                       [](const ci::vec3& l, const ci::vec3& r) { return l / r; }
                                                       ),
                                "__mod", sol::overload([](const ci::vec3& l, const float & r) {return glm::mod(l,  r); },
                                                       [](const ci::vec3& l, const ci::vec3& r) { return glm::mod(l, r); }
                                                       ),
                                //swizzles?
                                //colors references from css3 here:
                                // https://developer.mozilla.org/en-US/docs/Web/CSS/color_value
                                //using
                                // http://corecoding.com/utilities/rgb-or-hex-to-float.php
//                                "black", [](){return ci::vec3(0.0f, 0.0f, 0.0f);},
//                                "silver", [](){return ci::vec3(.753f, .753f, .753f);},
//                                "gray", [](){return ci::vec3(.5f, .5f, .5f);},
//                                "white", [](){return ci::vec3(1.0f, 1.0f, 1.0f);},
//                                "maroon", [](){return ci::vec3(.5f, 0.0f, 0.0f);},
//                                "red", [](){return ci::vec3(1.0f, 0.0f, 0.0f);},
//                                "purple", [](){return ci::vec3(0.5f, 0.0f, 0.5f);},
//                                "fuchia", [](){return ci::vec3(1.0f, 0.0f, 1.0f);},
//                                "green", [](){return ci::vec3(0.0f, 0.5f, 0.0f);},
//                                "lime", [](){return ci::vec3(0.0f, 1.0f, 0.0f);},
//                                "olive", [](){return ci::vec3(0.5f, 0.5f, 0.0f);},
//                                "yellow", [](){return ci::vec3(1.0f, 1.0f, 0.0f);},
//                                "navy", [](){return ci::vec3(0.0f, 0.0f, 0.5f);},
//                                "blue", [](){return ci::vec3(0.0f, 0.0f, 1.0f);},
//                                "teal", [](){return ci::vec3(0.0f, 0.5f, 0.5f);},
//                                "aqua", [](){return ci::vec3(0.0f, 1.0f, 1.0f);},
//                                "orange", [](){return ci::vec3(1.0f, 0.647f, 0.0f);},
//                                "aliceBlue", [](){return ci::vec3(0.941f, 0.973f, 1.0f);},
//                                "antiqueWhite", [](){return ci::vec3(0.98f, 0.922f, 0.843f);},
//                                "aquaMarine", [](){return ci::vec3(0.498f, 1.0f, 0.831f);},
//                                "azure", [](){return ci::vec3(0.9411f, 1.0f, 1.0f);},
//                                "beige", [](){return ci::vec3(0.961f, 0.961f, 0.863f);},
//                                "bisque", [](){return ci::vec3(1.0f, 0.894f, 0.769f);},
//                                "blanchedAlmond", [](){return ci::vec3(1.0f, 0.922f, 0.804f);},
//                                "blueViolet", [](){return ci::vec3(0.541f, 0.169f, 0.886f);},
//                                "brown", [](){return ci::vec3(0.647f, 0.165f, 0.165f);},
//                                "burlyWood", [](){return ci::vec3(0.871f, 0.722f, 0.529f);},
//                                "cadetBlue", [](){return ci::vec3(0.373f, 0.62f, 0.627f);},
//                                "chartreuse", [](){return ci::vec3(0.498f, 1.0f, 0.0f);},
//                                "chocolate", [](){return ci::vec3(0.824f, 0.412f, 0.118f);},
//                                "coral", [](){return ci::vec3(1.0f, 0.498f, 0.314f);},
//                                "cornflowerBlue", [](){return ci::vec3(0.392f, 0.584f, 0.929f);},
//                                "cornsilk", [](){return ci::vec3(1.0f, 0.973f, 0.863f);},
//                                "crimson", [](){return ci::vec3(0.863f, 0.078f, 0.235f);},
//                                "cyan", [](){return ci::vec3(0.0f, 1.0f, 1.0f);},
//                                "darkBlue", [](){return ci::vec3(0.0f, 0.0f, 0.545f);},
//                                "darkCyan", [](){return ci::vec3(0.0f, 0.545f, 0.545f);},
//                                "darkGoldenrod", [](){return ci::vec3(0.722f, 0.525f, .043f);},
//                                "darkGray", [](){return ci::vec3(0.663f, 0.663f, 0.663f);},
//                                "darkGreen", [](){return ci::vec3(0.0f, 0.392f, 0.0f);},
//                                "darkKhaki", [](){return ci::vec3(0.741f, 0.718f, 0.42f);},
//                                "darkMagenta", [](){return ci::vec3(0.545f, 0.0f, 0.545f);},
//                                "darkOliveGreen", [](){return ci::vec3(0.333f, 0.42f, 0.184f);},
//                                "darkOrange", [](){return ci::vec3(1.0f, 0.549f, 0.0f);},
//                                "darkOrchid", [](){return ci::vec3(0.6f, 0.196f, 0.8f);},
//                                "darkRed", [](){return ci::vec3(0.545f, 0.0f, 0.0f);},
//                                "darkSalmon", [](){return ci::vec3(0.914f, 0.588f, 0.478f);},
//                                "darkSeaGreen", [](){return ci::vec3(0.561f, 0.737f, 0.561f);},
//                                "darkSlateBlue", [](){return ci::vec3(0.282f, 0.239f, .545f);},
//                                "darkSlateGray", [](){return ci::vec3(0.184f, 0.31f, 0.31f);},
//                                "darkTurquoise", [](){return ci::vec3(0.0f, 0.808f, 0.82f);},
//                                "darkViolet", [](){return ci::vec3(0.58f, 0.0f, 0.827f);},
//                                "deepPink", [](){return ci::vec3(1.0f, 0.078f, 0.576f);},
//                                "deepSkyBlue", [](){return ci::vec3(0.0f, 0.749f, 1.0f);},
//                                "dimGray", [](){return ci::vec3(0.412f, 0.412f, 0.412f);},
//                                "dodgerBlue", [](){return ci::vec3(0.118f, 0.565f, 1.0f);},
//                                "fireBrick", [](){return ci::vec3(0.698f, 0.133f, 0.133f);},
//                                "floralWhite", [](){return ci::vec3(1.0f, 0.98f, 0.941f);},
//                                "forestGreen", [](){return ci::vec3(0.133f, 0.545f, 0.133f);},
//                                "gainsboro", [](){return ci::vec3(0.863f, 0.863f, 0.863f);},
//                                "ghostWhite", [](){return ci::vec3(0.973f, 0.973f, 1.0f);},
//                                "gold", [](){return ci::vec3(1.0f, 0.843f, 0.0f);},
//                                "goldenrod", [](){return ci::vec3(0.855f, 0.647f, 0.125f);},
//                                "greenYellow", [](){return ci::vec3(0.678f, 1.0f, 0.184f);},
//                                "gray", [](){return ci::vec3(0.5f, 0.5f, 0.5f);},
//                                "honeydew", [](){return ci::vec3(0.941f, 1.0f, 0.941f);},
//                                "hotPink", [](){return ci::vec3(1.0f, 0.412f, 0.706f);},
//                                "indianRed", [](){return ci::vec3(0.804f, 0.361f, 0.361f);},
//                                "indigo", [](){return ci::vec3(0.294f, 0.0f, 0.51f);},
//                                "ivory", [](){return ci::vec3(1.0f, 1.0f, 0.941f);},
//                                "khaki", [](){return ci::vec3(0.941f, 0.902f, 0.549f);},
//                                "lavender", [](){return ci::vec3(0.902f, 0.902f, 0.98f);},
//                                "lavenderBlush", [](){return ci::vec3(1.0f, 0.941f, 0.961f);},
//                                "lawnGreen", [](){return ci::vec3(0.486f, 0.988f, 0.0f);},
//                                "lemonChiffon", [](){return ci::vec3(1.0f, 0.98f, 0.804f);},
//                                "lightBlue", [](){return ci::vec3(0.678f, 0.847f, 0.902f);},
//                                "lightCoral", [](){return ci::vec3(0.941f, 0.502f, 0.502f);},
//                                "lightCyan", [](){return ci::vec3(0.878f, 1.0f, 1.0f);},
//                                "lightGoldenrod", [](){return ci::vec3(0.98f, 0.98f, 0.824f);},
//                                "lightGray", [](){return ci::vec3(0.827f, 0.827f, 0.827f);},
//                                "lightGreen", [](){return ci::vec3(0.565f, 0.933f, 0.565f);},
//                                "lightPink", [](){return ci::vec3(1.0f, 0.714f, 0.757f);},
//                                "lightSalmon", [](){return ci::vec3(1.0f, 0.627f, 0.478f);},
//                                "lightSeaGreen", [](){return ci::vec3(0.125f, 0.698f, 0.667f);},
//                                "lightSkyBlue", [](){return ci::vec3(0.529f, 0.808f, 0.98f);},
//                                "lightSlateGray", [](){return ci::vec3(0.567f, 0.533f, 0.6f);},
//                                "lightSteelBlue", [](){return ci::vec3(0.69f, 0.769f, 0.871f);},
//                                "lightYellow", [](){return ci::vec3(1.0f, 1.0f, 0.878f);},
//                                "limeGreen", [](){return ci::vec3(0.196f, 0.804f, 0.196f);},
//                                "linen", [](){return ci::vec3(0.98f, 0.941f, 0.902f);},
//                                "magenta", [](){return ci::vec3(1.0f, 0.0f, 1.0f);},
//                                "mediumAquaMarine", [](){return ci::vec3(0.4f, 0.804f, 0.677f);},
//                                "mediumBlue", [](){return ci::vec3(0.0f, 0.0f, 0.804f);},
//                                "mediumOrchid", [](){return ci::vec3(0.729f, 0.333f, 0.827f);},
//                                "mediumPurple", [](){return ci::vec3(0.576f, 0.439f, 0.859f);},
//                                "mediumSeaGreen", [](){return ci::vec3(0.235f, 0.702f, 0.443f);},
//                                "mediumSlateBlue", [](){return ci::vec3(0.482f, 0.408f, 0.933f);},
//                                "mediumSpringGreen", [](){return ci::vec3(0.0f, 0.98f, 0.604f);},
//                                "mediumTurquoise", [](){return ci::vec3(0.282f, 0.82f, 0.8f);},
//                                "mediumVioletRed", [](){return ci::vec3(0.78f, 0.082f, 0.522f);},
//                                "midnightBlue", [](){return ci::vec3(0.098f, 0.098f, 0.439f);},
//                                "mintCream", [](){return ci::vec3(0.961f, 1.0f, 0.98f);},
//                                "mistyRose", [](){return ci::vec3(1.0f, 0.894f, 0.882f);},
//                                "moccasin", [](){return ci::vec3(1.0f, 0.894f, 0.71f);},
//                                "navajoWhite", [](){return ci::vec3(1.0f, 0.871f, 0.678f);},
//                                "oldLace", [](){return ci::vec3(0.992f, 0.961f, 0.902f);},
//                                "oliveDrab", [](){return ci::vec3(0.42f, 0.557f, 0.137f);},
//                                "orangeRed", [](){return ci::vec3(1.0f, 0.271f, 0.0f);},
//                                "orchid", [](){return ci::vec3(0.855f, 0.439f, 0.839f);},
//                                "paleGoldenrod", [](){return ci::vec3(0.933f, 0.91f, 0.667f);},
//                                "paleGreen", [](){return ci::vec3(0.596f, 0.984f, 0.596f);},
//                                "paleTurquoise", [](){return ci::vec3(0.686f, 0.933f, 0.933f);},
//                                "paleVioletRed", [](){return ci::vec3(0.859f, 0.439f, 0.576f);},
//                                "papayaWhip", [](){return ci::vec3(1.0f, 0.937f, 0.835f);},
//                                "peachPuff", [](){return ci::vec3(1.0f, 0.855f, 0.725f);},
//                                "peru", [](){return ci::vec3(0.804f, 0.522f, 0.247f);},
//                                "pink", [](){return ci::vec3(1.0f, 0.753f, 0.796f);},
//                                "plum", [](){return ci::vec3(0.867f, 0.627f, 0.867f);},
//                                "powderBlue", [](){return ci::vec3(0.69f, 0.878f, 0.902f);},
//                                "rosyBrown", [](){return ci::vec3(0.737f, 0.561f, 0.561f);},
//                                "royalBlue", [](){return ci::vec3(0.255f, 0.412f, 0.882f);},
//                                "saddleBrown", [](){return ci::vec3(0.545f, 0.271f, 0.075f);},
//                                "salmon", [](){return ci::vec3(0.98f, 0.502f, 0.447f);},
//                                "sandyBrown", [](){return ci::vec3(0.957f, 0.643f, 0.376f);},
//                                "seaGreen", [](){return ci::vec3(0.18f, 0.545f, 0.341f);},
//                                "seaShell", [](){return ci::vec3(1.0f, 0.961f, 0.933f);},
//                                "sienna", [](){return ci::vec3(0.627f, 0.322f, 0.176f);},
//                                "skyBlue", [](){return ci::vec3(0.529f, 0.808f, 0.922f);},
//                                "slateBlue", [](){return ci::vec3(0.416f, 0.353f, 0.804f);},
//                                "slateGray", [](){return ci::vec3(0.439f, 0.502f, 0.565f);},
//                                "snow", [](){return ci::vec3(1.0f, 0.98f, 0.98f);},
//                                "springGreen", [](){return ci::vec3(0.0f, 1.0f, 0.498f);},
//                                "steelBlue", [](){return ci::vec3(0.275f, 0.51f, 0.706f);},
//                                "tan", [](){return ci::vec3(0.824f, 0.706f, 0.549f);},
//                                "thistle", [](){return ci::vec3(0.847f, 0.749f, 0.847f);},
//                                "tomato", [](){return ci::vec3(1.0f, 0.388f, 0.278f);},
//                                "turquoise", [](){return ci::vec3(0.251f, 0.878f, 0.816f);},
//                                "violet", [](){return ci::vec3(0.933f, 0.51f, 0.933f);},
//                                "wheat", [](){return ci::vec3(0.961f, 0.871f, 0.702f);},
//                                "whiteSmoke", [](){return ci::vec3(0.961f, 0.961f, 0.961f);},
//                                "yellowGreen", [](){return ci::vec3(0.604f, 0.804f, 0.196f);},
                                "x", &ci::vec3::x,
                                "y", &ci::vec3::y,
                                "z", &ci::vec3::z,
                                "r", &ci::vec3::x,
                                "g", &ci::vec3::y,
                                "b", &ci::vec3::z);
    
    lua->new_usertype<ci::vec4>("vec4",
                                sol::constructors<ci::vec4(), ci::vec4(float), ci::vec4(float, float, float, float)>(),
                                "__add", [](const ci::vec4& l, const ci::vec4& r) { return l + r; },
                                "__sub", [](const ci::vec4& l, const ci::vec4& r) { return l - r; },
                                "__mul", [](const ci::vec4& l, const ci::vec4& r) { return l * r; },
                                "__div", [](const ci::vec4& l, const ci::vec4& r) { return l / r; },
                                "__mod", [](const ci::vec4& l, const ci::vec4& r) { return glm::mod(l, r); },
                                "x", &ci::vec4::x,
                                "y", &ci::vec4::y,
                                "z", &ci::vec4::z,
                                "w", &ci::vec4::w,
                                "r", &ci::vec4::x,
                                "g", &ci::vec4::y,
                                "b", &ci::vec4::z,
                                "a", &ci::vec4::w
                            );
    
    lua->new_usertype<ci::Perlin>("perlin",
                                  sol::constructors<ci::Perlin(), ci::Perlin(int), ci::Perlin(int, int)>(),
                                  "setSeed", sol::as_function(&ci::Perlin::setSeed),
                                  "getOctaves", sol::as_function(&ci::Perlin::getOctaves),
                                  "setOctaves", sol::as_function(&ci::Perlin::setOctaves),
                                  "fBm", sol::overload(sol::resolve<float(float) const>(&ci::Perlin::fBm),
                                                       sol::resolve<float(const ci::vec2 &) const>(&ci::Perlin::fBm),
                                                       sol::resolve<float(float, float) const>(&ci::Perlin::fBm),
                                                       sol::resolve<float(const ci::vec3 &) const>(&ci::Perlin::fBm),
                                                       sol::resolve<float(float, float, float) const>(&ci::Perlin::fBm)
                                                       ),
                                  "dfBm", sol::overload(sol::resolve<ci::vec2(const ci::vec2 &) const>(&ci::Perlin::dfBm),
                                                        sol::resolve<ci::vec2(float, float) const>(&ci::Perlin::dfBm),
                                                        sol::resolve<ci::vec3(const ci::vec3 &) const>(&ci::Perlin::dfBm),
                                                        sol::resolve<ci::vec3(float, float, float) const>(&ci::Perlin::dfBm)
                                                        ),
                                  "noise", sol::overload(sol::resolve<float(float) const>(&ci::Perlin::noise),
                                                         sol::resolve<float(const ci::vec2 &) const>(&ci::Perlin::noise),
                                                         sol::resolve<float(float, float) const>(&ci::Perlin::noise),
                                                         sol::resolve<float(const ci::vec3 &) const>(&ci::Perlin::noise),
                                                         sol::resolve<float(float, float, float) const>(&ci::Perlin::noise)
                                                         ),
                                  "dnoise", sol::overload(sol::resolve<ci::vec2(float, float) const>(&ci::Perlin::dnoise),
                                                          sol::resolve<ci::vec3(float, float, float) const>(&ci::Perlin::dnoise)
                                                          ),
                                  "print", sol::as_function([](sol::this_state ts){
                                      lua_State* L = ts;
                                      sol::state_view lua(L);
                                      lua.safe_script("prnt(obj,'float<-noise(float or vec2 or f, f or vec3 or f, f, f) \t float<-fBm(float or vec2 or f, f or vec3 or f, f, f) \t vec<- or vec3<-dnoise(f, f or f, f, f) \t vec2<- or vec3<-dfBm(f, f or vec2 or f, f, f or vec3) \t setSeed(int) \t int<-getOctaves() \t setOctaves(int)')");
                                  })
                                  );
    
    
//    lua->new_usertype<mRand>("rand",
//                             "linear", sol::as_function(&mRand::linear),
//                             "gauss", sol::as_function(&mRand::gauss),
//                             "circular", sol::as_function(&mRand::circular),
//                             "spherical", sol::as_function(&mRand::spherical),
//                             "disk", sol::as_function(&mRand::disk),
//                             "ball", sol::as_function(&mRand::ball),
//                             "print", sol::as_function(&mRand::print)
//                             );
//    
    
    lua->new_usertype<ci::Rand>("rand",
                             sol::constructors<ci::Rand(), ci::Rand(int)>(),
                             "seed", sol::as_function(&ci::Rand::seed),
                             "nextBool", sol::as_function(&ci::Rand::nextBool),
                             "nextInt", sol::overload(sol::resolve<int32_t()>(&ci::Rand::nextInt),
                                                      sol::resolve<int32_t(int32_t)>(&ci::Rand::nextInt),
                                                      sol::resolve<int32_t(int32_t, int32_t)>(&ci::Rand::nextInt)
                                                      ),
                             "randInt", sol::overload(sol::resolve<int32_t()>(&ci::Rand::randInt),
                                                      sol::resolve<int32_t(int32_t)>(&ci::Rand::randInt),
                                                      sol::resolve<int32_t(int32_t, int32_t)>(&ci::Rand::randInt)
                                                      ),
                             "nextUint", sol::overload(sol::resolve<uint32_t()>(&ci::Rand::nextUint),
                                                      sol::resolve<uint32_t(uint32_t)>(&ci::Rand::nextUint)
                                                      ),
                             "randUint", sol::overload(sol::resolve<uint32_t()>(&ci::Rand::randUint),
                                                       sol::resolve<uint32_t(uint32_t)>(&ci::Rand::randUint)
                                                       ),
                             "nextFloat", sol::overload(sol::resolve<float()>(&ci::Rand::nextFloat),
                                                        sol::resolve<float(float)>(&ci::Rand::nextFloat),
                                                        sol::resolve<float(float, float)>(&ci::Rand::nextFloat)
                                                        ),
                             "randFloat", sol::overload(sol::resolve<float()>(&ci::Rand::randFloat),
                                                        sol::resolve<float(float)>(&ci::Rand::randFloat),
                                                        sol::resolve<float(float, float)>(&ci::Rand::randFloat)
                                                        ),
                             //posNegFloat
                             //randposNegFloat
                             //randGauss
                             "nextVec2", sol::as_function(&ci::Rand::nextVec2),
                             "randVec2", sol::as_function(&ci::Rand::randVec2),
                             "nextVec3", sol::as_function(&ci::Rand::nextVec3),
                             "randVec3", sol::as_function(&ci::Rand::randVec3)

//                             "print", sol::as_function(&mRand::print)
                             );

    
    lua->new_usertype<mCircle>("circle",
                               "p", sol::property(&mCircle::set_p, &mCircle::get_p),
                               "r", sol::property(&mCircle::set_r, &mCircle::get_r),
                               "s", sol::property(&mCircle::set_s, &mCircle::get_s),
                               "c", sol::property(&mCircle::set_c, &mCircle::get_c),
                               "a", sol::property(&mCircle::set_a, &mCircle::get_a),
                               "radius", sol::property(&mCircle::set_radius, &mCircle::get_radius),
                               "outline", sol::property(&mCircle::set_outline, &mCircle::get_outline),
                               "lineWidth", sol::property(&mCircle::set_lineWidth, &mCircle::get_lineWidth),
                               "print", sol::as_function(&mCircle::print),
                               "draw", sol::as_function(&mCircle::draw),
                               sol::base_classes, sol::bases<Drawable>()
                               );
    
    
    lua->new_usertype<mRectangle>("rect",
                                  "p", sol::property(&mRectangle::set_p, &mRectangle::get_p),
                                  "r", sol::property(&mRectangle::set_r, &mRectangle::get_r),
                                  "s", sol::property(&mRectangle::set_s, &mRectangle::get_s),
                                  "c", sol::property(&mRectangle::set_c, &mRectangle::get_c),
                                  "w", sol::property(&mRectangle::set_w, &mRectangle::get_w),
                                  "h", sol::property(&mRectangle::set_h, &mRectangle::get_h),
                                  "a", sol::property(&mRectangle::set_a, &mRectangle::get_a),
                                  "radians", sol::property(&mRectangle::set_radians, &mRectangle::get_radians),
                                  "outline", sol::property(&mRectangle::set_outline, &mRectangle::get_outline),
                                  "lineWidth", sol::property(&mRectangle::set_lineWidth, &mRectangle::get_lineWidth),
                                  "print", sol::as_function(&mRectangle::print),
                                  "draw", sol::as_function(&mRectangle::draw),
                                  sol::base_classes, sol::bases<Drawable>()
                                  );
    
    lua->new_usertype<mImageSrc>("imageSrc",
                                 sol::constructors<mImageSrc(), mImageSrc(std::string)>(),
//                                 "open", sol::as_function(&mImageSrc::open),
                                 "print", sol::as_function(&mImageSrc::print)
                                 );
    
    lua->new_usertype<mImage>("image",
                               sol::constructors<mImage(), mImage(mImageSrc *), mImage(float, float, mImageSrc *)>(),
                              "p", sol::property(&mImage::set_p, &mImage::get_p),
                              "r", sol::property(&mImage::set_r, &mImage::get_r),
                              "s", sol::property(&mImage::set_s, &mImage::get_s),
                              "c", sol::property(&mImage::set_c, &mImage::get_c),
                              "a", sol::property(&mImage::set_a, &mImage::get_a),
                              "radians", sol::property(&mImage::set_radians, &mImage::get_radians),
//                              "open", sol::as_function(&mImage::open),
                              "setImage", sol::as_function(&mImage::setImage),
                              "getImage", sol::as_function(&mImage::getImage),
                              "print", sol::as_function(&mImage::print),
                              "draw", sol::as_function(&mImage::draw),
                              sol::base_classes, sol::bases<Drawable>()
                              );
    
    lua->new_usertype<mLine>("line",
                             "p", sol::property(&mLine::set_p, &mLine::get_p),
                             "r", sol::property(&mLine::set_r, &mLine::get_r),
                             "s", sol::property(&mLine::set_s, &mLine::get_s),
                             "c", sol::property(&mLine::set_c, &mLine::get_c),
                             "p1", sol::property(&mLine::set_p1, &mLine::get_p1),
                             "p2", sol::property(&mLine::set_p2, &mLine::get_p2),
                             "a", sol::property(&mLine::set_a, &mLine::get_a),
                             "radians", sol::property(&mLine::set_radians, &mLine::get_radians),
                             "lineWidth", sol::property(&mLine::set_lineWidth, &mLine::get_radians),
                             "print", sol::as_function(&mLine::print),
                             "draw", sol::as_function(&mLine::draw),
                            sol::base_classes, sol::bases<Drawable>()
                             );
    
    lua->new_usertype<mCube>("cube",
                             "p", sol::property(&mCube::set_p, &mCube::get_p),
                             "r", sol::property(&mCube::set_r, &mCube::get_r),
                             "s", sol::property(&mCube::set_s, &mCube::get_s),
                             "c", sol::property(&mCube::set_c, &mCube::get_c),
                             "a", sol::property(&mCube::set_a, &mCube::get_a),
                             "w", sol::property(&mCube::set_w, &mCube::get_w),
                             "h", sol::property(&mCube::set_h, &mCube::get_h),
                             "d", sol::property(&mCube::set_d, &mCube::get_d),
                             "radians", sol::property(&mCube::set_radians, &mCube::get_radians),
                             "lineWidth", sol::property(&mCube::set_lineWidth, &mCube::get_lineWidth),
                             "outline", sol::property(&mCube::set_outline, &mCube::get_outline),
                             "print", sol::as_function(&mCube::print),
                             "draw", sol::as_function(&mCube::draw),
                              sol::base_classes, sol::bases<Drawable>()
                         );
    
    lua->new_usertype<mSphere>("sphere",
                               "p", sol::property(&mSphere::set_p, &mSphere::get_p),
                               "r", sol::property(&mSphere::set_r, &mSphere::get_r),
                               "s", sol::property(&mSphere::set_s, &mSphere::get_s),
                               "c", sol::property(&mSphere::set_c, &mSphere::get_c),
                               "a", sol::property(&mSphere::set_a, &mSphere::get_a),
                               "radians", sol::property(&mSphere::set_radians, &mSphere::get_radians),
                             "print", sol::as_function(&mSphere::print),
                             "draw", sol::as_function(&mSphere::draw),
                              sol::base_classes, sol::bases<Drawable>()
                             );
    
    lua->new_usertype<invert>("invert",
                              "print", sol::as_function(&invert::print)
                              );
    
    lua->new_usertype<greyscale>("grayscale",
                                 "amount", sol::property(&greyscale::set_amount, &greyscale::get_amount),
                                 "print", sol::as_function(&greyscale::print)
                                 );
    
    lua->new_usertype<vignette>("vignette",
                                "amount", sol::property(&vignette::set_amount, &vignette::get_amount),
                                "print", sol::as_function(&vignette::print)
                                );
    
    lua->new_usertype<aberration>("aberration",
                                  "amount", sol::property(&aberration::set_amount, &aberration::get_amount),
                                  "print", sol::as_function(&aberration::print)
                                  );
    
    lua->new_usertype<scanline>("scanline",
                                "amount", sol::property(&scanline::set_amount, &scanline::get_amount),
                                "speed", sol::property(&scanline::set_speed, &scanline::get_speed),
                                "print", sol::as_function(&scanline::print)
                                );
    
    lua->new_usertype<edges>("edges",
                             "print", sol::as_function(&edges::print)
                             );
    
    lua->new_usertype<blur>("blur",
                            "amount", sol::property(&blur::set_amount, &blur::get_amount),
                            "print", sol::as_function(&blur::print)
                            );
    
    
}
