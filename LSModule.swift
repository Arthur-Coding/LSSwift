//
//  LSModule.swift
//  Swift
//
//  Created by ArthurShuai on 2018/12/20.
//  Copyright © 2018 ArthurShuai. All rights reserved.
//

import Foundation

public typealias LSSwiftModuleAction = (AnyObject)->Void

// MARK: - 本地组件调用

public extension LSSwift {
    
    static private let modulesKey = UnsafeRawPointer.init(bitPattern: "modules".hashValue)
    
    private var modules:Dictionary<String, Any> {
        set (newModules) {
            objc_setAssociatedObject(self, LSSwift.modulesKey!, newModules, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let routerModules = objc_getAssociatedObject(self, LSSwift.modulesKey!) as? Dictionary<String, Any> {
                return routerModules
            }
            return [:]
        }
    }
    
    /// 本地组件调用
    ///
    /// - Parameters:
    ///   - objectClass: 组件类名
    ///   - actionName: 待执行方法名，组件的方法名前必须添加前缀@objc
    ///   - params: 待执行方法的参数
    ///   - perform: 找到组件后下一步调用处理，如push、present组件等
    public class func openModule(objectClass: String, actionName: String?, params: Any?, perform: LSSwiftModuleAction?)
    {
        var object:AnyObject?
        
        if initialization().modules.keys.contains(objectClass) {
            object = initialization().modules[objectClass] as AnyObject
        }else {
            // 获取命名空间
            var clsName:String = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
            // 若命名空间包含"-"时，系统会自动替换为"_"，故需将"-"替换为"_"才能与系统验证时一致
            clsName = clsName.replacingOccurrences(of: "-", with: "_")
            if NSClassFromString(clsName+"."+objectClass) != nil {
                let module = NSClassFromString(clsName+"."+objectClass) as! NSObject.Type
                object = module.init()
                initialization().modules[objectClass] = object;
            }else {
                #if DEBUG
                print("Undiscovered component!")
                #endif
            }
        }
        
        if perform != nil {
            perform!(object!)
        }
        
        if actionName != nil {
            let action = Selector(actionName!)
            
            if  object!.responds(to: action) {
                let result:Unmanaged<AnyObject>! = object!.perform(action, with: params)
                if result != nil {
                    #if DEBUG
                    print("Execute successfully!")
                    #endif
                }
            }else {
                releaseModule(objectClass: objectClass)
                #if DEBUG
                print("Undiscovered action!")
                #endif
            }
        }
    }
    
    /// 释放组件
    ///
    /// - Parameter objectClass: 组件类名
    /// - Returns: YES or NO
    @discardableResult
    public class func releaseModule(objectClass: String) -> Bool
    {
        if initialization().modules.keys.contains(objectClass) {
            initialization().modules.removeValue(forKey: objectClass)
            return true;
        }
        return false;
    }
    
    /// 释放所有组件
    public class func releaseAllModules()
    {
        initialization().modules.removeAll()
    }
    
}

// MARK: - 组件远程调用

public extension LSSwift {
    
    /// 远程App调用本地组件
    ///
    /// - Parameters:
    ///   - url: 格式：scheme://[target]/[actionName]?[params]
    ///          例如：app://targetA/actionB?id=1234&key=4567
    ///   - completion: 完成回调
    public class func performAction(url: URL, completion: LSSwiftModuleAction?)
    {
        // 解析url中传递的参数
        var params:Dictionary<String, Any> = [:]
        for param in url.query!.components(separatedBy:"&") {
            let elts = param.components(separatedBy:"=")
            if elts.count >= 2 {
                params[elts.first!] = elts.last!
            }
        }
        
        // 考虑到安全性，防止黑客通过远程方式调用本地模块
        // 当前要求本地组件的actionName必须包含前缀"action_",所以远程调用的action就不能包含action_前缀
        let actionName = url.path.replacingOccurrences(of: "/", with: "")
        if actionName.hasPrefix("action_") {
            return;
        }
        
        // 如果需要拓展更复杂的url，可以在这个方法调用之前加入完整的路由逻辑
        openModule(objectClass: url.host!, actionName: "action_"+actionName, params: params, perform: completion)
    }
    
}
