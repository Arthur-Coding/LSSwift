//
//  LSTrigger.swift
//  Swift
//
//  Created by ArthurShuai on 2019/1/4.
//  Copyright © 2019 ArthurShuai. All rights reserved.
//

import Foundation

public extension LSSwift {
    
    public var trigger: LSTrigger<Object> {
        return LSTrigger(object)
    }
    
    static var trigger: LSTrigger<Object>.Type {
        return LSTrigger<Object>.self
    }
    
}

public struct LSTrigger<Trigger> {
    
    public let trigger: Trigger
    
    public init(_ trigger: Trigger)
    {
        self.trigger = trigger
    }
    
    private typealias VIMP = @convention(c) (AnyClass, Selector) -> Void
    private typealias Imp  = @convention(block) (AnyObject) -> Void
    
    public func trigger(for selector: Selector, do action: ((Any) -> Void)? = nil)
    {
        let method = class_getInstanceMethod(Trigger.self as? AnyClass, selector)

        let methodAction: Imp = { (_ target) in
            if action != nil {
                action!(target)
            }
        }
        
        let method_imp = imp_implementationWithBlock(unsafeBitCast(methodAction, to: AnyObject.self))
        method_setImplementation(method!, method_imp)
    }
    
}

