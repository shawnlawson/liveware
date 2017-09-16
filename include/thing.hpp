//
//  thing.hpp
//  CinderProject
//
//  Created by Shawn Lawson on 8/29/17.
//
//

#ifndef thing_hpp
#define thing_hpp

#include <string>

class thing {
public:
    std::vector<thing> kids;
    

    int x, y, z;
    using value_type = decltype(kids)::value_type;
    using iterator = decltype(kids)::iterator;
    using size_type = decltype(kids)::size_type;
    iterator begin() { return iterator(kids.begin()); }
    iterator end() { return iterator(kids.end()); }
    size_type size() const noexcept { return kids.size(); }
    size_type max_size() const noexcept { return kids.max_size(); }
    void push_back(thing value) { kids.push_back(value); }
    bool empty() const noexcept { return kids.empty(); }
    
    
    thing() : x(0), y(100), z(123) {}
    
    std::string print() {
        return "this works";
    }
    
    void draw(){
        ci::gl::color(1.0, 1.0, 1.0, .25);
        ci::gl::drawSolidCircle(ci::app::getWindowCenter(), y);
        int howMany = kids.size();
        if (howMany > 0) {
            for (int i = 0; i < howMany; ++i) {
                kids[i].draw();
            }
        }
    }
    
    void update(){
        
    }
    
};

#endif /* thing_hpp */
