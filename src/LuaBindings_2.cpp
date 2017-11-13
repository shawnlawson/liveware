//
//  LuaBindings_2.cpp
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 11/13/17.
//
//

#include "luaBindings_2.hpp"

void luaBinding2(sol::state *lua)
{
    
    lua->new_usertype<help>("help",
                            "ease", sol::as_function(&help::ease),
                            "rand", sol::as_function(&help::rand),
                            "colors", sol::as_function(&help::colors),
                            "functions", sol::as_function(&help::functions),
                            "perlin", sol::as_function(&help::perlin),
                            "shapes" , sol::as_function(&help::shapes)
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
                              "which", sol::property(&mImage::setImage, &mImage::getImage),
                              "drawMode", sol::property(&mImage::set_drawMode, &mImage::get_drawMode),
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

