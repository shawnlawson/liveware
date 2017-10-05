//
//  LuaBindings.h
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 10/2/17.
//
//
#include "cinder/CinderMath.h"
#include "cinder/Perlin.h"

#include "Drawable.h"
#include "mCircle.h"
#include "mRectangle.h"
#include "mImage.h"
#include "mLine.h"

#include "PostProcess.h"
#include "BuiltinPostProcesses.h"


#ifndef LuaBindings_h
#define LuaBindings_h

void luaBinding(sol::state *lua)
{
    //easing functions
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
//    lua->set_function("length", [](const ci::vec3& l) { return glm::length(l); });
//    lua->set_function("distance", [](const ci::vec3& l, const ci::vec3& r){ return glm::distance(l, r); });
//    lua->set_function("dot", [](const ci::vec3& l, const ci::vec3& r){ return glm::dot(l, r); });
//    lua->set_function("cross", [](const ci::vec3& l, const ci::vec3& r){ return glm::cross(l, r); });
//    lua->set_function("faceforward", [](const ci::vec3& N, const ci::vec3& I, const ci::vec3& Nref){ return glm::faceforward(N, I, Nref); });
//    lua->set_function("refract", [](const ci::vec3& I, const ci::vec3& N, float eta){ return glm::refract(I, N, eta); });
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
    
    lua->set_function("length", sol::overload(sol::resolve<float(const ci::vec3 &)>(&glm::length)
                                              )
                      );
    lua->set_function("distance", sol::overload(sol::resolve<float(const ci::vec3& l, const ci::vec3& r)>(&glm::distance)
                                                )
                      );
    lua->set_function("dot", sol::overload(sol::resolve<float(const ci::vec3& l, const ci::vec3& r)>(&glm::dot)
                                           )
                      );
    lua->set_function("cross", sol::overload(sol::resolve<ci::vec3(const ci::vec3& l, const ci::vec3& r)>(&glm::cross)
                                             )
                      );
    lua->set_function("faceforward", sol::overload(sol::resolve<ci::vec3(const ci::vec3& N, const ci::vec3& I, const ci::vec3& Nref)>(&glm::faceforward)
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
//    lua->set_function("atan2", sol::overload(sol::resolve<float(const float)>(&glm::atan2),
//                                            sol::resolve<ci::vec2(const ci::vec2 &)>(&glm::atan2),
//                                            sol::resolve<ci::vec3(const ci::vec3 &)>(&glm::atan2),
//                                            sol::resolve<ci::vec4(const ci::vec4 &)>(&glm::atan2)
//                                            )
//                      );
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
                                             sol::resolve<ci::vec3(const ci::vec3 &, const ci::vec3 &)>(&glm::mod)
//                                             sol::resolve<ci::vec4(const ci::vec4 &, const ci::vec4 &)>(&glm::mod)
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
//    lua->set_function("step", sol::overload(sol::resolve<float(const float, const float)>(&glm::step),
////                                           sol::resolve<ci::vec2(const float, const ci::vec2 &)>(&glm::step),
//                                           sol::resolve<ci::vec2(const ci::vec2 &, const ci::vec2 &)>(&glm::step),
////                                           sol::resolve<ci::vec3(const float, const ci::vec3 &)>(&glm::step),
//                                           sol::resolve<ci::vec3(const ci::vec3 &, const ci::vec3 &)>(&glm::step),
////                                           sol::resolve<ci::vec4(const float, const ci::vec4 &)>(&glm::step),
//                                           sol::resolve<ci::vec4(const ci::vec4 &, const ci::vec4 &)>(&glm::step)
//                                           )
//                      );
    lua->set_function("smoothstep", sol::overload(sol::resolve<float(const float, const float, const float)>(&glm::smoothstep),
//                                           sol::resolve<ci::vec2(const float, const ci::vec2 &)>(&glm::step),
                                           sol::resolve<ci::vec2(const ci::vec2 &, const ci::vec2 &, const ci::vec2 &)>(&glm::smoothstep),
//                                           sol::resolve<ci::vec3(const float, const ci::vec3 &)>(&glm::step),
                                           sol::resolve<ci::vec3(const ci::vec3 &, const ci::vec3 &, const ci::vec3 &)>(&glm::smoothstep),
//                                           sol::resolve<ci::vec4(const float, const ci::vec4 &)>(&glm::step),
                                           sol::resolve<ci::vec4(const ci::vec4 &, const ci::vec4 &, const ci::vec4 &)>(&glm::smoothstep)
                                           )
                      );
    lua->set_function("isnan", sol::overload(sol::resolve<glm::bvec2(const ci::vec2 &)>(&glm::isnan),
                                             sol::resolve<glm::bvec3(const ci::vec3 &)>(&glm::isnan),
                                             sol::resolve<glm::bvec4(const ci::vec4 &)>(&glm::isnan)
                                             )
                    );
    //GLM_FUNC_DECL int floatBitsToInt(float const & v);
    //etc to end of glm::func_common.hpp

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
                                "x", &ci::vec3::x,
                                "y", &ci::vec3::y,
                                "z", &ci::vec3::z);
    
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
                               "w", &ci::vec4::w
                               );
    
    lua->new_usertype<ci::Perlin>("perlin",
                                  sol::constructors<ci::Perlin(), ci::Perlin(int), ci::Perlin(int, int)>(),
                                  "setSeed", &ci::Perlin::setSeed,
                                  "getOctaves", &ci::Perlin::getOctaves,
                                  "setOctaves", &ci::Perlin::setOctaves,
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
                                  "print", [](sol::this_state ts){
                                                                      lua_State* L = ts;
                                                                      sol::state_view lua(L);
                                                                      lua.safe_script("print('noise \t fBm \t setSeed(int) \t getOctaves \t setOctaves(int)')");
                                                                  }
                                  );
    
    
    
    lua->new_usertype<mCircle>("circle",
                              "p", &mCircle::p,
                              "r", &mCircle::r,
                              "s", &mCircle::s,
                              "radius", &mCircle::radius,
                              "outline", &mCircle::outline,
                              "lineWidth", &mCircle::lineWidth,
                              "print", &mCircle::print,
                              "draw", &mCircle::draw
                              );
    
    
    lua->new_usertype<mRectangle>("rect",
                                 "p", &mImage::p,
                                  "r", &mImage::r,
                                  "s", &mImage::s,
                                  "w", &mRectangle::w,
                                 "h", &mRectangle::h,
                                 "radians", &mRectangle::radians,
                                 "outline", &mRectangle::outline,
                                 "lineWidth", &mRectangle::lineWidth,
                                 "print", &mRectangle::print,
                                 "draw", &mRectangle::draw
                                 );
    
    lua->new_usertype<mImage>("image",
                             "p", &mImage::p,
                             "r", &mImage::r,
                             "s", &mImage::s,
                             "radians", &mImage::radians,
                             "open", &mImage::open,
                             "print", &mImage::print,
                             "draw", &mImage::draw
                             );
    
    lua->new_usertype<mLine>("line",
                             "p", &mImage::p,
                             "r", &mImage::r,
                             "s", &mImage::s,
                             "radians", &mLine::radians,
                              "print", &mLine::print,
                              "draw", &mLine::draw
                              );
    
    lua->new_usertype<invert>("invert",
                             "print", &invert::print
                             );
    
    lua->new_usertype<greyscale>("greyscale",
                                "amount", &greyscale::amount,
                                "print", &greyscale::print
                                );
    
    lua->new_usertype<vignette>("vignette",
                               "amount", &vignette::amount,
                               "print", &vignette::print
                               );
    
    lua->new_usertype<aberration>("aberration",
                                 "amount", &aberration::amount,
                                 "print", &aberration::print
                                 );
    
    lua->new_usertype<scanline>("scanline",
                               "amount", &scanline::amount,
                               "speed", &scanline::speed,
                               "print", &scanline::print
                               );
    
    lua->new_usertype<edges>("edges",
                            "print", &edges::print
                            );
    
    lua->new_usertype<blur>("blur",
                           "amount", &blur::amount,
                           "print", &blur::print
                           );
    
}

#endif /* LuaBindings_h */
