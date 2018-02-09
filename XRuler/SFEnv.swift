//
//  SFEnv.swift
//  Surf
//
//  Created by 孔祥波 on 8/3/16.
//  Copyright © 2016 yarshure. All rights reserved.
//

import Foundation
import NetworkExtension
import Darwin
import AxLogger
import SystemConfiguration.CaptiveNetwork
import SystemConfiguration.SCNetworkConnection

public enum SFNetWorkIPType:Int32,CustomStringConvertible {
    case ipv4  = 2//AF_INET
    case ipv6  = 30//AF_INET6
    public var description: String {
        switch self {
        case .ipv4:return "IPV4"
        case .ipv6:return "IPV6"
        
        }
    }
    public init(ip:String) {
        var sin = sockaddr_in()
        var sin6 = sockaddr_in6()
        var t:Int32 = 0
        if ip.withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1 {
            // IPv6 peer.
            t = AF_INET6
        }
        else if ip.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
            // IPv4 peer.
            t = AF_INET
        }
        self = SFNetWorkIPType.init(rawValue: t)!

    }
}
//物理层type
public enum SFNetWorkType:Int,CustomStringConvertible {
    case wifi  = 0
    case bluetooth  = 1
    case cell = 2
    case cellshare = 3 //cell share 模式
    public var description: String {
        switch self {
        case .wifi:return "WI-FI"
        case .bluetooth:return "BlueTooth"
        case .cell:return "Cell"
        case .cellshare:return "Cell Share"
        }
    }
    public init(interface:String) {
        
        var t = -1
        switch interface {
        case "en0":
            t = 0
        case "awdl0":
            t = 0
        case "pdp_ip0":
            t = 2
        case "pdp_ip1":
            t = 3
        default:
            t = 1
        }
        self = SFNetWorkType.init(rawValue: t)!
        
    }

}
extension NWPathStatus{
    var desc:String {
        get{
            switch self {
            case .invalid:
                return "invalid"
            case .satisfied:
                return "satisfied"
            case .unsatisfied:
                return "unsatisfied"
                
            case .satisfiable:
                return "satisfiable"
            }
        }
    }
}
extension NWPath{
    var info:String {
        get {
            if self.isExpensive {
                return "Expensive" + self.status.desc
            }else {
               return "Expensive no" + self.status.desc 
            }
        }
    }
}
//历史统计功能
public class SFVPNSession {
    static  let session = SFVPNSession()
    public  var startTime:Date = Date()
    public var endTime : Date = Date(timeIntervalSince1970:0)
    
    
    public func idenString() ->String {
        let f = DateFormatter();
        f.dateFormat = "yyyy_MM_dd_HH_mm_ss";
        return f.string(from: startTime)
    }
    public func shortIdenString() ->String {
        let f = DateFormatter();
        f.dateFormat = "yyyy_MM_dd_HH_mm_ss";
        return f.string(from: startTime)
    }
}
public class SFEnv {
    
    static let KB:UInt = 1024
    
    public static var ipType:SFNetWorkIPType = .ipv4
    public  static var hwType:SFNetWorkType = .cell
    static var sysMainVer = 10 //version()
    public static var session:SFVPNSession = SFVPNSession()

    init() {
    }
    static func updateEnv(_ ip:String,interface:String){
        ipType = SFNetWorkIPType.init(ip: ip)
        hwType = SFNetWorkType.init(interface: interface)
    }
    static public func updateEnvIP(_ ip:String){
        if !ip.isEmpty{
            ipType = SFNetWorkIPType.init(ip: ip)
        }
        
    }
    static func currentSSIDs() -> [String] {
        guard let interfaceNames = CNCopySupportedInterfaces() as? [String] else {
            return []
        }
        #if os(iOS)
        return interfaceNames.flatMap { name in
            guard let info = CNCopyCurrentNetworkInfo(name as CFString) as? [String:AnyObject] else {
                return nil
            }
            guard let ssid = info[kCNNetworkInfoKeySSID as String] as? String else {
                return nil
            }
            return ssid
        }
        #else
            return []
        #endif
    }
    static func updateEnvHW(_ interface:String){
        hwType = SFNetWorkType.init(interface: interface)
    }
    static public  func updateEnvHWWithPath(_ path:NWPath)  -> Bool{
        var changed = false
     
        if path.isExpensive {
            hwType = .cell
        }else {
            hwType = .wifi
        }
        let celladdr = SFNetworkInterfaceManager.WWANIPAddress
        let wifiaddr = SFNetworkInterfaceManager.WiFiIPAddress
        SFNetworkInterfaceManager.updateIPAddress(path)
        let newaddr =  SFNetworkInterfaceManager.WiFiIPAddress
        let newcelladdr = SFNetworkInterfaceManager.WWANIPAddress
        if wifiaddr != newaddr {
            changed = true
        }else {
            if newcelladdr != celladdr {
                changed = true
            }
        }
        if hwType == .wifi {
            let wifi  = currentSSIDs()
            if !wifi.isEmpty{
                XRuler.log("Now Network Type: \(hwType.description) SSID:\(wifi.first!) connected",level:.Info)
            }
        }
        
        return changed
    }
    static var SOCKS_RECV_BUF_SIZE:UInt {
       
        get {
            if SFEnv.sysMainVer == 10 {
                return SFEnv.KB*4
            }else {
                return SFEnv.KB
            }
        }
        
        
//        let TCP_CLIENT_SOCKS_RECV_BUF_SIZE_UInt:UInt = 1024
//        let CLIENT_SOCKS_RECV_BUF_SIZE:Int = KB * buf_rate
//        let CLIENT_SOCKS_RECV_BUF_SIZE_UInt:UInt = UInt(KB) * UInt(buf_rate)
    }
}
