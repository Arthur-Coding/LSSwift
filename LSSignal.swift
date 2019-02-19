//
//  LSSignal.swift
//  Swift
//
//  Created by ArthurShuai on 2019/1/11.
//  Copyright © 2019 ArthurShuai. All rights reserved.
//

import Foundation

public extension LSSwift {
    
    public var signal: LSSignal<Object> {
        return LSSignal(object)
    }
    
    static var signal: LSSignal<Object>.Type {
        return LSSignal<Object>.self
    }
    
}

public struct LSSignal<Signaler> {
    
    let signaler: Signaler
    
    /// 信号标识
    var signalTag = "" {
        didSet {
            let signal = signals.keys.contains(signalTag) ? signals[signalTag] : LSSignalProvider.init()
            signals[signalTag] = signal
        }
    }
    
    fileprivate init(_ signaler: Signaler)
    {
        self.signaler = signaler
    }
    
    public func configSignal(for tag: String) -> LSSignal
    {
        var lssignal = self
        lssignal.signalTag = tag
        return lssignal
    }
    
}

public struct LSSignalProvider {
    
    public var sender: Sender? // 发送者
    public var receivers: [Receiver]? // 接受者
    
    init(_ sender: Sender? = nil, _ receivers: [Receiver]? = nil) {
        self.sender = sender
        self.receivers = receivers
    }
    
    public struct Sender {
        
        var target: AnyObject // 信号对象
        var information: Any? // 信号信息
        
    }
    
    public struct Receiver {
        
        var target: AnyObject // 信号对象
        var action: ((LSSignalProvider, Any?) -> Void)?
        
    }
    
}

private var signals = [String: LSSignalProvider]() {
    didSet {
        if signalAction != nil {
            signalAction!()
        }
    }
}

private var signalAction: (()->Void)?

extension LSSignal where Signaler: AnyObject {
    
    /// 信号
    ///
    /// - Parameter next: 下一步处理
    func getSignals(_ next: (([String: LSSignalProvider])->Void)?)
    {
        signalAction = {
            if next != nil {
                next!(signals)
            }
        }
    }

    /// 发送信号
    ///
    /// - Parameter information: 信息
    public func send(_ information: Any? = nil)
    {
        if !signals.keys.contains(signalTag) {
            #if DEBUG
            print("Undiscovered signal!")
            #endif
            return
        }
        
        let sender = LSSignalProvider.Sender.init(target: signaler, information: nil)
        var signal = signals[signalTag]
        signal?.sender = sender
        signals[signalTag] = signal
        
        for (_, var signalValue) in signals {
            if signalValue.sender != nil && signalValue.sender!.target.isEqual(signaler) {
                var sender = signalValue.sender!
                sender.information = information
                signalValue.sender = sender
                
                if let receivers = signalValue.receivers {
                    for receiver in receivers {
                        if let action = receiver.action {
                            action(signalValue, information)
                        }
                    }
                }
                
                break
            }
        }
    }
    
    /// 绑定信息
    ///
    /// - Parameters:
    ///   - next: 绑定接收信息处理
    public func binding(_ next: ((LSSignalProvider, Any?) -> Void)?)
    {
        if !signals.keys.contains(signalTag) {
            return
        }
        
        var signal = signals[signalTag]
        var receivers = signal?.receivers ?? [LSSignalProvider.Receiver]()
        if receivers.count == 0 {
            receivers.append(LSSignalProvider.Receiver.init(target: signaler, action: next))
        }else {
            for (idx, receiver) in receivers.enumerated() {
                if idx == receivers.count - 1 && !receiver.target.isEqual(Signaler.self) {
                    receivers.append(LSSignalProvider.Receiver.init(target: signaler, action: next))
                    break
                }
            }
        }
        signal?.receivers = receivers
        signals[signalTag] = signal
    }
    
}
