//
//  Drawable.h
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 9/21/17.
//
//

#ifndef Drawable_h
#define Drawable_h

class Drawable {
public:
    std::vector<Drawble> kids;
    
    float x, y, z;
    float rX, rY, rZ;
    float sX, sY, sZ
    
    using value_type = decltype(kids)::value_type;
    using iterator = decltype(kids)::iterator;
    using size_type = decltype(kids)::size_type;
    iterator begin() { return iterator(kids.begin()); }
    iterator end() { return iterator(kids.end()); }
    size_type size() const noexcept { return kids.size(); }
    size_type max_size() const noexcept { return kids.max_size(); }
    void push_back(thing value) { kids.push_back(value); }
    bool empty() const noexcept { return kids.empty(); }

    
    drawable() : x(0), y(0), z(0), rX(0), rY(0), rZ(0), sX(1), sY(1), sZ(1) {}
    
    std::string print() {
        
    }
    
    void draw(){
        int howMany = kids.size();
        for (int i = 0; i < howMany; ++i) {
                kids[i].draw();
        }
    }
    
    void update(){
        int howMany = kids.size();
        for (int i = 0; i < howMany; ++i) {
            kids[i].draw();
        }
    }
    
};


#endif /* Drawable_h */
