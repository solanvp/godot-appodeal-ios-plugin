//
//  appodealplugin.m
//  appodealplugin
//
//  Created by Pedro Solano on 09/07/25.
//

#import <Foundation/Foundation.h>

#include "core/object/class_db.h"

#include "appodealplugin.h"

Appodealplugin *Appodealplugin::instance = NULL;

Appodealplugin::Appodealplugin() {
    instance = this;
    NSLog(@"initialize appodealplugin");
}


Appodealplugin::~Appodealplugin() {
    if (instance == this) {
        instance = NULL;
    }
    NSLog(@"deinitialize appodealplugin");
}


Appodealplugin *Appodealplugin::get_singleton() {
    return instance;
}

void Appodealplugin::_bind_methods() {
    ADD_SIGNAL(MethodInfo("multiply_result", PropertyInfo(Variant::STRING, "result")));
    
    ClassDB::bind_method("add", &Appodealplugin::add);
    ClassDB::bind_method("sub", &Appodealplugin::sub);
    ClassDB::bind_method("multiply", &Appodealplugin::multiply);
}

int Appodealplugin::add() {
    int num1 = 5;
    int num2 = 10;
    
    int result = num1 + num2;
    NSLog(@"Result of adition: %d", result);
    
    return result;
}

int Appodealplugin::sub(int num1, int num2) {
    int result = num1 - num2;
    NSLog(@"Result of substraction: %d", result);
    return result;
}

void Appodealplugin::multiply() {
    emit_signal("multiply_result", "Hello from Appodealplugin");
}
