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
    // Initialization
    void initialize_appodeal(const String &api_key);
    void initialize_appodeal_with_consent(const String &api_key, bool has_consent);
    
    // Event logging
    void log_event(const String &event_name);
    void log_event_with_parameters(const String &event_name, const Dictionary &parameters);
    void log_revenue_event(const String &currency, double amount);
    void log_revenue_event_with_parameters(const String &currency, double amount, const Dictionary &parameters);
    
    // User metadata (instead of Facebook meta config)
    void set_user_id(const String &user_id);
    void set_custom_state_value(const String &key, const Variant &value);
    
    // Consent management (using the correct methods)
    void set_child_directed_treatment(bool child_directed);
    
    // Banner ad methods
    void show_banner();
    void show_banner_at_position(const String &position);
    void hide_banner();
    bool is_banner_ready();
    bool is_banner_shown();
    void set_banner_animation_enabled(bool enabled);
    void set_smart_banners_enabled(bool enabled);
    
    // Utility methods
    void check_appodeal();
    String get_appodeal_version();
    bool is_initialized();
    
    static Appodealplugin *get_singleton();
    
    Appodealplugin();
    ~Appodealplugin();
    
protected:
    static void _bind_methods();
    
private:
    bool initialized;
    bool banner_loaded;
    bool banner_shown;
};

#endif
