//
//  mEase.h
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 10/9/17.
//
//

#ifndef help_h
#define help_h

class help {
    
public:

    
    void ease(sol::this_state ts){
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj,'float<-almostAll(float) \t easeInQuad \t easeOutQuad \t easeInOutQuad \t easeOutInQuad \t easeInCubic  \t easeOutCubic  \t easeInOutCubic  \t easeOutInCubic  \t easeInQuart \t easeOutQuart \t easeInOutQuart \t easeOutInQuart \t easeInQuint \t easeOutQuint \t easeInOutQuint \t easeOutInQuint \t easeInSine \t easeOutSine \t easeInOutSine \t easeOutInSine \t easeInExpo \t easeOutExpo \t easeInOutExpo \t easeOutInExpo \t easeInCirc \t easeOutCirc \t easeInOutCirc \t easeOutInCirc \t easeInBounce(float, f = 1.7) \t easeOutBounce \t easeInOutBounce \t easeOutInBounce \t easeInBack \t easeOutBack \t easeInOutBack \t easeOutInBack \t easeInElastic(float, f = amp, f= period) \t easeOutElastic \t easeInOutElastic \t easeOutInElastic \t easeInAtan(float, f = 15) \t easeOutAtan \t easeInOutAtan(')");
    }
    
    void rand(sol::this_state ts){
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj,'float<-linear(float min, float max) \t float<-gauss(float mean, float dev) \t vec2<-circular(float) \t vec3<-spherical(float) \t vec2<-disk(float) \t vec3<-ball(float)')");
    }
    
    void colors(sol::this_state ts){
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj,'aliceBlue antiqueWhite aqua aquaMarine azure beige bisque black blanchedAlmond blue blueViolet brown burlyWood chartreuse chocolate coral cornflowerBlue cornsilk crimson cyan darkBlue darkCyan darkGoldenrod darkGray darkGreen darkKhaki darkMagenta darkOliveGreen darkOrange darkRed darkSalmon darkSeaGreen darkSlateBlue darkSlateGray darkTurquoise darkViolet deepPink deepSkyBlue dimGray dodgerBlue fireBrick floralWhite forestGreen fuchia gray green gainsboro ghostWhite gold goldenrod greenYellow gray honeydew hotPink indianRed indigo ivory khaki lavender lavenderBlush lawnGreen lemonChiffon lightBlue lightCoral lightGray lightGreen lightPink lightSalmon lightSeaGreen lightSkyBlue lightSlateGray lightSteelBlue lightYellow lime limeGreen linen magenta mediumAquaMarine mediumBlue mediumOrchid mediumPurple mediumSeaGreen mediumSlateBlue mediumSpringGreen mediumTurquoise mediumVioletRed midnightBlue mintCream mistyRose moccain navajoWhite navy oldLace olive oliveDrab orange orangeRed orchid paleGoldenrod paleGreen paleTurquoise paleVioletRed papayaWhip peachPuff peru pink powderBlue purple red rosyBrown royalBlue saddleBrown salmon sandyBrown seaGreen seaShell sienna silver skyBlue slateBlue slateGray steelBlue tan teal thistle tomato turquoise violet wheat white whiteSmoke yellow yellowGreen')");
    }

    void functions(sol::this_state ts){
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj,'f<-toRadians(float) \t f<-toDegrees(float) \t f<-lerp(float, f, f) \t i,f<-lmap(if , , , , ) \t constrain(i f, i f, i f) \t hsvToRgb(vec3) \t rgbToHsv(vec3) \t length(vec2 3 4) \t distance(vec) \t dot(vec3 4) \t normalize(vec2 3 4) \t cross(vec3) \t faceForward(vec3) \t refract(vec3) \t abs(i f vec) \t acos(f vec) \t asin(f vec) \t atan(f vec) \t cos(f vec) \t cosh(f vec) sin(f vec) \t sinh(f vec) \t sinh(f vec) \t tan(f vec) \t tanh(f vec) \t exp(f vec) \t exp2(f vec) \t log(f vec) \t log2(f vec) \t pow(f, f or vec, vec) \t inversesqrt(f vec) \t sign(i f vec) \t floor(f vec) \t trunc(f vec) \t round(f vec) \t roundEven(f vec) \t ceil(f vec) \t fract(f vec) \t mod(f, f or vec, vec) \t min(i, i or f, f or vec, vec) \t max(i, i or f, f or vec, vec) \t clamp(f, f, f or vec, vec, vec or vec, vec, f) \t step(f, f or vec, vec or f, vec) \t smoothstep(f, f, f or vec, vec, vec or f, f, vec) \t bvec<-isnan(vec)')");
    }
    
    void perlin(sol::this_state ts){
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj,'float<-noise(float or vec2 or f, f or vec3 or f, f, f) \t float<-fBm(float or vec2 or f, f or vec3 or f, f, f) \t vec<- or vec3<-dnoise(f, f or f, f, f) \t vec2<- or vec3<-dfBm(f, f or vec2 or f, f, f or vec3) \t setSeed(int) \t int<-getOctaves() \t setOctaves(int)')");
    }
    
    void shapes(sol::this_state ts){
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj,'circle \t rect \t image \t line \t cube \t sphere')");
    }
};

#endif

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

}






