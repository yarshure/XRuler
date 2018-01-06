//
//  Flow.swift
//  XProxy
//
//  Created by yarshure on 2017/11/23.
//  Copyright © 2017年 yarshure. All rights reserved.
//

import Foundation
import SwiftyJSON
public struct SFTraffic {
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
    public mutating func mapObject(j:JSON)  {
        rx = UInt(j["rx"].int64Value)
        tx = UInt(j["tx"].int64Value)
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
public final class NetFlow{
    //public static let shared = NetFlow()
    public var totalFlows:[SFTraffic] = []
    public let currentFlows:[SFTraffic] = []
    public let lastFlows:[SFTraffic] = []
    public let maxFlows:[SFTraffic] = []
    
    public var wifiFlows:[SFTraffic] = []
    public var cellFlows:[SFTraffic] = []
    
    public var directFlows:[SFTraffic] = []
    public var proxyFlows:[SFTraffic] = []
    public func update(_ flow:SFTraffic, type:FlowType){
        //        var tmp:[SFTraffic]
        //        switch type {
        //        case .total:
        //           tmp = totalFlows
        //        case .current :
        //           tmp = currentFlows
        //        case .last :
        //           tmp = lastFlows
        //        case .max:
        //           tmp = maxFlows
        //        case .wifi:
        //           tmp = wifiFlows
        //        case .cell:
        //           tmp = cellFlows
        //        case .direct:
        //            tmp = directFlows
        //        case .proxy:
        //            tmp = proxyFlows
        //        }
        totalFlows.append(flow)
        if totalFlows.count > 60 {
            totalFlows.remove(at: 0)
        }
    }
    public func resp() -> [String : AnyObject] {
        var result:[String:AnyObject] = [:]
        var x:[AnyObject] = []
        for xx in totalFlows{
            x.append(xx.resp() as AnyObject)
        }
        result["total"] = x as AnyObject
        return result
    }
    public func mapObject(j: SwiftyJSON.JSON){
        totalFlows.removeAll(keepingCapacity: true)
        for xx in j["total"].arrayValue {
            var x = SFTraffic()
            x.mapObject(j: xx)
            totalFlows.append(x)
        }
    }
    public func flow(_ type:FlowType) ->[Double]{
        var r:[Double] = []
        for x in totalFlows {
            r.append(Double(x.rx))
        }
        return r
    }
}
