//
//  SFRuler.swift
//  Surf
//
//  Created by 孔祥波 on 16/1/26.
//  Copyright © 2016年 yarshure. All rights reserved.
//

import Foundation


let  DOMAINKEYWORD =  "DOMAIN-KEYWORD"
let IPCIDR = "IP-CIDR"
let DOMAINSUFFIX = "DOMAIN-SUFFIX"
let GEOIP =  "GEOIP"
let FINAL = "FINAL"
let AGENT = "AGENT"

public enum SFRulerType :Int,Codable{
    case domainkeyword = 0
    case ipcidr = 1
    case domainsuffix = 2
    case geoip = 3
    case final  = 4
    case agent  = 5 //app
    case header = 6 //just for http rewrite
    case tzt = 7 //302 rewrite
    public var description: String {
        switch self {
        case .domainkeyword: return "DOMAIN-KEYWORD"
        case .ipcidr: return "IP-CIDR"
        case .domainsuffix: return "DOMAIN-SUFFIX"
        case .geoip: return "GEOIP"
        case .final: return "FINAL"
        case .agent: return "USER-AGENT"
        case .header: return "HEADER"
        case .tzt: return "302"
        }
    }
    public static func gen(_ type:String) ->SFRulerType {
        //var typeIndex = 0
        switch type {
        case "DOMAIN-KEYWORD":
            //typeIndex = 0
            return SFRulerType.domainkeyword
        case "IP-CIDR":
            return SFRulerType.ipcidr
        case "DOMAIN-SUFFIX":
            return SFRulerType.domainsuffix
        case "GEOIP":
            return SFRulerType.geoip
        case "FINAL":
            return SFRulerType.final
        case "USER-AGENT":
            return SFRulerType.agent
        case "HEADER":
            return SFRulerType.header
        case "302":
            return SFRulerType.tzt
        default:
            return SFRulerType.domainkeyword
        }
        
    }
}

public class SFRuler:Codable {
    public var name:String = ""
    public var type:SFRulerType = .domainkeyword
    public var proxyName:String = ""
    public var timming:TimeInterval = 0.0
    public var ipAddress:String = ""
    public  init(){
        
    }
    public var policy:SFPolicy {
        let upper = proxyName.uppercased()
        if upper == "DIRECT" {
            return .Direct
        }else if upper == "REJECT"{
            return .Reject
        }
        return .Proxy
        
        
    }
    public static func createRulerWithLine(_ line:String) ->SFRuler?{
        if line.hasPrefix("DOMAIN-KEYWORD") || line.hasPrefix("DOMAIN-SUFFIX") || line.hasPrefix("DOMAIN") || line.hasPrefix("USER-AGENT") || line.hasPrefix("IP-CIDR") || line.hasPrefix("GEOIP") || line.hasPrefix("FINAL"){
            //不是非常好
        }else {
            return nil
        }
        var type:SFRulerType = .domainkeyword
        var name:String = ""
        var proxyName = ""
        let x2 = line.components(separatedBy: ",")
        if x2.count >= 2 {
            let typeString = x2[0].trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            switch  typeString{
            case "DOMAIN-KEYWORD":
                 type = .domainkeyword
            case "DOMAIN-SUFFIX","DOMAIN":
                type = .domainsuffix
            case "USER-AGENT":
                type = .agent
            case "IP-CIDR":
                type = .ipcidr
            case "GEOIP":
                type = .geoip
            case "FINAL":
                type = .final
                name = FINAL
            default:
                return nil
            }
        }
       if type != .final {
            
            if x2.count < 3 {
                return nil
            }
            //force-remote-dns 略过了 @Splash 发现错误
            name = x2[1].trimmingCharacters(in: .whitespacesAndNewlines)
            
            proxyName = x2[2].trimmingCharacters(in: .whitespacesAndNewlines)
            
        }else {
            if x2.count <  2 {
                return nil
            }
            
            proxyName = x2[1].trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let ruler = SFRuler()
        ruler.name = name
        ruler.proxyName = proxyName
        ruler.type = type
        return ruler
    }
    public func policyString() ->String{
        //这个方法是给主app 用的
        return proxyName
    }

    public func respString() ->String {
        if type == .final {
            return "\(type.description),\(proxyName)\n"
        }
        return   "\(type.description),\(name),\(proxyName)\n"
    }
    public func desc() ->String {
        if policy == .Proxy {
            return proxyName
        }
        return policy.description
    }

    public var typeId:Int64 {
        return Int64(type.rawValue)
    }
    public var policyId:Int64{
        let upper = proxyName.uppercased()
        if upper == "DIRECT" {
            return 0
        }else if upper == "REJECT"{
            return 1
        }
        return 2

    }
    public func pWith(_ s:Int64) {
        if s == 0{
            proxyName = "DIRECT"
        }else if s == 1 {
            proxyName = "REJECT"
        }else {
            proxyName = "Proxy"
        }
    }
}
