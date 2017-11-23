//
//  SFRule.swift
//  Surf
//
//  Created by yarshure on 15/12/23.
//  Copyright © 2015年 yarshure. All rights reserved.
//

import Foundation
import SwiftyJSON
import MMDB
import AxLogger

struct IPCidr {
    var sIP:UInt32 = 0
    var eIP:UInt32 = 0
    var name:String = ""
    var proxyName:String = ""
    init (s:UInt32 , e:UInt32,name:String) {
        sIP = s
        eIP = e
        proxyName = name
    }
    func find(_ key:UInt32) ->Bool {
        if key >= sIP && key <= eIP {
            return true
        }
        return false
    }
}


class SFRule:SFConfig {
    //var config:JSON
    //var final:JSON
    ////
    //var name:String = ""
//    var keyworldRulers:[SFRuler] = []
//    var ipcidrRulers:[SFRuler] = []
//    var sufixRulers:[SFRuler] = []
//    var geoipRulers:[SFRuler] = []
//    var finalRuler:SFRuler = SFRuler()
//    var agentRuler:[SFRuler] = []
    
    ////
    var geoIP:[String:JSON] = [:]//support multi
    var ipcidrlist:[IPCidr] = []
    var db:MMDB?
    var cnIPList:Data?
    var cnIPCount = 0
    //var agents:[String] = []
    //var keywords:
//    init (c:JSON?) {
//        
//        finalRuler.proxyName = "Proxy"
//        //        if let p  = SFPolicy(rawValue:finalRuler.proxyName){
//        //            finalRuler.policy = p
//        //        }
//        finalRuler.type = .FINAL
//        finalRuler.name = "FINAL"
//            
//        let helper = SFRuleHelper.shared
//        let x = helper.query(3,nameFilter:"")
//        for item in x {
//            if item.name == "CN" {
//                
//                if let path = Bundle.main.path(forResource:"CNIP.bin", ofType: nil) {
//                    if let x  = NSData.init(contentsOfFile: path){
//                        cnIPList = x
//                        cnIPCount = x.length / 8
//                        print("cnIPList :\(x.length)cnIPCount :\(cnIPCount)")
//                    }
//                }
//                
//            }
//
//            geoipRulers.append(item)
//        }
//        
//        
//        //}
////        self.loadConfig(c)
////        buildData(c["IP-CIDR"])
////        mylog("reportMemory \(reportMemory())")
//    }
    
    
//    init (name:String) {
//        self.name = name
//     
//        //}
//        //        self.loadConfig(c)
//        //        buildData(c["IP-CIDR"])
//        //        mylog("reportMemory \(reportMemory())")
//    }
    func configInfo() {
        XRuler.log("Config:\(configName)",level: .Info)
        XRuler.log("Hosts:\(hosts.count)", level: .Info)
        
        XRuler.log("KEYWORD:\(keyworldRulers.count)" ,level: .Info)
        XRuler.log("DOMAIN:\(sufixRulers.count)",level: .Info)
        XRuler.log("GEOIP:\(geoipRulers.count)",level: .Info)
        XRuler.log("AGENT:\(agentRuler.count)",level: .Info)
        XRuler.log("IPCIDR:\(ipcidrRulers.count)",level: .Info)
        XRuler.log("FINAL:\(finalRuler.proxyName)",level: .Info)
        let count = hosts.count + keyworldRulers.count + sufixRulers.count + geoipRulers.count + agentRuler.count + ipcidrRulers.count
//        if ProxyGroupSettings.share.historyEnable {
//            XRuler.log("Request History enabled",level: .Info)
//        }else {
//            XRuler.log("Request History disabled",level: .Info)
//        }
        if self.ipRuleEnable {
            
            XRuler.log("IP Address base rule enable",level: .Info)
        }else {
            XRuler.log("IP Address base rule disable",level: .Info)
        }
        XRuler.log("Rule Count:\(count)",level: .Info)
    }
    func config() {
        
        
        for item in geoipRulers {
            if item.name == "CN" {
                XRuler.log("GEOIP CN enabled",level: .Info)
                if let path = Bundle.main.path(forResource: "CNIP.bin", ofType: nil) {
                    let x  = try! Data.init(contentsOf: URL.init(fileURLWithPath: path))
                        cnIPList = x
                        cnIPCount = x.count / 8
                        XRuler.log("CN Network Count :\(cnIPCount)",level: .Info)
                    
                    
                }
               
            }else {
                
            }
        }
        
        
       
        if ipRuleEnable {
            //let net = "17.0.0.0/8"
            
            var rule  = SFRuler()
            //rule.name = net
            //rule.proxyName = "DIRECT"
            
            //ipcidrRulers.append(rule)
            XRuler.log("Config Apple 17.0.0.0/8 please use config file",level: .Info)
//            let iplist = getIFAddresses()
//            
//            var wifi:NetInfo?
//            var wwan:NetInfo?
//            for item in iplist {
//                if item.ifName == "en0" {
//                    wifi = item
//                }else if item.ifName.hasPrefix("pdp_ip") {
//                    wwan = item
//                }
//            }
//            
//            if let wifi = wifi{
//                let cidr = wifi.cidr
//                if wifi.network.characters.split(".").count == 4 {
//                    net = String(format: "\(wifi.network)/%d",cidr)
//                    rule  = SFRuler()
//                    rule.name = net
//                    rule.proxyName = "DIRECT"
//                    ipcidrRulers.append(rule)
//                }else {
//                    logStream.write("WIFI have IPv6 addr")
//                }
//                
//            }
           let x =   ["192.168.0.0/16", "10.0.0.0/8", "172.16.0.0/12", "127.0.0.0/8"]
            for cidr in x {
                //net = cidr
                rule  = SFRuler()
                rule.name = cidr
                rule.proxyName = "DIRECT"
                ipcidrRulers.append(rule)
            }
            
            
        }
        
        if finalRuler.proxyName.isEmpty {
            finalRuler.proxyName = "DIRECT"
            //        if let p  = SFPolicy(rawValue:finalRuler.proxyName){
            //            finalRuler.policy = p
            //        }
            finalRuler.type = .final
            finalRuler.name = "FINAL"

        }
        defaultDNS()
    }

    func defaultDNS() {
        
            NSLog("[SFSettingModule] defaultDNS")
            if hosts.count > 100{
                return;
            }
            var d:DNSRecord
            d = DNSRecord.init(name: "edge-mqtt.facebook.com", ips: "31.13.95.5")
        
            hosts.append(d)
            
            
        
        
            d = DNSRecord.init(name: "graph.facebook.com", ips: "31.13.95.8")
            hosts.append(d)
            
        
        
            d = DNSRecord.init(name: "api.facebook.com", ips: "31.13.95.8")
            hosts.append(d)
            
        
        
            let x = ["54.192.233.169","54.192.233.9",
            "54.192.233.30",
            "54.192.233.68",
            "54.192.233.179",
            "54.192.233.50",
            "54.192.233.17",
            "54.192.233.189"]
            d = DNSRecord.init(name: "m.cn.nytimes.com", ips: x.joined(separator: ",") )
        
            d = DNSRecord.init(name: "b-api.facebook.com", ips:"31.13.95.37" )
            hosts.append(d)
        
        
        d = DNSRecord.init(name: "b-graph.facebook.com", ips:"31.13.95.37" )
            hosts.append(d)
        
            
        
        var xw  = ["199.59.148.87","199.59.150.9","199.59.149.199","199.59.150.41"]
        
        d = DNSRecord.init(name: "api.twitter.com", ips:xw.joined(separator: ",") )
        
        hosts.append(d)
        
        xw = ["64.233.189.108","64.233.189.109","173.194.72.108","173.194.72.109"]
        d = DNSRecord.init(name: "imap.gmail.com", ips: xw.joined(separator: ","))
        
        hosts.append(d)
        
        //NSLog("[SFSettingModule] defaultDNS")
        
        
    }
  
    func ipFromString(_ str:String) -> (start:UInt32,end:UInt32) {
        //print("org \(str)")
        let iprange = str.components(separatedBy:  "/")
        if iprange.count != 2 {
            return (0,0)
        }
        let x:UInt32 = 0xffffffff
        let start:UInt32  = inet_addr(iprange.first!.cString(using: String.Encoding.utf8)!)
        var  end:UInt32 = UInt32(iprange.last!)!
        if end == 32 {
            return (0,0)
        }
        end = x >> end
        end =  start.byteSwapped | end
        //print("end \(ipString(end.byteSwapped))")
        //print("start:\(start.byteSwapped) end:\(end)")
        //let ipInt:UInt32 = ipFromString(iprange.first!)
        //print(ipInt.byteSwapped)
        return (start,end.byteSwapped)
    }
    func buildData(_ j:JSON){
        
        if ipRuleEnable {
            let net = "17.0.0.0/8"
            let result = ipFromString(net)
            
            var x = IPCidr(s: result.start.byteSwapped, e: result.end.byteSwapped, name: "DIRECT")
            x.name = net
            ipcidrlist.append(x)
        }
        if j.type == .dictionary {
            for (key, value) in j.dictionaryValue{
                //172.16.0.0/12
                //Proxy: "DIRECT"
                let result = ipFromString(key)
                
                
                let pName = value["Proxy"]
                var x = IPCidr(s: result.start.byteSwapped, e: result.end.byteSwapped, name: pName.stringValue)
                x.name = key
                ipcidrlist.append(x)
            }
        }
    }
    func createdb()->Bool{
        
        #if os(iOS)
            let p = Bundle.main.bundlePath + "/../../Frameworks/MMDB.framework/"
        #else
            let p = Bundle.main.bundlePath + "/../../Frameworks/MMDB.framework/"
        #endif
        guard let b = Bundle.init(path: p) else {return false }
        guard let path = b.path(forResource: "GeoLite2-Country.mmdb", ofType: nil) else {return false}
        
        
        guard let d = MMDB(path) else {
            //NSLog("failed to open Geo db.\(path)")
            return false
        }
        db = d
       XRuler.log("GeoLite2 loaded, maybe have memory issue",level: .Warning)
        return true

    }
    func ipString(_ ip:UInt32) ->String{
        let a = (ip & 0xFF)
        let b = (ip >> 8 & 0xFF)
        let c = (ip >> 16 & 0xFF)
        let d = (ip >> 24 & 0xFF)
        return "\(a)." + "\(b)." + "\(c)." + "\(d)"
    }
    func binSearch(_ ip:UInt32,db:Data) ->Bool {
        

        
        let x = db.withUnsafeBytes { (bytes:UnsafePointer<UInt32>) -> Bool in
            var startPtr:UnsafePointer<UInt32> = UnsafePointer<UInt32>.init(bytes)
            var endPtr:UnsafePointer<UInt32> = UnsafePointer(startPtr + (cnIPCount-1)*2)
            
            var midPtr:UnsafePointer<UInt32> = UnsafePointer(startPtr + (cnIPCount-1)*2)
            var startip:UInt32 = 0
            //var midip:UInt32 = 0
            var endip:UInt32 = 0
            repeat  {
                
                //test first range
                //print("new ")
                memcpy(&startip, startPtr,4)
                memcpy(&endip,startPtr + 1,4)
                //print("\(ipString(startip))-\(ipString(endip)) req:\(ipString(ip.byteSwapped))")
                if  ip >= startip.byteSwapped && ip <= endip.byteSwapped  {
                    return true
                }else {
                    //test last range
                    startPtr = startPtr + 2
                    memcpy(&startip, endPtr,4)
                    memcpy(&endip,endPtr + 1,4)
                    //print("\(ipString(startip))-\(ipString(endip)) req:\(ipString(ip.byteSwapped))")
                    if  ip >= startip.byteSwapped && ip <= endip.byteSwapped  {
                        return true
                    }else {
                        // test mid range
                        // have bug
                        endPtr = endPtr - 2
                        var x  = (endPtr - startPtr) / 2
                        let y = x % 2
                        if y != 0 {
                            x = x-1
                        }
                        //print("xxxx \(x)")
                        midPtr = startPtr + x
                        //if midPtr >
                        memcpy(&startip, midPtr,4)
                        memcpy(&endip,midPtr + 1,4)
                        //print("\(ipString(startip))-\(ipString(endip)) req:\(ipString(ip.byteSwapped))")
                        if  ip >= startip.byteSwapped && ip <= endip.byteSwapped  {
                            return true
                        }
                        
                        if ip < startip.byteSwapped {
                            endPtr = midPtr
                        }
                        if ip > endip.byteSwapped{
                            startPtr = midPtr
                        }
                    }
                }
                
                
                
                
            } while (endPtr - startPtr) > 1
            
            return false
        }
        return x
        
    }
    func geoIPRule(_ ipString:String) ->SFRuler?{
        if !geoipRulers.isEmpty {
            if let cnIPList = self.cnIPList {
                let req = inet_addr(ipString.cString(using: String.Encoding.utf8)!)
                if  binSearch(req.byteSwapped,db: cnIPList) {
                    let message = String.init(format: "use cnIPList found result %@", ipString)
                    print(message)
                    for item in geoipRulers {
                        if item.name == "CN"{
                            return item
                        }
                        
                    }
                    
                    
                }else {
                    #if os(iOS)
                    XRuler.log("use cnIPList don't found result \(ipString)",level: .Trace)
                    return nil
                    #endif
                }
            }
            
            if !geoipRulers.isEmpty {
                var haveDB = true
                if db == nil {
                    if !createdb(){
                        haveDB = false
                    }
                }
                if haveDB{
                    #if DEBUG
                        //fatalError()
                    #endif
                    XRuler.log("use MMDBCountry match",level: .Trace)
                    if let country:MMDBCountry = db!.lookup(ipString){
                        let isoCode = country.isoCode
                        for item in geoipRulers {
                            if item.name == isoCode{
                                return item
                            }
                            
                        }
                        let ruler = SFRuler()
                        ruler.type = .geoip
                        ruler.ipAddress = ipString
                        ruler.name = isoCode
                        
                        ruler.proxyName = finalRuler.proxyName
                        return ruler
                    }else {
                        return nil
                    }
                }
            }

        }
        return nil
    }
    
    func finalRule() ->SFRuler {
        return finalRuler
    }
    func agent(_ useragent:String) ->SFRuler?{
        for r in agentRuler {
            if useragent.contains(r.name){
                return r
            }
            
        }
        return nil
        
//        let list = config["USER-AGENT"]
//        for (key,subJson):(String, JSON) in list {
//            let r = useragent.containsString(key)
//            if r {
//                return (key,subJson)
//            }
//        }
//        return ("",nil)
    }
    func findRuleDB(_ hostname:String) ->SFRuler? {
        // a.b.c.d.f
        
        let list = hostname.components(separatedBy: ".")
        for i in 0 ..< list.count-1 {
            var s = list[i]
            for j in i+1 ..< list.count {
                s = s + "." + list[j]
            }
//            let helper = SFRuleHelper.shared
//            let x = helper.query(s)
//                //if let ruler = r.dmainSuffix(s){
//                    //let ruler:SFRuler = SFRuler()
//                    //ruler.name = s
//                    //ruler.proxyName = j["Proxy"].stringValue
//                    //ruler.policy = .
//                    //ruler.configPolicy(ruler.proxyName)
//                    //ruler.type = .DOMAINSUFFIX
//                  //  return ruler
//                //}
//            if !x.isEmpty{
//                return x.first!
//            }
            
            
        }
        return nil
        //return rule.final
    }
    func keyword(_ key:String) ->SFRuler?{
        
       
        
//        for item in x {
//            if key.range(of:item.name) != nil {
//                return item
//            }
//        }
        
        
        for r in keyworldRulers {
            if key.range(of: r.name) != nil {
//                let ruler:SFRuler = SFRuler()
//                ruler.name = r.name
//                ruler.proxyName = value["Proxy"].stringValue
//                ruler.type = .DOMAINKEYWORD
                return r
            }

        }
//        
//        let j = config["DOMAIN-KEYWORD"]
//        if j.type == .Dictionary {
//            let g1 = j.dictionaryValue
//            for (k,value) in g1 {
//                if key.range(of:k) != nil {
//                    let ruler:SFRuler = SFRuler()
//                    ruler.name = k
//                    ruler.proxyName = value["Proxy"].stringValue
//                    ruler.type = .DOMAINKEYWORD
//                    return ruler
//                }
//            }
//           
//        }
        
    
        return nil
        
        
        
    }
    func ipcidr(_ key:String) ->SFRuler?{
        let ip:UInt32  = inet_addr(key.cString(using: String.Encoding.utf8)!).byteSwapped
        for cidr in ipcidrRulers {
            let net = cidr.name//"17.0.0.0/8"
            let result = ipFromString(net)
            
            let x = IPCidr(s: result.start.byteSwapped, e: result.end.byteSwapped, name: "DIRECT")
            
            if x.find(ip) {
                return cidr
                //                let r = ["Proxy":cidr.proxyName]
                //                return JSON.init(r)
            }
        }
        //let list = config["IP-CIDR"]
        //list[key]
        return nil
    }
//    func ipcidr(key:String) ->IPCidr?{
//        let ip:UInt32  = inet_addr(key.cStringUsingEncoding(NSUTF8StringEncoding)!).byteSwapped
//        for cidr in ipcidrlist {
//            if cidr.find(ip) {
//                return cidr
////                let r = ["Proxy":cidr.proxyName]
////                return JSON.init(r)
//            }
//        }
//        //let list = config["IP-CIDR"]
//        //list[key]
//        return nil
//    }
    func dmainSuffix(_ key:String) ->SFRuler?{
        for ruler in sufixRulers {
            if key == ruler.name{
                return ruler
            }
        }
        return nil
//        let list = config["DOMAIN-SUFFIX"]
//        return list[key]
    }
    func test(){
//        print(keyword("google"))
//        print(dmainSuffix("4share.com").object)
    }
    deinit {
       print( "Rule Released")
    }
}
