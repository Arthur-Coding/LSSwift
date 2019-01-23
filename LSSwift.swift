//
//  LSSwift.swift
//  Swift
//
//  Created by ArthurShuai on 2018/12/20.
//  Copyright © 2018 ArthurShuai. All rights reserved.
//

import Foundation

extension NSObject: LSSwiftProvider {}

public protocol LSSwiftProvider {}

public extension LSSwiftProvider {
    
    public var lsswift: LSSwift<Self> {
        return LSSwift(self)
    }
    
    static var lsswift: LSSwift<Self>.Type {
        return LSSwift<Self>.self
    }
    
}

public struct LSSwift<Object> {
    
    public var object: Object
    
    fileprivate init(_ object: Object)
    {
        self.object = object
    }
    
}
