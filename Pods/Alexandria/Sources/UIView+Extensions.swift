//
//  UIView+Extensions.swift
//
//  Created by Jonathan Landon on 4/15/15.
//
// The MIT License (MIT)
//
// Copyright (c) 2014-2016 Oven Bits, LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

extension UIView {
    
    /// UIView animation without the long variable names
    public class func animate(duration: NSTimeInterval,
                               _ delay: NSTimeInterval,
                             _ damping: CGFloat,
                            _ velocity: CGFloat,
                             _ options: UIViewAnimationOptions,
                          _ animations: () -> Void,
                          _ completion: ((Bool) -> Void)?)
    {
        UIView.animateWithDuration(duration,
            delay: delay,
            usingSpringWithDamping: damping,
            initialSpringVelocity: velocity,
            options: options,
            animations: animations,
            completion: completion
        )
    }
    
    /// UIView animation without the long variable names or completion block
    public class func animate(duration: NSTimeInterval,
                               _ delay: NSTimeInterval,
                             _ damping: CGFloat,
                            _ velocity: CGFloat,
                             _ options: UIViewAnimationOptions,
                          _ animations: () -> Void)
    {
        UIView.animateWithDuration(duration,
            delay: delay,
            usingSpringWithDamping: damping,
            initialSpringVelocity: velocity,
            options: options,
            animations: animations,
            completion: nil
        )
    }
    
    /**
    The frame size, not to be confused with the bounds size
    
    For more information on the difference between a view's bounds and frame, see:
    
    - http://www.andrewgertig.com/2013/08/ios-bounds-vs-frame
    - http://ashfurrow.com/blog/you-probably-dont-understand-frames-and-bounds/
    */
    public var size: CGSize {
        set {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
        get { return frame.size }
    }
    /**
    The frame height, not to be confused with the bounds height
    
    For more information on the difference between a view's bounds and frame, see:
    
    - http://www.andrewgertig.com/2013/08/ios-bounds-vs-frame
    - http://ashfurrow.com/blog/you-probably-dont-understand-frames-and-bounds/
    */
    public var height: CGFloat {
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
        get { return frame.height }
    }
    /**
    The frame width, not to be confused with the bounds width
    
    For more information on the difference between a view's bounds and frame, see:
    
    - http://www.andrewgertig.com/2013/08/ios-bounds-vs-frame
    - http://ashfurrow.com/blog/you-probably-dont-understand-frames-and-bounds/
    */
    public var width: CGFloat {
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
        get { return frame.width }
    }
    /**
    The frame origin, not to be confused with the bounds origin
    
    For more information on the difference between a view's bounds and frame, see:
    
    - http://www.andrewgertig.com/2013/08/ios-bounds-vs-frame
    - http://ashfurrow.com/blog/you-probably-dont-understand-frames-and-bounds/
    */
    public var origin: CGPoint {
        set {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
        get { return frame.origin }
    }
    /**
    The frame origin.x, not to be confused with the bounds origin.x
    
    For more information on the difference between a view's bounds and frame, see:
    
    - http://www.andrewgertig.com/2013/08/ios-bounds-vs-frame
    - http://ashfurrow.com/blog/you-probably-dont-understand-frames-and-bounds/
    */
    public var originX: CGFloat {
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
        get { return origin.x }
    }
    /**
    The frame origin.y, not to be confused with the bounds origin.y
    
    For more information on the difference between a view's bounds and frame, see:
    
    - http://www.andrewgertig.com/2013/08/ios-bounds-vs-frame
    - http://ashfurrow.com/blog/you-probably-dont-understand-frames-and-bounds/
    */
    public var originY: CGFloat {
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
        get { return origin.y }
    }
    /**
    The frame maxY, not to be confused with the bounds maxY
    
    For more information on the difference between a view's bounds and frame, see:
    
    - http://www.andrewgertig.com/2013/08/ios-bounds-vs-frame
    - http://ashfurrow.com/blog/you-probably-dont-understand-frames-and-bounds/
    */
    public var maxY: CGFloat {
        set { originY = newValue - height }
        get { return frame.maxY }
    }
    /**
    The frame maxX, not to be confused with the bounds maxX
    
    For more information on the difference between a view's bounds and frame, see:
    
    - http://www.andrewgertig.com/2013/08/ios-bounds-vs-frame
    - http://ashfurrow.com/blog/you-probably-dont-understand-frames-and-bounds/
    */
    public var maxX: CGFloat {
        set { originX = newValue - width }
        get { return frame.maxX }
    }
    /**
    The frame minY, not to be confused with the bounds minY
    
    For more information on the difference between a view's bounds and frame, see:
    
    - http://www.andrewgertig.com/2013/08/ios-bounds-vs-frame
    - http://ashfurrow.com/blog/you-probably-dont-understand-frames-and-bounds/
    */
    public var minY: CGFloat {
        set { originY = newValue }
        get { return frame.minY }
    }
    /**
    The frame minX, not to be confused with the bounds minX
    
    For more information on the difference between a view's bounds and frame, see:
    
    - http://www.andrewgertig.com/2013/08/ios-bounds-vs-frame
    - http://ashfurrow.com/blog/you-probably-dont-understand-frames-and-bounds/
    */
    public var minX: CGFloat {
        set { originX = newValue }
        get { return frame.minX }
    }
    /**
    The frame center.x, not to be confused with the bounds center.x
    
    For more information on the difference between a view's bounds and frame, see:
    
    - http://www.andrewgertig.com/2013/08/ios-bounds-vs-frame
    - http://ashfurrow.com/blog/you-probably-dont-understand-frames-and-bounds/
    */
    public var centerX: CGFloat {
        set {
            var center = self.center
            center.x = newValue
            self.center = center
        }
        get { return center.x }
    }
    /**
    The frame center.y, not to be confused with the bounds center.y
    
    For more information on the difference between a view's bounds and frame, see:
    
    - http://www.andrewgertig.com/2013/08/ios-bounds-vs-frame
    - http://ashfurrow.com/blog/you-probably-dont-understand-frames-and-bounds/
    */
    public var centerY: CGFloat {
        set {
            var center = self.center
            center.y = newValue
            self.center = center
        }
        get { return center.y }
    }
    /**
    The midpoint of the view's bounds
    
    Implementation:
    
    return CGPoint(x: bounds.width/2, y: bounds.height/2)
    */
    public var boundsCenter: CGPoint {
        return CGPoint(x: bounds.width/2, y: bounds.height/2)
    }
    
    /// Creates a UIImage representation of the view
    public func snapshotAsImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, opaque, 0)
        if let context = UIGraphicsGetCurrentContext() {
            layer.renderInContext(context)
        }
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img ?? UIImage()
    }
    
    /**
     Constrain the current view to another view.
     
     - parameter attribute: The layout attribute of self to constrain.
     - parameter relation: The layout relation of self (optional, defaults to .Equal).
     - parameter otherView: The other view to be constrained to.
     - parameter otherAttribute: The layout attribute for the other view.
     - parameter multiplier: The multiplier to use for the constraint (optional, defaults to 1).
     - parameter priority: The priority for the constraint (optional, defaults to `UILayoutPriorityRequired`).
     - parameter identifier: The identifier for the constraint (optional).
     
     - returns: The created constraint for self.
     */
    public func constrain(attribute: NSLayoutAttribute,
                         _ relation: NSLayoutRelation = .Equal,
                       to otherView: UIView,
                   _ otherAttribute: NSLayoutAttribute,
                   times multiplier: CGFloat = 1,
                      plus constant: CGFloat = 0,
                atPriority priority: UILayoutPriority = UILayoutPriorityRequired,
                         identifier: String? = nil) -> NSLayoutConstraint
    {
        translatesAutoresizingMaskIntoConstraints = false
                        
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: attribute,
            relatedBy: relation,
            toItem: otherView,
            attribute: otherAttribute,
            multiplier: multiplier,
            constant: constant
        )
        constraint.priority = priority
        constraint.identifier = identifier
        constraint.active = true
                        
        return constraint
    }
    
    /**
     Constrain the current view to a layout support such as `topLayoutGuide` or `bottomLayoutGuide`.
     
     - parameter attribute: The layout attribute of self to constrain.
     - parameter relation: The layout relation of self (optional, defaults to .Equal).
     - parameter support: The support to be constrained to.
     - parameter otherAttribute: The layout attribute for the support.
     - parameter multiplier: The multiplier to use for the constraint (optional, defaults to 1).
     - parameter priority: The priority for the constraint (optional, defaults to `UILayoutPriorityRequired`).
     - parameter identifier: The identifier for the constraint (optional).
     
     - returns: The created constraint for self.
     */
    public func constrain(attribute: NSLayoutAttribute,
                         _ relation: NSLayoutRelation = .Equal,
                  toSupport support: UILayoutSupport,
                   _ otherAttribute: NSLayoutAttribute,
                   times multiplier: CGFloat = 1,
                      plus constant: CGFloat = 0,
                atPriority priority: UILayoutPriority = UILayoutPriorityRequired,
                         identifier: String? = nil) -> NSLayoutConstraint
    {
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: attribute,
            relatedBy: relation,
            toItem: support,
            attribute: otherAttribute,
            multiplier: multiplier,
            constant: constant
        )
        constraint.priority = priority
        constraint.identifier = identifier
        constraint.active = true
        
        return constraint
    }
    
    /**
     Constrain an attribute of the current view.
     
     - parameter attribute: The layout attribute of self to constrain.
     - parameter relation: The layout relation of self (optional, defaults to .Equal).
     - parameter constant: The constant to use for the constraint (optional, defaults to 0).
     - parameter priority: The priority for the constraint (optional, defaults to `UILayoutPriorityRequired`).
     - parameter identifier: The identifier for the constraint (optional).
     
     - returns: The created constraint for self.
     */
    public func constrain(attribute: NSLayoutAttribute,
                         _ relation: NSLayoutRelation = .Equal,
                        to constant: CGFloat,
                   times multiplier: CGFloat = 1,
                atPriority priority: UILayoutPriority = UILayoutPriorityRequired,
                         identifier: String? = nil) -> NSLayoutConstraint
    {
        translatesAutoresizingMaskIntoConstraints = false
                        
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: attribute,
            relatedBy: relation,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: multiplier,
            constant: constant
        )
        constraint.priority = priority
        constraint.identifier = identifier
        constraint.active = true
        
        return constraint
    }
    
    /**
     Constrain the edges of self its superview, with optional insets.
     
     - parameter top: The top insets (optional, defaults to 0).
     - parameter leading: The leading insets (optional, defaults to 0).
     - parameter bottom: The bottom insets (optional, defaults to 0).
     - parameter trailing: The trailing insets (optional, defaults to 0).
     
     - returns: All four created constraints (top, leading, bottom, and trailing edges) for self.
     */
    public func constrainEdgesToSuperview(top top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0) -> (top: NSLayoutConstraint, leading: NSLayoutConstraint, bottom: NSLayoutConstraint, trailing: NSLayoutConstraint) {
        
        guard let superview = superview else { fatalError("Unable to add constraints, because the view has no superview") }
        
        let topConstraint    = constrain(.Top, to: superview, .Top, plus: top)
        let leadingConstraint   = constrain(.Leading, to: superview, .Leading, plus: leading)
        let bottomConstraint = constrain(.Bottom, to: superview, .Bottom, plus: -bottom)
        let trailingConstraint  = constrain(.Trailing, to: superview, .Trailing, plus: -trailing)
        
        return (topConstraint, leadingConstraint, bottomConstraint, trailingConstraint)
    }
    
    /**
     Constrain the width of the current view.
     
     - parameter value: The width value.
     - parameter relation: The layout relation of self (optional, defaults to .Equal).
     - parameter constant: The constant to use for the constraint (optional, defaults to 0).
     - parameter priority: The priority for the constraint (optional, defaults to `UILayoutPriorityRequired`).
     
     - returns: self
     */
    public func constrainWidth(to value: CGFloat,
                             _ relation: NSLayoutRelation = .Equal,
                       times multiplier: CGFloat = 1,
                    atPriority priority: UILayoutPriority = UILayoutPriorityRequired) -> Self
    {
        constrain(.Width, relation, to: value, times: multiplier, atPriority: priority)
        return self
    }
    
    /**
     Constrain the height of the current view.
     
     - parameter value: The height value.
     - parameter relation: The layout relation of self (optional, defaults to .Equal).
     - parameter constant: The constant to use for the constraint (optional, defaults to 0).
     - parameter priority: The priority for the constraint (optional, defaults to `UILayoutPriorityRequired`).
     
     - returns: self
     */
    public func constrainHeight(to value: CGFloat,
                              _ relation: NSLayoutRelation = .Equal,
                        times multiplier: CGFloat = 1,
                     atPriority priority: UILayoutPriority = UILayoutPriorityRequired) -> Self
    {
        constrain(.Height, relation, to: value, times: multiplier, atPriority: priority)
        return self
    }
    
    /**
     Constrain the width of the current view to another view.
     
     - parameter view: The view by which to constrain self
     - parameter attribute: The layout attribute of self to constrain (optional, defaults to .Width).
     - parameter relation: The layout relation of self (optional, defaults to .Equal).
     - parameter multiplier: The constraint multiplier (optional, defaults to 1).
     - parameter constant: The constant to use for the constraint (optional, defaults to 0).
     - parameter priority: The priority for the constraint (optional, defaults to `UILayoutPriorityRequired`).
     
     - returns: self
     */
    public func constrainWidth(to view: UIView,
                           _ attribute: NSLayoutAttribute = .Width,
                              relation: NSLayoutRelation = .Equal,
                      times multiplier: CGFloat = 1,
                         plus constant: CGFloat = 0,
                   atPriority priority: UILayoutPriority = UILayoutPriorityRequired) -> Self
    {
        constrain(.Width, relation, to: view, attribute, times: multiplier, plus: constant, atPriority: priority)
        return self
    }
    
    /**
     Constrain the height of the current view to another view.
     
     - parameter view: The view by which to constrain self
     - parameter attribute: The layout attribute of self to constrain (optional, defaults to .Height).
     - parameter relation: The layout relation of self (optional, defaults to .Equal).
     - parameter multiplier: The constraint multiplier (optional, defaults to 1).
     - parameter constant: The constant to use for the constraint (optional, defaults to 0).
     - parameter priority: The priority for the constraint (optional, defaults to `UILayoutPriorityRequired`).
     
     - returns: self
     */
    public func constrainHeight(to view: UIView,
                            _ attribute: NSLayoutAttribute = .Height,
                               relation: NSLayoutRelation = .Equal,
                       times multiplier: CGFloat = 1,
                          plus constant: CGFloat = 0,
                    atPriority priority: UILayoutPriority = UILayoutPriorityRequired) -> Self
    {
        constrain(.Height, relation, to: view, attribute, times: multiplier, plus: constant, atPriority: priority)
        return self
    }
    
    /**
     Constrain the left constraint of the current view.
     
     - parameter view: The view by which to constrain self.
     - parameter attribute: The layout attribute of self to constrain (optional, defaults to .Left).
     - parameter relation: The layout relation of self (optional, defaults to .Equal).
     - parameter multiplier: The constraint multiplier (optional, defaults to 1).
     - parameter constant: The constant to use for the constraint (optional, defaults to 0).
     - parameter priority: The priority for the constraint (optional, defaults to `UILayoutPriorityRequired`).
     
     - returns: self
     */
    public func pinLeft(to view: UIView,
                    _ attribute: NSLayoutAttribute = .Left,
                       relation: NSLayoutRelation = .Equal,
               times multiplier: CGFloat = 1,
                  plus constant: CGFloat = 0,
            atPriority priority: UILayoutPriority = UILayoutPriorityRequired) -> Self
    {
        constrain(.Left, relation, to: view, attribute, times: multiplier, plus: constant, atPriority: priority)
        return self
    }
    
    /**
     Constrain the right constraint of the current view.
     
     - parameter view: The view by which to constrain self.
     - parameter attribute: The layout attribute of self to constrain (optional, defaults to .Right).
     - parameter relation: The layout relation of self (optional, defaults to .Equal).
     - parameter multiplier: The constraint multiplier (optional, defaults to 1).
     - parameter constant: The constant to use for the constraint (optional, defaults to 0).
     - parameter priority: The priority for the constraint (optional, defaults to `UILayoutPriorityRequired`).
     
     - returns: self
     */
    public func pinRight(to view: UIView,
                     _ attribute: NSLayoutAttribute = .Right,
                        relation: NSLayoutRelation = .Equal,
                times multiplier: CGFloat = 1,
                   plus constant: CGFloat = 0,
             atPriority priority: UILayoutPriority = UILayoutPriorityRequired) -> Self
    {
        constrain(.Right, relation, to: view, attribute, times: multiplier, plus: constant, atPriority: priority)
        return self
    }
    
    /**
     Constrain the top constraint of the current view.
     
     - parameter view: The view by which to constrain self.
     - parameter attribute: The layout attribute of self to constrain (optional, defaults to .Top).
     - parameter relation: The layout relation of self (optional, defaults to .Equal).
     - parameter multiplier: The constraint multiplier (optional, defaults to 1).
     - parameter constant: The constant to use for the constraint (optional, defaults to 0).
     - parameter priority: The priority for the constraint (optional, defaults to `UILayoutPriorityRequired`).
     
     - returns: self
     */
    public func pinTop(to view: UIView,
                   _ attribute: NSLayoutAttribute = .Top,
                      relation: NSLayoutRelation = .Equal,
              times multiplier: CGFloat = 1,
                 plus constant: CGFloat = 0,
           atPriority priority: UILayoutPriority = UILayoutPriorityRequired) -> Self
    {
        constrain(.Top, relation, to: view, attribute, times: multiplier, plus: constant, atPriority: priority)
        return self
    }
    
    /**
     Constrain the bottom constraint of the current view.
     
     - parameter view: The view by which to constrain self.
     - parameter attribute: The layout attribute of self to constrain (optional, defaults to .Bottom).
     - parameter relation: The layout relation of self (optional, defaults to .Equal).
     - parameter multiplier: The constraint multiplier (optional, defaults to 1).
     - parameter constant: The constant to use for the constraint (optional, defaults to 0).
     - parameter priority: The priority for the constraint (optional, defaults to `UILayoutPriorityRequired`).
     
     - returns: self
     */
    public func pinBottom(to view: UIView,
                      _ attribute: NSLayoutAttribute = .Bottom,
                         relation: NSLayoutRelation = .Equal,
                 times multiplier: CGFloat = 1,
                    plus constant: CGFloat = 0,
              atPriority priority: UILayoutPriority = UILayoutPriorityRequired) -> Self
    {
        constrain(.Bottom, relation, to: view, attribute, times: multiplier, plus: constant, atPriority: priority)
        return self
    }
    
    /**
     Constrain the leading constraint of the current view.
     
     - parameter view: The view by which to constrain self.
     - parameter attribute: The layout attribute of self to constrain (optional, defaults to .Leading).
     - parameter relation: The layout relation of self (optional, defaults to .Equal).
     - parameter multiplier: The constraint multiplier (optional, defaults to 1).
     - parameter constant: The constant to use for the constraint (optional, defaults to 0).
     - parameter priority: The priority for the constraint (optional, defaults to `UILayoutPriorityRequired`).
     
     - returns: self
     */
    public func pinLeading(to view: UIView,
                       _ attribute: NSLayoutAttribute = .Leading,
                          relation: NSLayoutRelation = .Equal,
                  times multiplier: CGFloat = 1,
                     plus constant: CGFloat = 0,
               atPriority priority: UILayoutPriority = UILayoutPriorityRequired) -> Self
    {
        constrain(.Leading, relation, to: view, attribute, times: multiplier, plus: constant, atPriority: priority)
        return self
    }
    
    /**
     Constrain the trailing constraint of the current view.
     
     - parameter view: The view by which to constrain self.
     - parameter attribute: The layout attribute of self to constrain (optional, defaults to .Trailing).
     - parameter relation: The layout relation of self (optional, defaults to .Equal).
     - parameter multiplier: The constraint multiplier (optional, defaults to 1).
     - parameter constant: The constant to use for the constraint (optional, defaults to 0).
     - parameter priority: The priority for the constraint (optional, defaults to `UILayoutPriorityRequired`).
     
     - returns: self
     */
    public func pinTrailing(to view: UIView,
                        _ attribute: NSLayoutAttribute = .Trailing,
                           relation: NSLayoutRelation = .Equal,
                   times multiplier: CGFloat = 1,
                      plus constant: CGFloat = 0,
                atPriority priority: UILayoutPriority = UILayoutPriorityRequired) -> Self
    {
        constrain(.Trailing, relation, to: view, attribute, times: multiplier, plus: constant, atPriority: priority)
        return self
    }
    
    /**
     Constrain the center X constraint of the current view.
     
     - parameter view: The view by which to constrain self.
     - parameter attribute: The layout attribute of self to constrain (optional, defaults to .CenterX).
     - parameter relation: The layout relation of self (optional, defaults to .Equal).
     - parameter multiplier: The constraint multiplier (optional, defaults to 1).
     - parameter constant: The constant to use for the constraint (optional, defaults to 0).
     - parameter priority: The priority for the constraint (optional, defaults to `UILayoutPriorityRequired`).
     
     - returns: self
     */
    public func pinCenterX(to view: UIView,
                       _ attribute: NSLayoutAttribute = .CenterX,
                          relation: NSLayoutRelation = .Equal,
                  times multiplier: CGFloat = 1,
                     plus constant: CGFloat = 0,
               atPriority priority: UILayoutPriority = UILayoutPriorityRequired) -> Self
    {
        constrain(.CenterX, relation, to: view, attribute, times: multiplier, plus: constant, atPriority: priority)
        return self
    }
    
    /**
     Constrain the center Y constraint of the current view.
     
     - parameter view: The view by which to constrain self.
     - parameter attribute: The layout attribute of self to constrain (optional, defaults to .CenterY).
     - parameter relation: The layout relation of self (optional, defaults to .Equal).
     - parameter multiplier: The constraint multiplier (optional, defaults to 1).
     - parameter constant: The constant to use for the constraint (optional, defaults to 0).
     - parameter priority: The priority for the constraint (optional, defaults to `UILayoutPriorityRequired`).
     
     - returns: self
     */
    public func pinCenterY(to view: UIView,
                       _ attribute: NSLayoutAttribute = .CenterY,
                          relation: NSLayoutRelation = .Equal,
                  times multiplier: CGFloat = 1,
                     plus constant: CGFloat = 0,
               atPriority priority: UILayoutPriority = UILayoutPriorityRequired) -> Self
    {
        constrain(.CenterY, relation, to: view, attribute, times: multiplier, plus: constant, atPriority: priority)
        return self
    }
    
    /**
     Constrain self to fit its content for the specified layout constraint axes.
     
     - parameter axes: The axes on which to constrain self (variadic).
     - parameter priority: The layout priority for content hugging and compression (optional, defaults to `UILayoutPriorityRequired`)
     */
    public func constrainSizeToFit(axes: UILayoutConstraintAxis..., priority: UILayoutPriority = UILayoutPriorityRequired) {
        axes.forEach {
            setContentHuggingPriority(priority, forAxis: $0)
            setContentCompressionResistancePriority(priority, forAxis: $0)
        }
    }
    
    /**
     Add self to a superview.
     
     - parameter superview: The superview in which to add self.
     */
    @available(*, deprecated=1.2.0, message="use 'add(toSuperview:)'")
    public func addToSuperview(superview: UIView) -> Self {
        superview.addSubview(self)
        return self
    }
    
    /**
     Add self to a superview.
     
     - parameter toSuperview: The superview in which to add self.
     */
    @nonobjc
    public func add(toSuperview superview: UIView) -> Self {
        superview.addSubview(self)
        return self
    }
    
    /**
     Add self as an arranged subview of a UIStackView.
     
     - parameter toStackview: The stackview in which to add self as an arranged subview.
     */
    @available(iOS 9.0, *)
    public func add(toStackview stackview: UIStackView) -> Self {
        stackview.addArrangedSubview(self)
        return self
    }
    
    /**
     Returns a UIView object that has been added as a subview to the given superview.
     
     - parameter superview: The view in which to add self as a subview.
     
     - returns: A UIView initialized and added as a subview to the given superview.
     */
    public convenience init(superview: UIView) {
        self.init()
        superview.addSubview(self)
    }
}


extension UIView {

/*
    View snapshotting. 
    
    Comes from: Richard Turton http://commandshift.co.uk/blog/2016/03/13/better-snapshots/
    
    In case Richard's page ever goes away:

        In my talk at RWDevCon 2016 I described a way to handle custom view controller transitions in 
        a way that didn’t lead to messing up your view controllers and leaving yourself with a lot of 
        horrible cleanup code.
    
        The secret to painless custom transitions is to do a lot of snapshots. In the talk I mentioned 
        some utility methods for making snapshots, but there wasn’t time in the session to cover the 
        details. Instead, I’ve written about them here.
    
        A sensible view controller transition doesn’t move, fade or otherwise manipulate any of the 
        view controller’s views. That way lies madness. The correct way to handle them is:
    
            * Create a canvas view, which fills the container view of the transition context
            * Snapshot everything you’re interested in moving
            * Move the snapshots around, then animate them to their final positions
            * Remove the canvas when you’re done
    
        This has numerous advantages:
    
            * No cleanup code or resetting of view properties
            * You can take advantage of autolayout in your view controllers, but move the snapshots 
              around by animating the center property, which makes much more sense when doing transitions 
              and means you don’t need outlets to all your constraints
            * Keeps the view controller very loosely coupled to the transition
    
        Making a snapshot from a UIView is simple and fast:
    
            `let snapshot = view.snapshotViewAfterScreenUpdates(false)`

        The resulting view has the same bounds as the original, but has a frame origin at zero, which is usually useless.
    
        For transitions, what is usually required is for the snapshot to be added to the canvas view, at the 
        same position on the screen. This is done with an extension on UIView:
    
            > see `addSnapshotOfView(_:afterUpdates:)` below
    
        You call the function like this:
    
            `let snapshot = canvas.addSnapshotOfView(view, afterUpdates: false)`
    
        For an array of views, another method in the extension:
        
            > see `addSnapshotOfView(_:afterUpdates:)` below
    
        Snapshotting is so common and so useful when doing transitions, and these extension methods make 
        your transition code much more readable and obvious.
    

    Thank you, Richard!
*/
    
    
    /**
    Take a snapshot of the given view, adding it to `self` which is treated as the canvas-view. Will place the
    snapshot view within self (canvas view) at the snapshotted view's same position on screen.
    
    `let snapshot = canvas.addSnapshotOfView(view, afterUpdates: false)`
    
    - parameter view:         The view to snapshot
    - parameter afterUpdates: A Boolean value (default: false) that specifies whether the snapshot should be taken after recent changes have been incorporated. Pass the value false to capture the screen in its current state, which might not include recent changes.
    
    - returns: The snapshotted view (already added to the caller).
    
    - author: Richard Turton http://commandshift.co.uk/blog/2016/03/13/better-snapshots/
    */
    public func addSnapshotOfView(view: UIView, afterUpdates: Bool = false) -> UIView? {
        guard let snapshot = view.snapshotViewAfterScreenUpdates(afterUpdates) else { return nil }
        self.addSubview(snapshot)
        snapshot.frame = convertRect(view.bounds, fromView: view)
        return snapshot
    }
    
    
    /**
     Convenience for calling `addSnapshotOfView(_:afterUpdates:)` over an array of views.
     
     - parameter views:        The views to snapshot.
     - parameter afterUpdates: A Boolean value (default: false) that specifies whether the snapshot should be taken after recent changes have been incorporated. Pass the value false to capture the screen in its current state, which might not include recent changes.
     
     - returns: The snapshotted views.
     
     - author: Richard Turton http://commandshift.co.uk/blog/2016/03/13/better-snapshots/
     */
    public func addSnapshotOfViews(views: [UIView], afterUpdates: Bool = false) -> [UIView] {
        return views.flatMap { addSnapshotOfView($0, afterUpdates: afterUpdates) }
    }


}


