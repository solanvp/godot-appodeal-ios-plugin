//
//  appodealplugin_module.mm
//  appodealplugin
//
//  Created by Pedro Solano on 09/07/25.
//

#include "core/config/engine.h"

#include "appodealplugin_module.h"

Appodealplugin * appodealplugin;

void register_appodealplugin_types() {
    appodealplugin = memnew(Appodealplugin);
    Engine::get_singleton() -> add_singleton(Engine::Singleton("Appodealplugin", appodealplugin));
};

void unregister_appodealplugin_types() {
    if (appodealplugin) {
        memdelete(appodealplugin);
    }
}
