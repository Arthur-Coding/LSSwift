//
//  LSRuntime.swift
//  Swift
//
//  Created by ArthurShuai on 2019/1/3.
//  Copyright © 2019 ArthurShuai. All rights reserved.
//

import Foundation
import ObjectiveC.runtime

extension NSObject: LSRuntimeProvider {}

public protocol LSRuntimeProvider {}

public extension LSRuntimeProvider {
    
    public var lsruntime: LSRuntime<Self> {
        return LSRuntime(self)
    }
    
    static var lsruntime: LSRuntime<Self>.Type {
        return LSRuntime<Self>.self
    }
    
}

public struct LSRuntime<Object> {
    
    public let object: Object
    
    fileprivate init(_ object: Object)
    {
        self.object = object
    }
    
    public func setValue(object: Any, key: UnsafeRawPointer, value: Any?)
    {
        objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    public func getValue(object: Any, key: UnsafeRawPointer) -> Any?
    {
        return objc_getAssociatedObject(object, key)
    }
    
}


