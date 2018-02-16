//
//  Flow.swift
//  XProxy
//
//  Created by yarshure on 2017/11/23.
//  Copyright © 2017年 yarshure. All rights reserved.
//

import Foundation

public struct SFTraffic:Codable {
    public var rx: UInt = 0
    public var tx: UInt = 0
    public init(){
        
    }
    public mutating func addRx(x:Int){
        rx += UInt(x)
    }
    public mutating func addTx(x:Int){
        tx += UInt(x)
    }
    //new api
    public mutating func addFlow(x:Int,RX:Bool){
        if RX {
             rx += UInt(x)
        }else {
            tx += UInt(x)
        }
    }
    public mutating func reset() {
        rx = 0
        tx = 0
    }
    public func txString() ->String{
        return toString(x: tx,label: "TX:",speed: false)
    }
    public func rxString() ->String {
        return toString(x: rx,label:"RX:",speed: false)
    }
    public func toString(x:UInt,label:String,speed:Bool) ->String {
        
        var s = "/s"
        if !speed {
            s = ""
        }
        #if os(macOS)
            if x < 1024{
                return label + " \(x) B" + s
            }else if x >= 1024 && x < 1024*1024 {
                return label +  String(format: "%d KB", Int(Float(x)/1024.0))  + s
            }else if x >= 1024*1024 && x < 1024*1024*1024 {
                //return label + "\(x/1024/1024) MB" + s
                return label +  String(format: "%d MB", Int(Float(x)/1024/1024))  + s
            }else {
                //return label + "\(x/1024/1024/1024) GB" + s
                return label +  String(format: "%d GB", Int(Float(x)/1024/1024/1024))  + s
            }
        #else
            if x < 1024{
                return label + " \(x) B" + s
            }else if x >= 1024 && x < 1024*1024 {
                return label +  String(format: "%.2f KB", Float(x)/1024.0)  + s
            }else if x >= 1024*1024 && x < 1024*1024*1024 {
                //return label + "\(x/1024/1024) MB" + s
                return label +  String(format: "%.2f MB", Float(x)/1024/1024)  + s
            }else {
                //return label + "\(x/1024/1024/1024) GB" + s
                return label +  String(format: "%.2f GB", Float(x)/1024/1024/1024)  + s
            }
        #endif
    }
    public func report() ->String{
        return "\(toString(x: tx, label: "TX:",speed: true)) \(toString(x: rx, label: "RX:",speed: true))"
    }
    public func reportTraffic() ->String{
        return "\(toString(x: tx, label: "TX:",speed: false)) \(toString(x: rx, label: "RX:",speed: false))"
    }
    public func resp ()-> [String:NSNumber] {
        return ["rx":NSNumber.init(value: rx) ,"tx":NSNumber.init(value: tx)]
    }
  
}

public enum FlowType:Int {
    case total = 1
    case current = 2
    case last = 3
    case max = 4
    case wifi = 5
    case cell = 6
    case direct = 7
    case proxy = 8
}
public final class NetFlow:Codable{
    //public static let shared = NetFlow()
    public var total:[SFTraffic] = []
    public var current:[SFTraffic] = []
    public var last:[SFTraffic] = []
    public var max:[SFTraffic] = []
    
    public var wifi:[SFTraffic] = []
    public var cell:[SFTraffic] = []
    
    public var direct:[SFTraffic] = []
    public var proxy:[SFTraffic] = []
    //只保存最近60次采样
   
    public func update(_ flow:SFTraffic, type:FlowType){
        var tmp:[SFTraffic]
        switch type {
        case .total:
            tmp = total
        case .current :
            tmp = current
        case .last :
            tmp = last
        case .max:
            tmp = max
        case .wifi:
            tmp = wifi
        case .cell:
            tmp = cell
        case .direct:
            tmp = direct
        case .proxy:
            tmp = proxy
        }
        
        tmp.append(flow)
        if tmp.count > 60 {
            tmp.remove(at: 0)
        }
        //value type write back
        //totalFlows = tmp
        switch type {
        case .total:
            total  = tmp
        case .current :
            current = tmp
        case .last :
             last = tmp
        case .max:
            max = tmp
        case .wifi:
              wifi = tmp
        case .cell:
             cell = tmp
        case .direct:
              direct = tmp
        case .proxy:
             proxy = tmp
        }
        
    }
   
    public func flow(_ type:FlowType) ->[Double]{
        var r:[Double] = []
        for x in total {
            r.append(Double(x.rx))
        }
        return r
    }
}
