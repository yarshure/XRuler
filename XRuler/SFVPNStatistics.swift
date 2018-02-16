//
//  State.swift
//  XRuler
//
//  Created by yarshure on 2017/11/23.
//  Copyright © 2017年 yarshure. All rights reserved.
//

import Foundation

open class SFVPNStatistics:Codable {
    public static let shared = SFVPNStatistics()
    public var startDate = Date()
    public var sessionStartTime = Date()
    public var reportTime = Date()
    public var startTimes = 0
    public var show:Bool = false
    public var totalTraffice:SFTraffic = SFTraffic()
    public var currentTraffice:SFTraffic = SFTraffic()
    public var lastTraffice:SFTraffic = SFTraffic()
    public  var maxTraffice:SFTraffic = SFTraffic()
    
    public var wifiTraffice:SFTraffic = SFTraffic()
    public var cellTraffice:SFTraffic = SFTraffic()
    
    public var directTraffice:SFTraffic = SFTraffic()
    public var proxyTraffice:SFTraffic = SFTraffic()
    public var memoryUsed:UInt64 = 0
    public var finishedCount:Int = 0
    public var workingCount:Int = 0
    public var netflow:NetFlow = NetFlow()
    public required init(from decoder: Decoder) throws {
    }
    public func encode(to encoder: Encoder) throws
    {
        
    }
    public var runing:String {
        get {
            let now = Date()
            let second = Int(now.timeIntervalSince(sessionStartTime))
            return secondToString(second: second)
        }
    }
    public func updateMax() {
        if lastTraffice.tx > maxTraffice.tx{
            maxTraffice.tx = lastTraffice.tx
        }
        if lastTraffice.rx > maxTraffice.rx {
            maxTraffice.rx = lastTraffice.rx
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
    public func report(memory:UInt64,count:Int) ->Data{
        reportTime = Date()
        memoryUsed = memory
        
        do {
            return try JSONEncoder().encode(self)
        }catch let e {
            print("report error:" + e.localizedDescription)
            return Data()
        }
        
    }
    public func flowData(memory:UInt64) ->Data{
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
        lastTraffice.tx = currentTraffice.tx
        lastTraffice.rx = currentTraffice.rx
        var snapShot = SFTraffic()
        snapShot.tx = currentTraffice.tx
        snapShot.rx = currentTraffice.rx
        netflow.update(snapShot, type: .total)
        
        currentTraffice.tx = 0
        currentTraffice.rx = 0
        totalTraffice.addRx(x: Int(lastTraffice.rx))
        totalTraffice.addTx(x: Int(lastTraffice.tx))
        
        updateMax()
    }
    init() {
        
        installTimer()
    }
    fileprivate let reportTimer: DispatchSourceTimer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: 0), queue: DispatchQueue.main)
    public func startReporting(){
        XRuler.log("Starting reportTimer ..", level: .Info)
//        if reportTimer.isCancelled {
//            installTimer()
//        }
        reportTimer.resume()
    }
    func installTimer(){
        reportTimer.schedule(deadline: .now(), repeating: DispatchTimeInterval.seconds(1), leeway: DispatchTimeInterval.seconds(1))
        reportTimer.setEventHandler {
            [weak self] in
            
            self?.reportTask()
        }
        reportTimer.setCancelHandler {
            XRuler.log("cancel reportTimer ..", level: .Info)
        }
    }
    public func pauseReporting(){
        //reportTimer.
        reportTimer.suspend()
    }
    public func cancelReporting(){
        reportTimer.cancel()
    }
}
