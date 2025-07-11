extends Node

# Appodeal Plugin Example
# This script demonstrates how to use the Appodeal plugin for iOS

# Replace with your actual Appodeal API key
const APPODEAL_API_KEY = "your_appodeal_api_key_here"

func _ready():
    # Connect to Appodeal signals
    Appodealplugin.appodeal_initialized.connect(_on_appodeal_initialized)
    Appodealplugin.event_logged.connect(_on_event_logged)
    Appodealplugin.banner_shown.connect(_on_banner_shown)
    Appodealplugin.banner_hidden.connect(_on_banner_hidden)
    
    # Initialize Appodeal SDK
    initialize_appodeal()
    
    # Set up user metadata
    setup_user_metadata()
    
    # Set child directed treatment (COPPA compliance)
    setup_compliance()

func initialize_appodeal():
    print("Initializing Appodeal SDK...")
    
    # Initialize with API key
    Appodealplugin.initialize_appodeal(APPODEAL_API_KEY)
    
    # Alternative: Initialize with consent
    # Appodealplugin.initialize_appodeal_with_consent(APPODEAL_API_KEY, true)

func setup_user_metadata():
    # Set user ID for targeting
    Appodealplugin.set_user_id("user123")
    
    # Set custom state values for segmentation
    Appodealplugin.set_custom_state_value("completed_levels", 5)
    Appodealplugin.set_custom_state_value("user_type", "premium")
    Appodealplugin.set_custom_state_value("last_login", "2024-01-15")

func setup_compliance():
    # Set child directed treatment for COPPA compliance
    Appodealplugin.set_child_directed_treatment(false)  # Set to true if app is for children

func log_game_events():
    # Log simple events
    Appodealplugin.log_event("level_completed")
    Appodealplugin.log_event("purchase_initiated")
    
    # Log events with parameters
    var level_data = {
        "level_number": 5,
        "score": 1500,
        "time_spent": 120.5,
        "difficulty": "hard"
    }
    Appodealplugin.log_event_with_parameters("level_completed", level_data)
    
    # Log purchase events with parameters
    var purchase_data = {
        "item_id": "premium_pack",
        "price": 9.99,
        "currency": "USD",
        "store": "app_store"
    }
    Appodealplugin.log_event_with_parameters("purchase_completed", purchase_data)

func log_revenue_events():
    # Log simple revenue events
    Appodealplugin.log_revenue_event("USD", 4.99)
    
    # Log revenue events with additional parameters
    var revenue_data = {
        "product_id": "coins_pack_100",
        "quantity": 1,
        "store": "app_store",
        "transaction_id": "txn_123456789"
    }
    Appodealplugin.log_revenue_event_with_parameters("USD", 4.99, revenue_data)

# Banner ad functions
func show_banner_ads():
    # Show banner at top position
    Appodealplugin.show_banner_at_position("top")
    
    # Alternative: Show banner at bottom position
    # Appodealplugin.show_banner_at_position("bottom")
    
    # Simple banner show (defaults to top)
    # Appodealplugin.show_banner()

func hide_banner_ads():
    Appodealplugin.hide_banner()

func check_banner_status():
    var is_ready = Appodealplugin.is_banner_ready()
    var is_shown = Appodealplugin.is_banner_shown()
    
    print("Banner ready: ", is_ready)
    print("Banner shown: ", is_shown)

func configure_banner():
    # Set banner animation
    Appodealplugin.set_banner_animation_enabled(true)
    
    # Set smart banners (auto-resize based on screen size)
    Appodealplugin.set_smart_banners_enabled(true)

func _on_appodeal_initialized(success: bool):
    if success:
        print("Appodeal SDK initialized successfully!")
        print("Appodeal version: ", Appodealplugin.get_appodeal_version())
        
        # Start logging events after initialization
        log_game_events()
        log_revenue_events()
        
        # Configure and show banner ads
        configure_banner()
        show_banner_ads()
        
        # Check banner status
        check_banner_status()
    else:
        print("Failed to initialize Appodeal SDK")

func _on_event_logged(event_name: String):
    print("Event logged: ", event_name)

func _on_banner_shown(success: bool):
    if success:
        print("Banner ad shown successfully")
    else:
        print("Failed to show banner ad")

func _on_banner_hidden(success: bool):
    if success:
        print("Banner ad hidden successfully")
    else:
        print("Failed to hide banner ad")

# Example usage in game events
func on_level_completed(level_number: int, score: int, time_spent: float):
    var event_data = {
        "level_number": level_number,
        "score": score,
        "time_spent": time_spent,
        "timestamp": Time.get_unix_time_from_system()
    }
    Appodealplugin.log_event_with_parameters("level_completed", event_data)
    
    # Update custom state for segmentation
    Appodealplugin.set_custom_state_value("completed_levels", level_number)

func on_purchase_completed(product_id: String, price: float, currency: String):
    var purchase_data = {
        "product_id": product_id,
        "price": price,
        "currency": currency,
        "store": "app_store"
    }
    Appodealplugin.log_event_with_parameters("purchase_completed", purchase_data)
    Appodealplugin.log_revenue_event_with_parameters(currency, price, purchase_data)

func on_user_action(action: String, parameters: Dictionary = {}):
    Appodealplugin.log_event_with_parameters(action, parameters)

# Banner ad management examples
func on_game_paused():
    # Hide banner when game is paused
    hide_banner_ads()

func on_game_resumed():
    # Show banner when game is resumed
    show_banner_ads()

func on_level_started():
    # Show banner at bottom for level start
    Appodealplugin.show_banner_at_position("bottom")

func on_level_finished():
    # Hide banner when level is finished
    hide_banner_ads() 