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
    void check_appodeal();
    static Appodealplugin *get_singleton();
    
    Appodealplugin();
    ~Appodealplugin();
    
protected:
    static void _bind_methods();
};

#endif
