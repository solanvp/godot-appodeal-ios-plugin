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

@interface AppodealRewardedDelegateBridge : NSObject <AppodealRewardedVideoDelegate>
@end

@implementation AppodealRewardedDelegateBridge

- (void)rewardedVideoDidLoadAdIsPrecache:(BOOL)precache {
    NSLog(@"Rewarded video loaded, precache: %@", precache ? @"YES" : @"NO");
    // No signal needed for load success, just log
}

- (void)rewardedVideoDidFailToLoadAd {
    NSLog(@"Rewarded video failed to load");
    if (Appodealplugin::get_singleton()) {
        Appodealplugin::get_singleton()->emit_signal("rewarded_failed", false);
    }
}

- (void)rewardedVideoDidFailToPresentWithError:(NSError *)error {
    NSLog(@"Rewarded video failed to present with error: %@", error);
    if (Appodealplugin::get_singleton()) {
        Appodealplugin::get_singleton()->emit_signal("rewarded_failed", false);
    }
}

- (void)rewardedVideoDidPresent {
    NSLog(@"Rewarded video presented");
    if (Appodealplugin::get_singleton()) {
        Appodealplugin::get_singleton()->emit_signal("rewarded_shown", true);
    }
}

- (void)rewardedVideoDidDismiss {
    NSLog(@"Rewarded video dismissed");
    if (Appodealplugin::get_singleton()) {
        Appodealplugin::get_singleton()->emit_signal("rewarded_closed", true);
    }
}

- (void)rewardedVideoDidFinish:(float)rewardAmount name:(NSString *)rewardName {
    NSLog(@"Rewarded video finished - Reward: %@, Amount: %.2f", rewardName, rewardAmount);
    if (Appodealplugin::get_singleton()) {
        Appodealplugin::get_singleton()->emit_signal("rewarded_finished", true);
    }
}

- (void)rewardedVideoDidClick {
    NSLog(@"Rewarded video clicked");
    if (Appodealplugin::get_singleton()) {
        Appodealplugin::get_singleton()->emit_signal("rewarded_clicked", true);
    }
}

@end

Appodealplugin *Appodealplugin::instance = NULL;

Appodealplugin::Appodealplugin() {
    instance = this;
    initialized = false;
    banner_loaded = false;
    banner_shown = false;
    rewarded_delegate_bridge = [[AppodealRewardedDelegateBridge alloc] init];
    NSLog(@"initialize appodealplugin");
    [Appodeal setRewardedVideoDelegate:rewarded_delegate_bridge];
}

Appodealplugin::~Appodealplugin() {
    if (instance == this) {
        instance = NULL;
    }
    // ARC handles memory management automatically, no need for release
    rewarded_delegate_bridge = nullptr;
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
    // Interstitial ad signals
    ADD_SIGNAL(MethodInfo("interstitial_shown", PropertyInfo(Variant::BOOL, "success")));
    ADD_SIGNAL(MethodInfo("interstitial_closed", PropertyInfo(Variant::BOOL, "success")));
    ADD_SIGNAL(MethodInfo("interstitial_failed", PropertyInfo(Variant::BOOL, "success")));
    ADD_SIGNAL(MethodInfo("interstitial_clicked", PropertyInfo(Variant::BOOL, "success"))); // Optional, if supported
    // Rewarded ad signals
    ADD_SIGNAL(MethodInfo("rewarded_shown", PropertyInfo(Variant::BOOL, "success")));
    ADD_SIGNAL(MethodInfo("rewarded_closed", PropertyInfo(Variant::BOOL, "success")));
    ADD_SIGNAL(MethodInfo("rewarded_failed", PropertyInfo(Variant::BOOL, "success")));
    ADD_SIGNAL(MethodInfo("rewarded_clicked", PropertyInfo(Variant::BOOL, "success"))); // Optional, if supported
    ADD_SIGNAL(MethodInfo("rewarded_finished", PropertyInfo(Variant::BOOL, "success"))); // User earned reward
    
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
    
    // Interstitial ad methods
    ClassDB::bind_method("show_interstitial", &Appodealplugin::show_interstitial);
    ClassDB::bind_method("is_interstitial_ready", &Appodealplugin::is_interstitial_ready);
    
    // Rewarded ad methods
    ClassDB::bind_method("show_rewarded", &Appodealplugin::show_rewarded);
    ClassDB::bind_method("is_rewarded_ready", &Appodealplugin::is_rewarded_ready);
    
    // Utility methods
    ClassDB::bind_method("check_appodeal", &Appodealplugin::check_appodeal);
    ClassDB::bind_method("get_appodeal_version", &Appodealplugin::get_appodeal_version);
    ClassDB::bind_method("is_initialized", &Appodealplugin::is_initialized);
}

void Appodealplugin::initialize_appodeal(const String &api_key) {
    NSString *nsApiKey = [NSString stringWithUTF8String:api_key.utf8().get_data()];
    
    [Appodeal initializeWithApiKey:nsApiKey
                            types:AppodealAdTypeInterstitial | AppodealAdTypeRewardedVideo | AppodealAdTypeBanner];
    
    initialized = true;
    NSLog(@"Appodeal initialized successfully");
    emit_signal("appodeal_initialized", true);
}

void Appodealplugin::initialize_appodeal_with_consent(const String &api_key, bool has_consent) {
    NSString *nsApiKey = [NSString stringWithUTF8String:api_key.utf8().get_data()];
    
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
    BOOL success = [Appodeal showAd:AppodealShowStyleBannerBottom rootViewController:(UIViewController *)[AppDelegate viewController]];
    
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

// Interstitial ad methods
void Appodealplugin::show_interstitial() {
    if (!initialized) {
        NSLog(@"Appodeal not initialized. Cannot show interstitial");
        emit_signal("interstitial_failed", false);
        return;
    }
    NSLog(@"Showing interstitial ad");
    BOOL success = [Appodeal showAd:AppodealShowStyleInterstitial rootViewController:(UIViewController *)[AppDelegate viewController]];
    if (success) {
        NSLog(@"Interstitial ad shown successfully");
        emit_signal("interstitial_shown", true);
        // Note: To emit 'interstitial_closed' and 'interstitial_clicked', you should implement the AppodealInterstitialDelegate and forward those callbacks here.
    } else {
        NSLog(@"Failed to show interstitial ad");
        emit_signal("interstitial_failed", false);
    }
}

bool Appodealplugin::is_interstitial_ready() {
    if (!initialized) {
        return false;
    }
    return [Appodeal isReadyForShowWithStyle:AppodealShowStyleInterstitial];
}

// Rewarded ad methods
void Appodealplugin::show_rewarded() {
    if (!initialized) {
        NSLog(@"Appodeal not initialized. Cannot show rewarded");
        emit_signal("rewarded_failed", false);
        return;
    }
    NSLog(@"Showing rewarded ad");
    BOOL success = [Appodeal showAd:AppodealShowStyleRewardedVideo rootViewController:(UIViewController *)[AppDelegate viewController]];
    if (success) {
        NSLog(@"Rewarded ad shown successfully");
        emit_signal("rewarded_shown", true);
        // Note: To emit 'rewarded_closed', 'rewarded_clicked', and 'rewarded_finished', you should implement the AppodealRewardedVideoDelegate and forward those callbacks here.
    } else {
        NSLog(@"Failed to show rewarded ad");
        emit_signal("rewarded_failed", false);
    }
}

bool Appodealplugin::is_rewarded_ready() {
    if (!initialized) {
        return false;
    }
    return [Appodeal isReadyForShowWithStyle:AppodealShowStyleRewardedVideo];
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