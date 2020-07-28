# GTBlurView

![Language](https://img.shields.io/badge/Language-Swift-orange)
![Platform](https://img.shields.io/badge/Platform-iOS-lightgrey)
![License](https://img.shields.io/badge/License-MIT-brightgreen)
![Version](https://img.shields.io/badge/Version-1.0.0-blue)

#### Add blur effect to any view in a simple, modern and declarative way.

## About

GTBlurView is a Swift library that allows to add blur effect to any view with or without vibrancy in a modern and declarative fashion. Made for UIKit based projects on iOS.

## Integrating GTBlurView

To integrate `GTBlurView` into your projects follow the next steps:

1. Copy the repository's URL to GitHub (it can be found by clicking on the *Clone or Download* button).
2. Open your project in Xcode.
3. Go to menu **File > Swift Packages > Add Package Dependency...**.
4. Paste the URL, select the package when it appears and click Next.
5. In the *Rules* leave the default option selected (*Up to Next Major*) and click Next.
6. Select the *GTBlurView* package and select the *Target* to add to; click Finish.
7. In Xcode, select your project in the Project navigator and go to *General* tab.
8. Add GTBlurView framework under *Frameworks, Libraries, and Embedded Content* section.

Don't forget to import `GTBlurView` module anywhere you are about to use it:

```swift
import GTBlurView
```

## Public API

```swift

// -- Class Methods

// Create a `GTBlurView` view with a blur effect visual effect view
// and add it to the given parent view.
addBlur(to:)

// Remove the `GTBlurView` instance and all of its subviews from the given view.
remove(from:)

// Remove `GTBlurView` instance and all of its subviews from the given view animated.
removeAnimated(from:duration:completion:)


// -- Instance Methods

// Change the default blur style.
set(style:)

// Add vibrancy to blur effect.
useVibrancy()

// Add a subview to vibrancy effect view.
addVibrancySubview(_:layoutRules:)

// Remove `GTBlurView` instance and its contents on tap.
removeOnTap(animated:animationDuration:actionHandler:completion:)
 
// Show the `GTBlurView` instance containing the blur effect without animation.
show()

// Show the `GTBlurView` instance containing the blur effect view animated.
showAnimated(duration:completion:)

```

## Usage Example

The simplest and fastest way to add blur effect to a view is the following:

```swift
GTBlurView.addBlur(to: self).show()

// or

GTBlurView.addBlur(to: someView).show()
```

where `self` and `someView` are UIView objects.

Blur view can be shown animated as well:

```swift
GTBlurView.addBlur(to: someView).showAnimated()
```

Animation duration and completion handler can be optionally provided. Default animation duration is 0.4 seconds.

```swift
GTBlurView.addBlur(to: self).showAnimated(duration: 0.25) {
    // do something upon completion...
}
```

Both `show()` and `showAnimated(duration:completion:)` methods return a `GTBlurView` instance but they are marked with the `@discardableResult` attribute. That way assigning it to a variable or property is optional and Xcode will not show any warnings in case you avoid to do so.

### Blur Effect Style

Default blur effect style is `.regular`. Override it like so:

```swift
GTBlurView.addBlur(to: self)
    .set(style: .dark)
    .show()
```

### Remove On Tap

It's possible to remove blur view by just tapping on it.  Use the `removeOnTap(animated:animationDuration:delay:actionHandler:completion:)` method to enable it.

```swift
GTBlurView.addBlur(to: self)
    .removeOnTap(animated: true, animationDuration: 0.25, actionHandler: {
        // Do something when tapping on GTBlurView instance...
    }, completion: {
        // Do something when GTBlurView instance has been removed...
    })
    .show()
```

Note that the only required argument is the `animated` value. All the rest are optional, and pass only those necessary to your implementation. Also:

* `actionHandler` closure can be used to trigger additional actions right when the blur view is tapped.
* `completion` closure is called when blur view dismissal is finished.

### Use Vibrancy

To use vibrancy effect along with the blur effect use the `useVibrancy()` method:

```swift
GTBlurView.addBlur(to: self)
    .useVibrancy()
    .show()
```

To add subviews to vibrancy's content view call the `addVibrancySubview(_:layoutRules:)` method:

```swift
let button = UIButton()
// Button configuration.

GTBlurView.addBlur(to: someView)
   .useVibrancy()
   .addVibrancySubview(button, layoutRules: .auto)
   .show()
```

See the documentation of the `VibrancySubviewsLayoutRules` `enum` for details about laying out subviews to vibrancy effect view.

### Removing Blur View

One way to remove a blur view is by using the `removeOnTap(animated:animationDuration:delay:actionHandler:completion:)` method as shown above. Besides that, there are two ways to manually remove it:

**Without animation**

```swift
GTBlurView.addBlur(to: someView).show()
GTBlurView.remove(from: someView)
```

**With animation**

```swift
GTBlurView.addBlur(to: someView).show()
GTBlurView.removeAnimated(from: someView)
```

Animation duration and a completion handler can be optionally provided:

```swift
GTBlurView.addBlur(to: someView).show()

GTBlurView.removeAnimated(from: someView, duration: 0.25) {
    // do something once blur view has been removed...
}
```

### Putting Everything Together

```swift
GTBlurView.addBlur(to: self)
    .set(style: .regular)
    .useVibrancy()
    .addVibrancySubview(someView, layoutRules: .none)
    .removeOnTap(animated: true, animationDuration: 0.25, actionHandler: {
        // Do something when tapping on GTBlurView instance...
    }, completion: {
        // Do something when GTBlurView instance has been removed...
    })
    .showAnimated(duration: 0.25)
```

## Other

To change blur transparency level you can change the `alpha` value of the returned `GTBlurView` instance by any of the `show()` or `showAnimated(duration:completion:)` methods.

Read the documentation of each method using Xcode's Quick Help for additional details. 

## License

GTBlurView is licensed under the MIT license.
