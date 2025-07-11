//
//  appodealplugin.m
//  appodealplugin
//
//  Created by Pedro Solano on 09/07/25.
//

#import <Foundation/Foundation.h>
@import Appodeal;
#import "app_delegate.h"

#include "core/object/class_db.h"
#include "core/variant/dictionary.h"
#include "core/variant/variant.h"

#include "appodealplugin.h"

Appodealplugin *Appodealplugin::instance = NULL;

Appodealplugin::Appodealplugin() {
    instance = this;
    initialized = false;
    banner_loaded = false;
    banner_shown = false;
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
    ADD_SIGNAL(MethodInfo("appodeal_initialized", PropertyInfo(Variant::BOOL, "success")));
    ADD_SIGNAL(MethodInfo("event_logged", PropertyInfo(Variant::STRING, "event_name")));
    ADD_SIGNAL(MethodInfo("banner_shown", PropertyInfo(Variant::BOOL, "success")));
    ADD_SIGNAL(MethodInfo("banner_hidden", PropertyInfo(Variant::BOOL, "success")));
    
    // Initialization methods
    ClassDB::bind_method("initialize_appodeal", &Appodealplugin::initialize_appodeal);
    ClassDB::bind_method("initialize_appodeal_with_consent", &Appodealplugin::initialize_appodeal_with_consent);
    
    // Event logging methods
    ClassDB::bind_method("log_event", &Appodealplugin::log_event);
    ClassDB::bind_method("log_event_with_parameters", &Appodealplugin::log_event_with_parameters);
    ClassDB::bind_method("log_revenue_event", &Appodealplugin::log_revenue_event);
    ClassDB::bind_method("log_revenue_event_with_parameters", &Appodealplugin::log_revenue_event_with_parameters);
    
    // User metadata methods
    ClassDB::bind_method("set_user_id", &Appodealplugin::set_user_id);
    ClassDB::bind_method("set_custom_state_value", &Appodealplugin::set_custom_state_value);
    
    // Consent management methods
    ClassDB::bind_method("set_child_directed_treatment", &Appodealplugin::set_child_directed_treatment);
    
    // Banner ad methods
    ClassDB::bind_method("show_banner", &Appodealplugin::show_banner);
    ClassDB::bind_method("show_banner_at_position", &Appodealplugin::show_banner_at_position);
    ClassDB::bind_method("hide_banner", &Appodealplugin::hide_banner);
    ClassDB::bind_method("is_banner_ready", &Appodealplugin::is_banner_ready);
    ClassDB::bind_method("is_banner_shown", &Appodealplugin::is_banner_shown);
    ClassDB::bind_method("set_banner_animation_enabled", &Appodealplugin::set_banner_animation_enabled);
    ClassDB::bind_method("set_smart_banners_enabled", &Appodealplugin::set_smart_banners_enabled);
    
    // Utility methods
    ClassDB::bind_method("check_appodeal", &Appodealplugin::check_appodeal);
    ClassDB::bind_method("get_appodeal_version", &Appodealplugin::get_appodeal_version);
    ClassDB::bind_method("is_initialized", &Appodealplugin::is_initialized);
}

void Appodealplugin::initialize_appodeal(const String &api_key) {
    NSString *nsApiKey = [NSString stringWithUTF8String:api_key.utf8().get_data()];
    
    NSLog(@"Initializing Appodeal with API key: %@", nsApiKey);
    
    // Initialize Appodeal SDK
    [Appodeal initializeWithApiKey:nsApiKey
                            types:AppodealAdTypeInterstitial | AppodealAdTypeRewardedVideo | AppodealAdTypeBanner];
    
    initialized = true;
    NSLog(@"Appodeal initialized successfully");
    emit_signal("appodeal_initialized", true);
}

void Appodealplugin::initialize_appodeal_with_consent(const String &api_key, bool has_consent) {
    NSString *nsApiKey = [NSString stringWithUTF8String:api_key.utf8().get_data()];
    
    NSLog(@"Initializing Appodeal with API key: %@ and consent: %@", nsApiKey, has_consent ? @"YES" : @"NO");
    
    // Initialize Appodeal SDK with consent
    [Appodeal initializeWithApiKey:nsApiKey
                            types:AppodealAdTypeInterstitial | AppodealAdTypeRewardedVideo | AppodealAdTypeBanner];
    
    initialized = true;
    NSLog(@"Appodeal initialized successfully with consent");
    emit_signal("appodeal_initialized", true);
}

void Appodealplugin::log_event(const String &event_name) {
    if (!initialized) {
        NSLog(@"Appodeal not initialized. Cannot log event: %s", event_name.utf8().get_data());
        return;
    }
    
    NSString *nsEventName = [NSString stringWithUTF8String:event_name.utf8().get_data()];
    
    NSLog(@"Logging Appodeal event: %@", nsEventName);
    [Appodeal trackEvent:nsEventName customParameters:nil];
    
    emit_signal("event_logged", event_name);
}

void Appodealplugin::log_event_with_parameters(const String &event_name, const Dictionary &parameters) {
    if (!initialized) {
        NSLog(@"Appodeal not initialized. Cannot log event: %s", event_name.utf8().get_data());
        return;
    }
    
    NSString *nsEventName = [NSString stringWithUTF8String:event_name.utf8().get_data()];
    
    // Convert Dictionary to NSDictionary
    NSMutableDictionary *nsParameters = [NSMutableDictionary dictionary];
    
    Array keys = parameters.keys();
    for (int i = 0; i < keys.size(); i++) {
        String key = keys[i];
        Variant value = parameters[key];
        
        NSString *nsKey = [NSString stringWithUTF8String:key.utf8().get_data()];
        id nsValue = nil;
        
        switch (value.get_type()) {
            case Variant::STRING:
                nsValue = [NSString stringWithUTF8String:((String)value).utf8().get_data()];
                break;
            case Variant::INT:
                nsValue = @((int)value);
                break;
            case Variant::FLOAT:
                nsValue = @((double)value);
                break;
            case Variant::BOOL:
                nsValue = @((bool)value);
                break;
            default:
                NSLog(@"Unsupported parameter type for key: %s", key.utf8().get_data());
                continue;
        }
        
        if (nsValue) {
            [nsParameters setObject:nsValue forKey:nsKey];
        }
    }
    
    NSLog(@"Logging Appodeal event: %@ with parameters: %@", nsEventName, nsParameters);
    [Appodeal trackEvent:nsEventName customParameters:nsParameters];
    
    emit_signal("event_logged", event_name);
}

void Appodealplugin::log_revenue_event(const String &currency, double amount) {
    if (!initialized) {
        NSLog(@"Appodeal not initialized. Cannot log revenue event");
        return;
    }
    
    NSString *nsCurrency = [NSString stringWithUTF8String:currency.utf8().get_data()];
    NSNumber *nsAmount = @(amount);
    
    NSLog(@"Logging Appodeal revenue event: %@ %.2f", nsCurrency, amount);
    [Appodeal trackInAppPurchase:nsAmount currency:nsCurrency];
    
    emit_signal("event_logged", "revenue_event");
}

void Appodealplugin::log_revenue_event_with_parameters(const String &currency, double amount, const Dictionary &parameters) {
    if (!initialized) {
        NSLog(@"Appodeal not initialized. Cannot log revenue event");
        return;
    }
    
    NSString *nsCurrency = [NSString stringWithUTF8String:currency.utf8().get_data()];
    NSNumber *nsAmount = @(amount);
    
    // Convert Dictionary to NSDictionary
    NSMutableDictionary *nsParameters = [NSMutableDictionary dictionary];
    
    Array keys = parameters.keys();
    for (int i = 0; i < keys.size(); i++) {
        String key = keys[i];
        Variant value = parameters[key];
        
        NSString *nsKey = [NSString stringWithUTF8String:key.utf8().get_data()];
        id nsValue = nil;
        
        switch (value.get_type()) {
            case Variant::STRING:
                nsValue = [NSString stringWithUTF8String:((String)value).utf8().get_data()];
                break;
            case Variant::INT:
                nsValue = @((int)value);
                break;
            case Variant::FLOAT:
                nsValue = @((double)value);
                break;
            case Variant::BOOL:
                nsValue = @((bool)value);
                break;
            default:
                NSLog(@"Unsupported parameter type for key: %s", key.utf8().get_data());
                continue;
        }
        
        if (nsValue) {
            [nsParameters setObject:nsValue forKey:nsKey];
        }
    }
    
    NSLog(@"Logging Appodeal revenue event: %@ %.2f with parameters: %@", nsCurrency, amount, nsParameters);
    [Appodeal trackInAppPurchase:nsAmount currency:nsCurrency];
    
    emit_signal("event_logged", "revenue_event");
}

void Appodealplugin::set_user_id(const String &user_id) {
    if (!initialized) {
        NSLog(@"Appodeal not initialized. Cannot set user ID");
        return;
    }
    
    NSString *nsUserId = [NSString stringWithUTF8String:user_id.utf8().get_data()];
    NSLog(@"Setting user ID: %@", nsUserId);
    [Appodeal setUserId:nsUserId];
}

void Appodealplugin::set_custom_state_value(const String &key, const Variant &value) {
    if (!initialized) {
        NSLog(@"Appodeal not initialized. Cannot set custom state value");
        return;
    }
    
    NSString *nsKey = [NSString stringWithUTF8String:key.utf8().get_data()];
    id nsValue = nil;
    
    switch (value.get_type()) {
        case Variant::STRING:
            nsValue = [NSString stringWithUTF8String:((String)value).utf8().get_data()];
            break;
        case Variant::INT:
            nsValue = @((int)value);
            break;
        case Variant::FLOAT:
            nsValue = @((double)value);
            break;
        case Variant::BOOL:
            nsValue = @((bool)value);
            break;
        default:
            NSLog(@"Unsupported value type for key: %s", key.utf8().get_data());
            return;
    }
    
    if (nsValue) {
        NSLog(@"Setting custom state value: %@ = %@", nsKey, nsValue);
        [Appodeal setCustomStateValue:nsValue forKey:nsKey];
    }
}

void Appodealplugin::set_child_directed_treatment(bool child_directed) {
    NSLog(@"Setting child directed treatment: %@", child_directed ? @"YES" : @"NO");
    [Appodeal setChildDirectedTreatment:child_directed];
}

// Banner ad methods
void Appodealplugin::show_banner() {
    if (!initialized) {
        NSLog(@"Appodeal not initialized. Cannot show banner");
        return;
    }
    
    NSLog(@"Showing banner ad");
    BOOL success = [Appodeal showAd:AppodealShowStyleBannerTop rootViewController:(UIViewController *)[AppDelegate viewController]];
    
    if (success) {
        banner_shown = true;
        NSLog(@"Banner ad shown successfully");
        emit_signal("banner_shown", true);
    } else {
        NSLog(@"Failed to show banner ad");
        emit_signal("banner_shown", false);
    }
}

void Appodealplugin::show_banner_at_position(const String &position) {
    if (!initialized) {
        NSLog(@"Appodeal not initialized. Cannot show banner");
        return;
    }
    
    NSString *nsPosition = [NSString stringWithUTF8String:position.utf8().get_data()];
    NSLog(@"Showing banner ad at position: %@", nsPosition);
    
    AppodealShowStyle showStyle;
    
    if ([nsPosition isEqualToString:@"top"]) {
        showStyle = AppodealShowStyleBannerTop;
    } else if ([nsPosition isEqualToString:@"bottom"]) {
        showStyle = AppodealShowStyleBannerBottom;
    } else {
        NSLog(@"Invalid banner position: %@. Using top position", nsPosition);
        showStyle = AppodealShowStyleBannerTop;
    }
    
    BOOL success = [Appodeal showAd:showStyle rootViewController:(UIViewController *)[AppDelegate viewController]];
    
    if (success) {
        banner_shown = true;
        NSLog(@"Banner ad shown successfully at position: %@", nsPosition);
        emit_signal("banner_shown", true);
    } else {
        NSLog(@"Failed to show banner ad at position: %@", nsPosition);
        emit_signal("banner_shown", false);
    }
}

void Appodealplugin::hide_banner() {
    if (!initialized) {
        NSLog(@"Appodeal not initialized. Cannot hide banner");
        return;
    }
    
    NSLog(@"Hiding banner ad");
    [Appodeal hideBanner];
    banner_shown = false;
    NSLog(@"Banner ad hidden successfully");
    emit_signal("banner_hidden", true);
}

bool Appodealplugin::is_banner_ready() {
    if (!initialized) {
        return false;
    }
    
    banner_loaded = [Appodeal isReadyForShowWithStyle:AppodealShowStyleBannerTop];
    return banner_loaded;
}

bool Appodealplugin::is_banner_shown() {
    return banner_shown;
}

void Appodealplugin::set_banner_animation_enabled(bool enabled) {
    if (!initialized) {
        NSLog(@"Appodeal not initialized. Cannot set banner animation");
        return;
    }
    
    NSLog(@"Setting banner animation: %@", enabled ? @"YES" : @"NO");
    [Appodeal setBannerAnimationEnabled:enabled];
}

void Appodealplugin::set_smart_banners_enabled(bool enabled) {
    if (!initialized) {
        NSLog(@"Appodeal not initialized. Cannot set smart banners");
        return;
    }
    
    NSLog(@"Setting smart banners: %@", enabled ? @"YES" : @"NO");
    [Appodeal setSmartBannersEnabled:enabled];
}

void Appodealplugin::check_appodeal() {
    NSLog(@"Appodeal check");
    NSString *sdkVersion = [Appodeal getVersion];
    NSLog(@"Appodeal check: %@", sdkVersion);
    emit_signal("signal_test", "Hello from Appodealplugin");
}

String Appodealplugin::get_appodeal_version() {
    NSString *version = [Appodeal getVersion];
    return String::utf8([version UTF8String]);
}

bool Appodealplugin::is_initialized() {
    return initialized;
}