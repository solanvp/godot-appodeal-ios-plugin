//
//  appodealplugin.h
//  appodealplugin
//
//  Created by Pedro Solano on 09/07/25.
//

#ifndef APPODEALPLUGIN_H
#define APPODEALPLUGIN_H

#include "core/object/object.h"

class Appodealplugin: public Object {
    
    GDCLASS(Appodealplugin, Object);
    
    static Appodealplugin *instance;

public:
    int add();
    int sub(int num1, int num2);
    void multiply();
    static Appodealplugin *get_singleton();
    
    Appodealplugin();
    ~Appodealplugin();
    
protected:
    static void _bind_methods();
};

#endif
