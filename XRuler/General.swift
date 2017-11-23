//
//  File.swift
//  Surf
//
//  Created by yarshure on 15/12/23.
//  Copyright © 2015年 yarshure. All rights reserved.
//

import Foundation
import AxLogger
public class General {
    public var author = "yarshure"
    public var loglevel = "info"
    public var commnet = "fuck gfw and gcd"
    public var lastUpdate = Date()
    public var url = ""
    public var bypasstun:[String] = []
    public var skipproxy:[String] = []
    public var bypasssystem:Bool = false
    public var dnsserver:[String] = []
    public var cellSuspend:Bool = false //Project-FI 可以不用翻墙
    //var config:JSON
    public init (name:String) {
        
    }
    public var  axloglevel: AxLoggerLevel {
        
        var level:AxLoggerLevel = .Info
        let l = loglevel.lowercased()
        
        switch l {
        case "error": level = .Error
        case "warning": level = .Warning
        case "info": level = .Info
        case "notify": level = .Notify
        case "trace": level = .Trace
        case "verbose": level = .Verbose
        case "debug": level = .Debug
        default:
            break
        }
        return level
    }
    public init (c:String) {
        //config = c
        // 空格啊
//        let bypass = c["bypass-tun"]
//        if bypass.error == nil {
//            if bypass.type == .Array {
//                for item in bypass {
//                    skipproxy.append(item.1.stringValue)
//                }
//            }
//        }
//        if c["dns-server"].error == nil {
//            for (_,v) in c["dns-server"] {
//                dnsserver.append(v.stringValue)
//            }
//        }
//        if c["loglevel"].error == nil {
//            loglevel = c["loglevel"].stringValue..trimmingCharacters(in: .whitespacesAndNewlines)
//        }
//        
//        if c["url"].error == nil {
//            url = c["url"].stringValue
//        }
//        if c["commnet"].error == nil {
//            commnet = c["commnet"].stringValue
//        }
    }
    public func resp() ->String{
        var result = "[General]\n"
        result  += "loglevel = \(loglevel)\n"
        if !dnsserver.isEmpty {
            result += "dns-server = "
            for i in dnsserver {
                if i == dnsserver.last!{
                    result += i
                }else {
                    result += i + ","
                }
            }
            result += "\n"
        }
        if !bypasstun.isEmpty{
            result += "bypass-tun = "
            for i in bypasstun {
                if i == bypasstun.last!{
                    result += i
                }else {
                    result += i + ","
                }
            }
            result += "\n"
        }
        if !skipproxy.isEmpty {
            result += "skip-proxy = "
            for i in skipproxy {
                if i == skipproxy.last!{
                    result += i
                }else {
                    result += i + ","
                }
            }
            result += "\n"
        }
        return result
    }
    public func dnsString() ->String {
        var result = ""
        if !dnsserver.isEmpty {
            
            for item in dnsserver {
                result += item
                if item != dnsserver.last!{
                    result += ","
                }
            }
        }
        return result
    }
    public func updateDNS(_ string:String) {
        let list = string.components(separatedBy: ",")
        dnsserver.removeAll()
        for item in list {
            let x = item.trimmingCharacters(in: .whitespacesAndNewlines)
            dnsserver.append(x)
        }
    }
    deinit{
        
    }
}
