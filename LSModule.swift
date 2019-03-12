//
//  LSModule.swift
//  Swift
//
//  Created by ArthurShuai on 2018/12/20.
//  Copyright © 2018 ArthurShuai. All rights reserved.
//

import Foundation
import UIKit

public extension LSSwift {
    
    public var module: LSModule<Object> {
        return LSModule(object)
    }
    
    static var module: LSModule<Object>.Type {
        return LSModule<Object>.self
    }
    
}

public struct LSModule<Moduler> {
    
    let moduler: Moduler

    /// 模块名
    var moduleName = "" {
        didSet {
            if !modules.keys.contains(moduleName) {
                if NSClassFromString(moduleName) != nil {
                    let object = (NSClassFromString(moduleName) as! NSObject.Type).init()
                    modules[moduleName] = object
                }
            }
        }
    }
    
    fileprivate init(_ moduler: Moduler)
    {
        self.moduler = moduler
    }
    
    public func configModule(for cls: AnyClass) -> LSModule
    {
        var lsmoudle = self
        lsmoudle.moduleName = NSStringFromClass(cls)
        return lsmoudle
    }
    
}

private var modules = [String: AnyObject]() {
    didSet {
        if moduleAction != nil {
            moduleAction!()
        }
    }
}

private var moduleAction: (()->Void)?

public extension LSModule where Moduler: AnyObject {
    
    /// 所有模块
    ///
    /// - Parameter next: 下一步处理
    func getModules(_ next: (([String: AnyObject])->Void)?)
    {
        moduleAction = {
            if next != nil {
                next!(modules)
            }
        }
    }
    
    /// 访问模块
    ///
    /// - Parameters:
    ///   - method: 打开方式
    @discardableResult
    public func open(by method: ((AnyObject)->Void)?) -> LSModule
    {
        if modules.keys.contains(moduleName) {
            let module = modules[moduleName]
            if method != nil {
               method!(module!)
            }
        }
        return self
    }
    
    /// 访问模块完成后模块执行操作
    ///
    /// - Parameters:
    ///   - method: 模块方法
    ///   - params: 模块方法参数
    public func completed(perform sel: Selector?, _ params: Any?)
    {
        if modules.keys.contains(moduleName) {
            let module = modules[moduleName]
            if sel != nil {
                if module!.responds(to: sel!) {
                    var result:Unmanaged<AnyObject>?
                    if params == nil {
                        result = module!.perform(sel!)
                    }else {
                        result = module!.perform(sel!, with: params!)
                    }
                    if result != nil {
                        #if DEBUG
                        print("Execute successfully!")
                        #endif
                    }
                }else {
                    release()
                    #if DEBUG
                    print("Undiscovered action!")
                    #endif
                }
            }
        }
    }

    /// 释放模块
    ///
    /// - Returns: true or false
    @discardableResult
    public func release() -> Bool
    {
        if modules.keys.contains(NSStringFromClass(Moduler.self)) {
            modules.removeValue(forKey: NSStringFromClass(Moduler.self))
            return true;
        }
        return false;
    }

    /// 释放所有模块
    public func clearUp()
    {
        modules.removeAll()
    }

}

public extension LSModule where Moduler: UIViewController {
    
    @discardableResult
    public func push() -> LSModule
    {
        return open { (_ module) in
            if module is UIViewController {
                let vc = module as! UIViewController
                vc.hidesBottomBarWhenPushed = true
                moduler.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @discardableResult
    public func present(_ presentationStyle: UIModalPresentationStyle? = nil, _ transitionStyle: UIModalTransitionStyle? = nil, _ completion: (()->Void)? = nil) -> LSModule
    {
        return open { (_ module) in
            if module is UIViewController  {
                let vc = module as! UIViewController
                if presentationStyle != nil {
                    vc.modalPresentationStyle = presentationStyle!
                }
                if transitionStyle != nil {
                    vc.modalTransitionStyle = transitionStyle!
                }
                moduler.present(vc, animated: true, completion: completion)
            }
        }
    }
    
}

public extension LSModule where Moduler: UIView {
    
    @discardableResult
    public func addSubView() -> LSModule
    {
        return open(by: { (_ module) in
            if module is UIView {
                let view = module as! UIView
                moduler.addSubview(view)
            }
        })
    }
    
}

public extension LSModule where Moduler: CALayer {
    
    @discardableResult
    public func addSubLayer() -> LSModule
    {
        return open(by: { (_ module) in
            if module is CALayer {
                let layer = module as! CALayer
                moduler.addSublayer(layer)
            }
        })
    }
    
}
