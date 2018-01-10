//
//  State.swift
//  XRuler
//
//  Created by yarshure on 2017/11/23.
//  Copyright © 2017年 yarshure. All rights reserved.
//

import Foundation
import SwiftyJSON
open class SFVPNStatistics {
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
    public func map(j:JSON) {
        startDate = Date.init(timeIntervalSince1970: j["start"].doubleValue) as Date
        sessionStartTime = Date.init(timeIntervalSince1970: j["sessionStartTime"].doubleValue)
        reportTime = NSDate.init(timeIntervalSince1970: j["report_date"].doubleValue) as Date
        totalTraffice.mapObject(j: j["total"])
        lastTraffice.mapObject(j: j["last"])
        maxTraffice.mapObject(j: j["max"])
        
        cellTraffice.mapObject(j:j["cell"])
        wifiTraffice.mapObject(j: j["wifi"])
        directTraffice.mapObject(j: j["direct"])
        proxyTraffice.mapObject(j: j["proxy"])
        netflow.mapObject(j: j["netflow"])
        if let c  = j["memory"].uInt64 {
            memoryUsed = c
        }
        if let tcp = j["finishedCount"].int {
            finishedCount = tcp
        }
        if let tcp = j["workingCount"].int {
            workingCount = tcp
        }
        
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
        
        var status:[String:AnyObject] = [:]
        status["start"] =  NSNumber.init(value: startDate.timeIntervalSince1970)
        status["sessionStartTime"] =  NSNumber.init(value: sessionStartTime.timeIntervalSince1970)
        status["report_date"] =  NSNumber.init(value: reportTime.timeIntervalSince1970)
        //status["runing"] = NSNumber.init(double:runing)
        status["total"] = totalTraffice.resp() as AnyObject?
        status["last"] = lastTraffice.resp() as AnyObject?
        status["max"] = maxTraffice.resp() as AnyObject?
        status["memory"] = NSNumber.init(value: memoryUsed) //memoryUsed)
        
        
        status["finishedCount"] = NSNumber.init(value: finishedCount) //
        status["workingCount"] = NSNumber.init(value: count) //
        
        status["cell"] = cellTraffice.resp() as AnyObject?
        status["wifi"] = wifiTraffice.resp() as AnyObject?
        status["direct"] = directTraffice.resp() as AnyObject?
        status["proxy"] = proxyTraffice.resp() as AnyObject?
        status["netflow"] = netflow.resp() as AnyObject
        let j = JSON(status)
        
        
        
        
        //print("recentRequestData \(j)")
        var data:Data
        do {
            try data = j.rawData()
        }catch let error  {
            //AxLogger.log("ruleResultData error \(error.localizedDescription)")
            //let x = error.localizedDescription
            //let err = "report error"
            data =  error.localizedDescription.data(using: .utf8)!// NSData()
        }
        return data
    }
    public func flowData(memory:UInt64) ->Data{
        reportTime = Date()
        memoryUsed = memory
        
        var status:[String:AnyObject] = [:]
        
        status["netflow"] = netflow.resp() as AnyObject
        let j = JSON(status)
        
        var data:Data
        do {
            try data = j.rawData()
        }catch let error  {
            //AxLogger.log("ruleResultData error \(error.localizedDescription)")
            //let x = error.localizedDescription
            //let err = "report error"
            data =  error.localizedDescription.data(using: .utf8)!// NSData()
        }
        return data
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
        reportTimer =  DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: 0), queue: DispatchQueue.main)
        installTimer()
    }
    fileprivate let reportTimer: DispatchSourceTimer
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
