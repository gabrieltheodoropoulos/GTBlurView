//
//  GTBlurView.swift
//
//
//  Created by Gabriel Theodoropoulos.
//

import UIKit

/**
 Add blur effect to any view in a simple, modern and declarative way.
 
 Usage example:
 
 ```
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
 
 ## Public Methods
 
 ```
 // Create a `GTBlurView` view with a blur effect visual effect view
 // and add it to the given parent view.
 addBlur(to:)
 
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
  
 // Remove the `GTBlurView` instance and all of its subviews from the given view.
 remove(from:)
 
 // Remove `GTBlurView` instance and all of its subviews from the given view animated.
 removeAnimated(from:duration:completion:)
 ```
 
 */
open class GTBlurView: UIView {
    
    // MARK: - Inner Types
    
    /**
     Values that specify how subviews should be layed out on vibrancy effect view.
     
     ## Possible cases:
     * `none`: Subviews will not be laid out at all.
     * `auto`: Subviews will have equal leading, top, trailing and bottom
     anchors to the vibrancy effect view's content view.
     * `frame(CGRect)`: Autolayout constraints will be created based on the origin
     and size of the given frame.
     * `constraints([NSLayoutConstraint])`: Provided constraints will be used to layout subview to
     vibrancy effect view's content view.
     */
    public enum VibrancySubviewsLayoutRules {
        /// Subviews will not be laid out at all.
        case none
        
        /// Subviews will have equal leading, top, trailing and bottom
        /// anchors to the vibrancy effect view's content view.
        case auto
        
        /// Autolayout constraints will be created based on the origin
        /// and size of the given frame.
        case frame(CGRect)
        
        /// Provided constraints will be used to layout subviews to
        /// vibrancy effect view's content view.
        case constraints([NSLayoutConstraint])
    }
    
    
    // MARK: - Properties
    
    /// The blur effect assigned to blur effect view.
    private var blurEffect: UIBlurEffect?
    
    /// The blur effect view that shows the blur effect.
    private var blurEffectView: UIVisualEffectView?
    
    /// The vibrancy effect view that shows the vibrancy effect. It
    /// can contain subviews added to its content view with the
    /// `addVibrancySubview(_:layoutRules:)` method.
    private(set) public var vibrancyEffectView: UIVisualEffectView?
    
    /// The vibrancy effect view's content view that contains any subviews.
    private(set) public var vibrancyEffectViewContent: UIView?
    
    /// The action handler to call upon tapping self instance to remove.
    private var removeActionHandler: (() -> Void)?
    
    /// The action handler to call when removing self instance after tapping
    /// on it is complete.
    private var removeCompletionHandler: (() -> Void)?
    
    /// Keep whether self instance should be removed animated or not when tapped.
    private var removeAnimated = false
    
    /// The animation duration of removing self instance from its superview when
    /// tapping on it.
    private var removeAnimationDuration: TimeInterval?
    
    /// The delay before performing self removal from the superview animated.
    private var removeAnimationDelay: TimeInterval = 0.0
    
    /// The view that contains the `GTBlurView` instance.
    private var parentView: UIView?
    
    
    deinit {
        // print("Deinit in GTBlurView!")
    }
    
    
    // MARK: - Public Class Methods
    
    /**
     Create a `GTBlurView` view with a blur effect visual effect view
     and add it to the given parent view.
     
     * Use this class method to create a new `GTBlurView` instance that is
     added to the given `view` object as a subview. Internally, a visual effect
     view (`UIVisualEffectView`) with the blur effect is added to the `GTBlurView`
     instance as a subview.
     * * *
     * Change the `alpha` value of the returned `GTBlurView` object to change the blur
     transparency level. **Do not** change the `alpha` value of the blur effect view
     itself!
     * * *
     * The `.regular` style is assigned by default to blur effect. To change that,
     use the `set(style:)` intance method in the returned object of this method.
     * * *
     * Call `show()` or `showAnimated()` (providing optionally any necessary arguments)
     on a `GTBlurView` object to make the blur effect view appear animated or not.
     * * *
     * Both `show()` and `showAnimated()` are marked with `@discardableResult` attribute,
     so assigning the returned `GTBlurView` object to a variable or property is not necessary.
     * * *
     Example:
     ```
     // Simplest way to show blur effect view.
     GTBlurView.addBlur(to: someView)
        .show()
     ```
     
     - Parameter view: The parent view that will contain the `GTBlurView` instance.
     - Returns: The new `GTBlurView` instance that is added to `view`.
     */
    public class func addBlur(to view: UIView) -> GTBlurView {
        // Initialize a GTBlurView instance.
        let blurView = GTBlurView()
        
        // Add it to view as a subview and set the constraints.
        view.addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        blurView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // Initialize the blur effect and the blur effect view,
        // and add the second to blurView as a subview.
        blurView.addBlurEffectView()
        
        // Make blurView hidden. This will change on any of the show methods.
        blurView.isHidden = true
        
        // Keep the container view.
        blurView.parentView = view
        
        // Return blur view.
        return blurView
    }
    
    
    /**
     Remove the `GTBlurView` instance and all of its subviews from the given view.
     
     It's not mandatory to explicitly call this method if `removeOnTap(animated:)` triggers
     the removal of the `GTBlurView` instance from its superview.
     
     Example:
     ```
     GTBlurView.addBlur(to: someView).show()
     
     GTBlurView.remove(from: someView)
     ```
     
     - Parameter view: The view that contains the `GTBlurView` instance that should be dismissed.
     */
    public class func remove(from view: UIView) {
        guard var blurView = view.subviews.filter({ (subview) -> Bool in
                return subview.isKind(of: GTBlurView.self)
            }).first as? GTBlurView?
            else { return }
        
        blurView?.cleanUp()
        blurView?.removeCompletionHandler?()
        blurView?.removeCompletionHandler = nil
        blurView?.removeFromSuperview()
        blurView = nil
    }
    
    
    /**
     Remove `GTBlurView` instance and all of its subviews from the given view animated.
     
     It's not mandatory to explicitly call this method if `removeOnTap(animated:)` triggers
     the removal of the `GTBlurView` instance from its superview.
     
     Example:
     ```
     GTBlurView.addBlur(to: someView).show()
     
     GTBlurView.removeAnimated(from: someView)
     ```
     
     Example #2:
     ```
     let blurView = GTBlurView.addBlur(to: someView).show()
     
     blurView.removeAnimated(duration: 0.25) {
         // Do something upon completion...
     }
     ```
     
     - Parameter view: The view that contains the `GTBlurView` instance that should be dismissed.
     - Parameter duration: The animation duration. Default value is 0.4 second.
     - Parameter completion: The completion handler that gets called when removing `GTBlurView`
     instance from its superview is finished. Default value is `nil`.
     */
    public class func removeAnimated(from view: UIView, duration: TimeInterval = 0.4, completion: (() -> Void)? = nil) {
        guard var blurView = view.subviews.filter({ (subview) -> Bool in
                return subview.isKind(of: GTBlurView.self)
            }).first as? GTBlurView?
            else { return }
        
        UIView.animate(withDuration: duration, delay: blurView?.removeAnimationDelay ?? 0.0, options: .curveLinear, animations: {
            blurView?.blurEffectView?.effect = nil
            blurView?.vibrancyEffectView?.alpha = 0.0
        }) { (_) in
            blurView?.cleanUp()
            blurView?.removeCompletionHandler?()
            blurView?.removeCompletionHandler = nil
            blurView?.removeFromSuperview()
            completion?()
            blurView = nil
        }
    }
    
    
    // MARK: - Public Instance Methods
        
    /**
     Change the default blur style.
     
     Default blur style is `.regular`. Use this method before calling `show()`
     or `showAnimated()` to provide a different blur style.
     
     Example:
     ```
     // Change blur style before showing the blur effect view.
     GTBlurView.addBlur(to: someView)
        .set(style: dark)
        .show()
     ```
     
     - Parameter style: The new blur style as a `UIBlurEffect.Style` value.
     - Returns: An updated `GTBlurView` instance.
     */
    public func set(style: UIBlurEffect.Style) -> GTBlurView {
        blurEffect = nil
        blurEffect = UIBlurEffect(style: style)
        blurEffectView?.effect = blurEffect
        return self
    }
    
    
    /**
     Add vibrancy to blur effect.
     
     A new visual effect view is created and added to blur effect view's content view.
     That new visual effect view (`vibrancyEffectView` property) is ready to accept
     other views as subviews using the `addVibrancySubview(_:layoutRules:)` method.
     
     - Note: This method has no effect without adding subviews with the
     `addVibrancySubview(_:layoutRules:)` method.
     
     Example:
     ```
     GTBlurView.addBlur(to: someView)
        .useVibrancy()
        .show()
     ```
     
     - Returns: An updated `GTBlurView` instance.
     */
    public func useVibrancy() -> GTBlurView {
        guard let blurEffectView = blurEffectView, let blurEffect = blurEffect else { return self }
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectViewContent = vibrancyEffectView?.contentView
        
        blurEffectView.contentView.addSubview(vibrancyEffectView!)
        vibrancyEffectView?.translatesAutoresizingMaskIntoConstraints = false
        vibrancyEffectView?.leadingAnchor.constraint(equalTo: blurEffectView.contentView.leadingAnchor).isActive = true
        vibrancyEffectView?.trailingAnchor.constraint(equalTo: blurEffectView.contentView.trailingAnchor).isActive = true
        vibrancyEffectView?.topAnchor.constraint(equalTo: blurEffectView.contentView.topAnchor).isActive = true
        vibrancyEffectView?.bottomAnchor.constraint(equalTo: blurEffectView.contentView.bottomAnchor).isActive = true
        
        return self
    }
    
    
    /**
     Add a subview to vibrancy effect view.
     
     Call this method for as many subviews as you need to add to vibrancy effect view.
     Note that `useVibrancy()` method must have been called prior to this one.
     
     - Note: Any provided view is added to the `contentView` of the vibrancy effect view.
     
     Example:
     
     ```
     let button = UIButton()
     // Button configuration.
     
     GTBlurView.addBlur(to: someView)
        .useVibrancy()
        .addVibrancySubview(button, layoutRules: .auto)
        .show()
     ```
     
     - Parameter subview: The subview to add to vibrancy effect view.
     - Parameter layoutRules: A `VibrancySubviewsLayoutRules` value that indicates the way
     subview should be layed out to the vibrancy effect view's content view.
     - Returns: An updated `GTBlurView` instance.
     */
    public func addVibrancySubview(_ subview: UIView, layoutRules: VibrancySubviewsLayoutRules) -> GTBlurView {
        guard let vibrancyView = vibrancyEffectView else { return self }
        
        vibrancyEffectView?.contentView.addSubview(subview)
        
        switch layoutRules {
            case .none: // Do nothing
                break
            
            case .auto: // Apply constraints that make content view equal to vibrancy view.
                subview.translatesAutoresizingMaskIntoConstraints = false
                subview.leadingAnchor.constraint(equalTo: vibrancyView.contentView.leadingAnchor).isActive = true
                subview.trailingAnchor.constraint(equalTo: vibrancyView.contentView.trailingAnchor).isActive = true
                subview.topAnchor.constraint(equalTo: vibrancyView.contentView.topAnchor).isActive = true
                subview.bottomAnchor.constraint(equalTo: vibrancyView.contentView.bottomAnchor).isActive = true
            
            case .frame(let frame): // Applying constraints using origin and size from given frame.
                subview.translatesAutoresizingMaskIntoConstraints = false
                subview.leadingAnchor.constraint(equalTo: vibrancyView.contentView.leadingAnchor, constant: frame.origin.x).isActive = true
                subview.topAnchor.constraint(equalTo: vibrancyView.contentView.topAnchor, constant: frame.origin.y).isActive = true
                subview.widthAnchor.constraint(equalToConstant: frame.size.width).isActive = true
                subview.heightAnchor.constraint(equalToConstant: frame.size.height).isActive = true
            
            case .constraints(let constraints): // Apply given constraints to content view.
                subview.translatesAutoresizingMaskIntoConstraints = false
                subview.addConstraints(constraints)
        }
        
        return self
    }
    
    
    /**
     Remove `GTBlurView` instance and its contents on tap.
     
     Call this method by providing any arguments as needed to make `GTBlurView` and
     its subviews get removed from the superview by just tapping on it.
     
     Example:
     ```
     GTBlurView.addBlur(to: someView)
        .removeOnTap(animated: false)
        .show()
     ```
     
     Example #2:
     ```
     GTBlurView.addBlur(to: someView)
        .removeOnTap(animated: true, animationDuration: 0.25, actionHandler: {
            // Peform actions when tapping to remove...
        }, completion: {
            // Perform actions when GTBlurView instance
            // removal from the superview is finished...
        })
        .show()
     ```
     
     - Parameter animated: Specify whether removal will be animated or not.
     - Parameter animationDuration: Use it when `animated` is `true`. Default value
     is 0.4 seconds.
     - Parameter delay: The amount of time to wait before removing self instance from
     the superview animated.
     - Parameter actionHandler: A callback function that gets called on tap. Use it to
     trigger any necessary actions upon tapping on the `GTBlurView` instance. Default value
     is `nil`.
     - Parameter completion: The completion handler that gets called when removal is finished.
     Default value is `nil`.
     - Returns: An updated `GTBlurView` instance.
     */
    public func removeOnTap(animated: Bool, animationDuration: TimeInterval = 0.4, delay: TimeInterval = 0.0,
                             actionHandler: (() -> Void)? = nil,
                             completion: (() -> Void)? = nil) -> GTBlurView {
        removeAnimated = animated
        removeAnimationDuration = animationDuration
        removeAnimationDelay = delay
        removeActionHandler = actionHandler
        removeCompletionHandler = completion
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        return self
    }
        
    
    /**
     Show the `GTBlurView` instance containing the blur effect without animation.
     
     This method is marked with `@discardableResult` attribute so it's not necessary
     to assign the returned `GTBlurView` instance to any variable or property.
     
     Example:
     ```
     // Change blur style before showing the blur effect view.
     GTBlurView.addBlur(to: someView)
        .show()
     ```
     
     - Returns: The current `GTBlurView` instance.
     */
    @discardableResult
    public func show() -> GTBlurView {
        self.isHidden = false
        return self
    }
    
    
    /**
     Show the `GTBlurView` instance containing the blur effect view animated.
     
     This method is marked with `@discardableResult` attribute so it's not necessary
     to assign the returned `GTBlurView` instance to any variable or property.
     
     Example:
     ```
     GTBlurView.addBlur(to: someView)
        .showAnimated()
     ```
     
     Example #2:
     ```
     GTBlurView.addBlur(to: someView)
        .showAnimated(duration: 0.25) {
            // Perform further actions...
        }
     ```
     
     - Parameter duration: The appearance animation duration. Default value is 0.4 seconds.
     - Parameter completion: A completion handler to be called optionally when the appearance
     animation is finished.
     
     */
    @discardableResult
    public func showAnimated(duration: TimeInterval = 0.4, completion: (() -> Void)? = nil) -> GTBlurView {
        blurEffectView?.effect = nil
        vibrancyEffectView?.alpha = 0.0
        self.isHidden = false
        UIView.animate(withDuration: duration, animations: {
            self.blurEffectView?.effect = self.blurEffect
            self.vibrancyEffectView?.alpha = 1.0
        }) { (_) in
            completion?()
        }
        
        return self
    }
    
    
    
    // MARK: - Fileprivate Methods
    
    /**
     It creates the blur effect using the `.regular` style as default,
     it initializes the blur effect view and it adds it as a subview to self
     instance by setting the proper autolayout constraints properly.
     */
    fileprivate func addBlurEffectView() {
        blurEffect = UIBlurEffect(style: .regular)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        self.addSubview(blurEffectView!)
        blurEffectView!.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView!.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        blurEffectView!.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        blurEffectView!.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        blurEffectView!.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    
    /**
     Clean up self instance by removing subviews and making `nil` any used property.
     */
    fileprivate func cleanUp() {
        vibrancyEffectView?.contentView.subviews.forEach { $0.removeFromSuperview() }
        vibrancyEffectView?.removeFromSuperview()
        blurEffectView?.removeFromSuperview()
        
        parentView = nil
        blurEffect = nil
        blurEffectView = nil
        vibrancyEffectView = nil
        vibrancyEffectViewContent = nil
        removeActionHandler = nil
    }
    
    
    /**
     It handles the tap gesture recognizer added to self when
     `removeOnTap(animated:animationDuration:actionHandler:completion:)`
     method is used.
     
     When this method is called after a tap gesture triggers the removal of
     self and its subviews from its superview. Whether removal will be animated
     or not is determined by the `removeAnimated` property.
     
     - Parameter gesture: The tap gesture recognizer object.
     */
    @objc fileprivate func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let parent = parentView else { return }
        
        removeActionHandler?()
        
        if removeAnimated {
            GTBlurView.removeAnimated(from: parent, duration: removeAnimationDuration ?? 0.4, completion: nil)
        } else {
            GTBlurView.remove(from: parent)
        }
    }
    
}

