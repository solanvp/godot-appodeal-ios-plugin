# Appodeal Plugin for Godot

This plugin integrates the Appodeal SDK into Godot projects for iOS, providing event logging, revenue tracking, banner ads, and user metadata capabilities.

## Features

- **SDK Initialization**: Initialize Appodeal with your API key
- **Event Logging**: Log custom events with or without parameters
- **Revenue Tracking**: Track revenue events for monetization analytics
- **Banner Ads**: Show, hide, and manage banner advertisements
- **User Metadata**: Set user ID and custom state values for targeting
- **Compliance**: COPPA compliance support
- **Signal System**: Godot signals for initialization and event logging callbacks

## Installation

1. Copy the `appodealplugin` folder to your Godot project's `addons` directory
2. Enable the plugin in Project Settings > Plugins
3. Add the Appodeal SDK to your iOS project (via CocoaPods or manual integration)

### CocoaPods Integration

Add to your `Podfile`:
```ruby
pod 'Appodeal'
```

## Usage

### Basic Initialization

```gdscript
extends Node

func _ready():
    # Connect to signals
    Appodealplugin.appodeal_initialized.connect(_on_appodeal_initialized)
    Appodealplugin.event_logged.connect(_on_event_logged)
    Appodealplugin.banner_shown.connect(_on_banner_shown)
    Appodealplugin.banner_hidden.connect(_on_banner_hidden)
    
    # Initialize with API key
    Appodealplugin.initialize_appodeal("your_api_key_here")
```

### Banner Ads

```gdscript
# Show banner at top position
Appodealplugin.show_banner_at_position("top")

# Show banner at bottom position
Appodealplugin.show_banner_at_position("bottom")

# Simple banner show (defaults to top)
Appodealplugin.show_banner()

# Hide banner
Appodealplugin.hide_banner()

# Check banner status
var is_ready = Appodealplugin.is_banner_ready()
var is_shown = Appodealplugin.is_banner_shown()

# Configure banner
Appodealplugin.set_banner_animation_enabled(true)
Appodealplugin.set_smart_banners_enabled(true)
```

**Note**: Banner ads require a valid view controller to display properly. This plugin automatically uses the main Godot view controller (`AppDelegate.viewController`) to ensure banners display correctly.

### Event Logging

```gdscript
# Simple event logging
Appodealplugin.log_event("level_completed")

# Event with parameters
var event_data = {
    "level_number": 5,
    "score": 1500,
    "difficulty": "hard"
}
Appodealplugin.log_event_with_parameters("level_completed", event_data)
```

### Revenue Tracking

```gdscript
# Simple revenue event
Appodealplugin.log_revenue_event("USD", 4.99)

# Revenue event with parameters
var revenue_data = {
    "product_id": "coins_pack_100",
    "quantity": 1,
    "transaction_id": "txn_123456789"
}
Appodealplugin.log_revenue_event_with_parameters("USD", 4.99, revenue_data)
```

### User Metadata

```gdscript
# Set user ID for targeting
Appodealplugin.set_user_id("user123")

# Set custom state values for segmentation
Appodealplugin.set_custom_state_value("completed_levels", 5)
Appodealplugin.set_custom_state_value("user_type", "premium")
Appodealplugin.set_custom_state_value("last_login", "2024-01-15")
```

### Compliance

```gdscript
# Set child directed treatment for COPPA compliance
Appodealplugin.set_child_directed_treatment(false)  # Set to true if app is for children
```

## API Reference

### Initialization Methods

- `initialize_appodeal(api_key: String)`: Initialize with API key
- `initialize_appodeal_with_consent(api_key: String, has_consent: bool)`: Initialize with consent

### Banner Ad Methods

- `show_banner()`: Show banner at top position
- `show_banner_at_position(position: String)`: Show banner at specified position ("top" or "bottom")
- `hide_banner()`: Hide banner ad
- `is_banner_ready() -> bool`: Check if banner is ready to show
- `is_banner_shown() -> bool`: Check if banner is currently shown
- `set_banner_animation_enabled(enabled: bool)`: Enable/disable banner animation
- `set_smart_banners_enabled(enabled: bool)`: Enable/disable smart banners (auto-resize)

### Event Logging Methods

- `log_event(event_name: String)`: Log simple event
- `log_event_with_parameters(event_name: String, parameters: Dictionary)`: Log event with parameters
- `log_revenue_event(currency: String, amount: float)`: Log revenue event
- `log_revenue_event_with_parameters(currency: String, amount: float, parameters: Dictionary)`: Log revenue event with parameters

### User Metadata Methods

- `set_user_id(user_id: String)`: Set user ID for targeting
- `set_custom_state_value(key: String, value: Variant)`: Set custom state value for segmentation

### Compliance Methods

- `set_child_directed_treatment(child_directed: bool)`: Set COPPA compliance flag

### Utility Methods

- `get_appodeal_version() -> String`: Get SDK version
- `is_initialized() -> bool`: Check if SDK is initialized
- `check_appodeal()`: Debug method to check SDK status

## Signals

- `appodeal_initialized(success: bool)`: Emitted when initialization completes
- `event_logged(event_name: String)`: Emitted when an event is logged
- `banner_shown(success: bool)`: Emitted when banner is shown
- `banner_hidden(success: bool)`: Emitted when banner is hidden
- `signal_test(result: String)`: Debug signal

## Support

For issues related to this plugin, please check the Godot documentation and Appodeal SDK documentation. 