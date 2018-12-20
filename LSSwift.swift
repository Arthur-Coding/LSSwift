//
//  LSSwift.swift
//  Swift
//
//  Created by ArthurShuai on 2018/12/20.
//  Copyright © 2018 ArthurShuai. All rights reserved.
//

import Foundation

public let lsswift = LSSwift.initialization()

// MARK: - 组件调用

/// 本地组件调用
///
/// - Parameters:
///   - objectClass: 组件类名
///   - actionName: 待执行方法名，组件的方法名前必须添加前缀@objc
///   - params: 待执行方法的参数
///   - perform: 找到组件后下一步调用处理，如push、present组件等
@available(iOS 8.0, macOS 10.11, tvOS 9.0, *)
public func lsswift_openModule(objectClass: String, actionName: String?, params: Any?, perform: LSSwiftModuleAction?)
{
    LSSwift.openModule(objectClass: objectClass, actionName: actionName, params: params, perform: perform)
}

/// 远程App调用本地组件
///
/// - Parameters:
///   - url: 格式：scheme://[target]/[actionName]?[params]
///          例如：app://targetA/actionB?id=1234&key=4567
///   - completion: 完成回调
@available(iOS 8.0, macOS 10.11, tvOS 9.0, *)
public func lsswift_performAction(url: URL, completion: LSSwiftModuleAction?)
{
    LSSwift.performAction(url: url, completion: completion)
}

/// 释放组件
///
/// - Parameter objectClass: 组件类名
/// - Returns: YES or NO
@discardableResult
@available(iOS 8.0, macOS 10.11, tvOS 9.0, *)
public func lsswift_releaseModule(objectClass: String) -> Bool
{
    return LSSwift.releaseModule(objectClass: objectClass)
}

/// 释放所有组件
@available(iOS 8.0, macOS 10.11, tvOS 9.0, *)
public func lsswift_releaseAllModule()
{
    LSSwift.releaseAllModules()
}

// MARK: - 组件间通讯

/// 组件发送通讯信息接口
/// * 发送方只负责通过通讯标记发送信息
///
/// - Parameters:
///   - information: 通讯信息
///   - tagName: 通讯标记，用于接收方识别接收信息
@available(iOS 8.0, macOS 10.11, tvOS 9.0, *)
public func lsswift_sendInformation(information: Any, tagName: String)
{
    LSSwift.sendInformation(information: information, tagName: tagName)
}

/// 组件接收通讯信息接口
/// * 接收方只负责通过通讯标记接收信息
///
/// - Parameters:
///   - tagName: 通讯标记，用于接收方识别接收信息
///   - result: 接收到通讯信息回调，将返回通讯信息
@available(iOS 8.0, macOS 10.11, tvOS 9.0, *)
public func lsswift_receiveInformation(tagName: String, result: LSSwiftInformationAction?)
{
    LSSwift.receiveInformation(tagName: tagName, result: result)
}

