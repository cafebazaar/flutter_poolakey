<img src="https://github.com/cafebazaar/flutter_poolakey/raw/master/repo_files/flutter_poolakey.jpg"/>

[![pub package](https://img.shields.io/pub/v/flutter_poolakey.svg)](https://pub.dartlang.org/packages/flutter_poolakey)

### Android In-App Billing *Flutter* SDK for [Cafe Bazaar](https://cafebazaar.ir/?l=en) App Store.

## Getting Started

To start working with Flutter Poolakey, you need to add its dependency in your
project's `pubspec.yaml` file:

### Dependency

```yaml
dependencies:
  flutter_poolakey: ^2.2.0
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

> [Poolakey](https://github.com/cafebazaar/Poolakey) is an Android In-App Billing SDK
> for [Cafe Bazaar](https://cafebazaar.ir/?l=en) App Store.
