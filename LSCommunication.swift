//
//  LSCommunication.swift
//  Swift
//
//  Created by ArthurShuai on 2018/12/20.
//  Copyright © 2018 ArthurShuai. All rights reserved.
//

import Foundation

public typealias LSSwiftInformationAction = (Any)->Void

public extension LSSwift {
    
    static let receiveActionsKey = UnsafeRawPointer.init(bitPattern: "receiveActions".hashValue)
    
    private var receiveActions:Dictionary<String, Any> {
        set (actions) {
            objc_setAssociatedObject(self, LSSwift.receiveActionsKey!, actions, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let routerReceiveActions = objc_getAssociatedObject(self, LSSwift.receiveActionsKey!) as? Dictionary<String, Any> {
                return routerReceiveActions
            }
            return [String: Any]()
        }
    }
    
    /// 组件发送通讯信息接口
    /// * 发送方只负责通过通讯标记发送信息
    ///
    /// - Parameters:
    ///   - information: 通讯信息
    ///   - tagName: 通讯标记，用于接收方识别接收信息
    public class func sendInformation(information: Any, tagName: String)
    {
        NotificationCenter.default.post(name: NSNotification.Name.init(tagName), object: nil, userInfo:  ["info": information])
    }
    
    /// 组件接收通讯信息接口
    /// * 接收方只负责通过通讯标记接收信息
    ///
    /// - Parameters:
    ///   - tagName: 通讯标记，用于接收方识别接收信息
    ///   - result: 接收到通讯信息回调，将返回通讯信息
    public class func receiveInformation(tagName: String, result: LSSwiftInformationAction?)
    {
        NotificationCenter.default.addObserver(initialization(), selector: #selector(receivedInformation(noti:)), name: NSNotification.Name.init(tagName), object: nil)
        if result != nil {
            initialization().receiveActions[tagName] = result!;
        }
    }
    
    @objc private func receivedInformation(noti:NSNotification)
    {
        let tagName = noti.name.rawValue
        let infotmation = noti.userInfo!["info"]
        
        guard infotmation == nil else {
            if let receiveAction = LSSwift.initialization().receiveActions[tagName] as? LSSwiftInformationAction {
                receiveAction(infotmation!)
            }
            return
        }
    }
    
}
