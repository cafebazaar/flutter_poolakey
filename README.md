<img src="https://github.com/cafebazaar/flutter_poolakey/raw/master/repo_files/flutter_poolakey.jpg"/>

[![pub package](https://img.shields.io/pub/v/flutter_poolakey.svg)](https://pub.dartlang.org/packages/flutter_poolakey)

### Android In-App Billing *Flutter* SDK for [Cafe Bazaar](https://cafebazaar.ir/?l=en) App Store.

## Getting Started

To start working with Flutter Poolakey, you need to add its dependency in your
project's `pubspec.yaml` file:

### Dependency

```yaml
dependencies:
  flutter_poolakey: ^2.2.0-1.0.0-alpha01
```

Then run the below command to retrieve it:

```shell
flutter packages get
```

And then Go to the allprojects section of your project gradle file and add the JitPack repository to the repositories block:
```groovy
allprojects {
  repositories {
    // add JitPack
    maven { url 'https://jitpack.io' }
  }
} 
```

### Import it

Now in your Dart code, you can use:

```dart
import 'package:flutter_poolakey/flutter_poolakey.dart';
```

### How to use

For more information regarding the usage of flutter Poolakey, please check out
the [wiki](https://github.com/cafebazaar/flutter_poolakey/wiki) page.

### Sample

There is a fully functional sample application that demonstrates the usage of flutter Poolakey, all you have
to do is cloning the project and running
the [app](https://github.com/cafebazaar/flutter_poolakey/tree/master/example) module.


#### flutter_poolakey is a wrapper around [Poolakey](https://github.com/cafebazaar/Poolakey) to use in Flutter.

For additional help, please refer to the [wiki](https://github.com/cafebazaar/flutter_poolakey/wiki) or file an issue on GitHub.
> [Poolakey](https://github.com/cafebazaar/Poolakey) is an Android In-App Billing SDK
> for [Cafe Bazaar](https://cafebazaar.ir/?l=en) App Store.


## Important Configuration Notes
If you face any issues consider doing these:

1. **JitPack Repository**
   Use the following syntax for JitPack repository in your `build.gradle`:
   ```gradle
   allprojects {
     repositories {
       maven { url = uri("https://jitpack.io") }
     }
   }
   ```

2. **Java Version Configuration**
   If you face Java-related issues, update your `android/app/build.gradle`:
   ```gradle
   android {
     compileOptions {
       sourceCompatibility = JavaVersion.VERSION_11
       targetCompatibility = JavaVersion.VERSION_11
     }
   }
   ```

3. **Gradle Plugin Version**
   Ensure you're using a compatible Gradle plugin version in your project's `build.gradle`:
   ```gradle
   buildscript {
     dependencies {
       classpath("com.android.tools.build:gradle:8.7.0")
     }
   }
   ```

4. **Kotlin Version**
   Update the Kotlin version in your project's `build.gradle`:
   ```gradle
   buildscript {
     ext.kotlin_version = "1.8.22"
     // ...
   }
   ```

## Troubleshooting

If you encounter build issues, please verify:
- All the above configurations are correctly set
- Your project's Gradle version is compatible with the Android Gradle Plugin
- You have Java 11 or later installed and properly configured in your environment

