//
//  LSInit.swift
//  Swift
//
//  Created by ArthurShuai on 2018/12/20.
//  Copyright © 2018 ArthurShuai. All rights reserved.
//

import UIKit
import ObjectiveC.runtime

open class LSSwift : NSObject {
    
    // 重写init，防止误调取init
    private override init()
    {
        #if DEBUG
        print("Create LSSwift successfully!")
        #endif
    }
    
    public class func initialization() -> LSSwift
    {
        return swift
    }
    
    static private let swift = LSSwift()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
