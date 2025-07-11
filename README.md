# Godot 4.4 Appodeal plugin

### Work in progress

This is only the first step towards integrating the Appodeal SDK to Godot 4.4, latest versions of both as of June 2025

### Setup

1. Download and build godot source. You might need to install scons (recomended with homebrew)
```
    cd plugin
    git clone -b 4.4 https://github.com/godotengine/godot-cpp.git
    cd godot
    scons platform=ios target=template_debug -j4
```

2. Download Appodeal SDK zip from https://docs.appodeal.com/ios/get-started (Manual tab) and extract and place Appodeal.xcframework under plugin/sdk.


3. Build
```
    cd plugin
    scons target=release_debug arch=arm64 plugin=appodealplugin --appodeal-xcframework-path=./sdk/Appodeal.xcframework
```

4. Copy appodealplugin.gdip (support_files folder) and the output .a file (bin folder) to `/ios/plugins` of your main Godot game. Rename the .a file to appodealplugin.a

5. Add the following gdscript snippet on your game:
```
    if Engine.has_singleton("Appodealplugin"):
		var appodealplugin = Engine.get_singleton("Appodealplugin")
		appodealplugin.connect("signal_test", func(result): 
			print(result)
		)
		appodealplugin.check_appodeal()
```

6. After exporting the game to iOS, place the Podfile (support_files) on the root of the exported project (alongside .xcodeproj) and run `pod install`

7. Open the generated .xcworkspace. Under Target -> General, add all the frameworks of the project (the downloaded pods). Select all and mark them as "Do Not Embed".

8. After running you should see an output like `Appodeal check: 3.8.0` on xcode console, it means the integration was successful

