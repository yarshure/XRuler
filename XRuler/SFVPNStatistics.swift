//
//  State.swift
//  XRuler
//
//  Created by yarshure on 2017/11/23.
//  Copyright © 2017年 yarshure. All rights reserved.
//

import Foundation

public final class SFStatistics:Codable {
   
    public var startDate:Date = Date()
    public var sessionStartTime:Date = Date()
    public var reportTime:Date = Date()
    public var startTimes:Int = 0
    public var show:Bool = false
    public var total:SFTraffic = SFTraffic()
    public var current:SFTraffic = SFTraffic()
    public var last:SFTraffic = SFTraffic()
    public  var max:SFTraffic = SFTraffic()
    
    public var wifi:SFTraffic = SFTraffic()
    public var cell:SFTraffic = SFTraffic()
    
    public var direct:SFTraffic = SFTraffic()
    public var proxy:SFTraffic = SFTraffic()
    public var memoryUsed:UInt64 = 0
    public var finishedCount:Int = 0
    public var workingCount:Int = 0
    public var netflow:NetFlow = NetFlow()
    enum CodingKeys: String, CodingKey {
        case startDate = "startDate"
        case sessionStartTime = "sessionStartTime"
        case reportTime = "reportTime"
        case startTimes =  "startTimes"
        
        
        case show = "show"  //http socks5 user
        case total   = "total"
        case current   = "current"
        case last  = "last"
        case max  = "max"
        case wifi =   "wifi"
        case cell =     "cell"
        case direct =     "direct"
        case proxy =      "proxy"
        case memoryUsed  = "memoryUsed"
        case finishedCount  = "finishedCount"
        case workingCount  = "workingCount"
        case netflow  = "netflow"
       
        
    }
    public var runing:String {
        get {
            let now = Date()
            let second = Int(now.timeIntervalSince(sessionStartTime))
            return secondToString(second: second)
        }
    }
    public func updateMax() {
        if last.tx > max.tx{
            max.tx = last.tx
        }
        if last.rx > max.rx {
            max.rx = last.rx
        }
    }
    public func secondToString(second:Int) ->String {
        
        let sec = second % 60
        let min = second % (60*60) / 60
        let hour = second / (60*60)
        
        return String.init(format: "%02d:%02d:%02d", hour,min,sec)
        
        
    }
  
    public func memoryString() ->String {
        let f = Float(memoryUsed)
        if memoryUsed < 1024 {
            return "\(memoryUsed) Bytes"
        }else if memoryUsed >=  1024 &&  memoryUsed <  1024*1024 {
            
            return  String(format: "%.2f KB", f/1024.0)
        }
        return String(format: "%.2f MB", f/1024.0/1024.0)
        
    }
   
    func flowData(memory:UInt64) ->Data{
        reportTime = Date()
        memoryUsed = memory
        
     
        do {
            return try JSONEncoder().encode(netflow)
        }catch let e  {
            print(e.localizedDescription)
            return Data()
        }
        
    }
    //shoud every second update
    public func reportTask() {
        //let report = SFVPNStatistics.shared
        last.tx = current.tx
        last.rx = current.rx
        var snapShot = SFTraffic()
        snapShot.tx = current.tx
        snapShot.rx = current.rx
        netflow.update(snapShot, type: .total)
        
        current.tx = 0
        current.rx = 0
        total.addRx(x: Int(last.rx))
        total.addTx(x: Int(last.tx))
        
        updateMax()
    }

}
