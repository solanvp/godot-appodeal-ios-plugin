//
//  appodealplugin.m
//  appodealplugin
//
//  Created by Pedro Solano on 09/07/25.
//

#import <Foundation/Foundation.h>
@import Appodeal;

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
    ADD_SIGNAL(MethodInfo("signal_test", PropertyInfo(Variant::STRING, "result")));
    
    ClassDB::bind_method("check_appodeal", &Appodealplugin::check_appodeal);
}

void Appodealplugin::check_appodeal() {
    NSLog(@"Appodeal check");
    NSString *sdkVersion = [Appodeal getVersion];
    NSLog(@"Appodeal check: %@", sdkVersion);
    emit_signal("signal_test", "Hello from Appodealplugin");
}