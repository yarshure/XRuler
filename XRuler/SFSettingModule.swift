//
//  SFSettingModule.swift
//  Surf
//
//  Created by yarshure on 15/12/23.
//  Copyright © 2015年 yarshure. All rights reserved.
//

import Foundation
import Security
import SwiftyJSON
import AxLogger
import Xcon
import NetworkExtension
open  class SFSettingModule {
    //static let setting = SFSettingModule()
    public static var config:String = ""
    public  static let setting:SFSettingModule =  SFSettingModule()

    public enum  HTTPProxyMode{
         case socket
         case tunnel
    }
    public func check(){
        
    }
    public func custormDNS() ->[String]{
        if let r = rule{
            return r.general!.dnsserver
        }
        return []
    }
    public func ipStringV4(_ ip:UInt32) ->String{
        let a = (ip & 0xFF)
        let b = (ip >> 8 & 0xFF)
        let c = (ip >> 16 & 0xFF)
        let d = (ip >> 24 & 0xFF)
        return "\(a)." + "\(b)." + "\(c)." + "\(d)"
    }
    public func exclulesRoute() ->[NEIPv4Route] {
        var excludedRoutes = [NEIPv4Route]()
        guard let rule = rule else  {
           
            return excludedRoutes
        }
        
        if let general =  rule.general  {
            
            for item in general.bypasstun {
                let x = item.components(separatedBy: "/")
                if x.count == 2{
                    if let net = x.first, let mask = x.last {
                        //2,3,4
                        let netmask :UInt32 = 0xffffffff << (32 - UInt32( mask)!)
                        
                        let route = NEIPv4Route(destinationAddress: net, subnetMask: ipStringV4(netmask.byteSwapped))
                        route.gatewayAddress = NEIPv4Route.default().gatewayAddress
                        excludedRoutes.append(route)
                    }
                }
            }
        }
        return excludedRoutes
    }
    public func exceptionList() -> [String] {
        var excludedList = [String]()
        guard let rule = rule else  {
            
            return excludedList
        }
        
        if let general =  rule.general  {
            excludedList.append(contentsOf: general.skipproxy)
        }
        return excludedList
    }
    public func rewrite(url:String) ->(String,String) {
        var result:String = url
        //MARK: --todo url rewrite feature
        if  let r =  SFSettingModule.setting.rule{
            if let ruler = r.rewriteRule(url){
                if ruler.type == .header {
                    if let r = url.range(of: ruler.name){
                        result.replaceSubrange(r, with: ruler.proxyName)
                        let dest = ruler.proxyName
                        let dlist = dest.components(separatedBy: "/")
                        for dd in dlist {
                            if !dd.isEmpty && !dd.hasPrefix("http"){
                                //self.params["Host"] = dd
                                return (url,dd)
                            }

                        }


                    }
                }


            }
        }
        return ("","")
    }
    public var mode:HTTPProxyMode = .tunnel
    
    public func updateProxySetting(setting:NEProxySettings){
        
        if let r = rule, let g =  r.general{
            if !g.skipproxy.isEmpty {
                setting.exceptionList  = g.skipproxy
            }
            
            setting.excludeSimpleHostnames = true
            
        }
    }
    
    public let httpProxyModeSocket = true
    public var httpProxyEnable = true
    public var httpsProxyEnable = true
    public var socksProxyEnable = false
    public var udprelayer = true
    //var hosts:[DNSRecord] = []//
    //var proxy:[String:SFProxy] = [:]
    //var general:General?
    var rule:SFRule!
    
    var configFileData = Date()
    var method:Int32 = -1
    var level:AxLoggerLevel = .Info
    var adBlockRules:[String:String] = [:]
    var dnsCache:[DNSCache] = []
    init() {

    }
    public func addDNSCacheRecord(_ r:DNSCache) {
        dnsCache.append(r)
    }
    public func cleanDNSCache(){
        dnsCache.removeAll()
    }
    public func searchIPAddress(_ ip:String) ->String? {
        for r in dnsCache {
            for i in r.ips {
                if ip == i {
                    return r.domain
                }
            }
        }
        return nil
    }
    public func searchDomain(_ d:String) ->[String] {
        //带点search
        let dest = d.delLastN(1)
        if let r = findRuleByString(dest, useragent: "") {
            if r.result.policy == .Reject {
                //对于raw tcp , 之间返回127.0.0.1 可以做去广告
                XRuler.log("DNS-request \(d):127.0.0.1", level: .Warning)
                return ["127.0.0.1"]
            }
        }
        
        for r in dnsCache {
            if r.domain == d {
                return r.ips
            }
        }
        return []
    }
    //这个是给DNS 转发用的，做cache
    public func queryDomain(_ domain:String) ->String? {
        //用户设置的host 不代.
        if let r = rule {
            for item in r.hosts {
                if item.name == domain {
                    if let ip = item.ip() {
                        return ip
                    }
                }
            }
        }

        return nil
    }
  

    public func config(_ path:String){
        

        var destPath:String
        
        
        if path.isEmpty {
            //default config
            let bundle = Bundle.init(for: SFSettingModule.self)
            if let p = bundle.path(forResource: "Default", ofType: ".conf") {
                destPath =   p
                XRuler.log("Read Config From Default:\(destPath)", level: .Info)
            }else {
                fatalError()
            }
            
            
            
        }else {
            if  fm.fileExists(atPath:path) {
                XRuler.log("Read Config From :\(path)", level: .Info)
                destPath = path
            }else {
                
                destPath = groupContainerURL(XRuler.groupIdentifier).appendingPathComponent(path).path
                if  fm.fileExists(atPath:destPath) {
                    XRuler.log("Read Config From :\(destPath)", level: .Info)
                }else {
                    let    fn = ProxyGroupSettings.share.config
                    if !fn.isEmpty {
                        
                        destPath = groupContainerURL(XRuler.groupIdentifier).appendingPathComponent(fn).path
                    }else {
                        fatalError("config error")
                    }
                }
                
                
            }
            
        }
       
        
        rule =  SFRule.init(path: destPath, loadRule: true)
        rule.config()
        rule.configInfo()
        if let g = rule!.general {
            AxLogger.logleve = g.axloglevel
            XRuler.log("log level :\(g.axloglevel.description) ",level: .Info)
            
        }
        XRuler.log("Config load Finished ",level: .Info)
    }

    public var ipv6Enable:Bool{
        get {
            if let r = rule {
                return r.general!.ipv6
            }
            return false
        }
    }
    public var ipRuleEnable:Bool{
        get {
            if let r = rule {
                return r.ipRuleEnable
            }
            return false
        }
    }
    
    public func checkRemoteMitm(_ remote:String) ->Bool {
        return rule.checkMitm(remote)
        
    }
    /*
 
 ▿ 1 element
 ▿ 0 : 5 elements
 ▿ 0 : 2 elements
 - key : "label"
 - value : Surge Generated CA 9F537BE0
 ▿ 1 : 2 elements
 - key : "chain"
 ▿ value : 1 element
 - 0 : <cert(0x10130f5a0) s: Surge Generated CA 9F537BE0 i: Surge Generated CA 9F537BE0>
 ▿ 2 : 2 elements
 - key : "identity"
 - value : <SecIdentity 0x60c000074500 [0x7fff933a2980]>
 ▿ 3 : 2 elements
 - key : "trust"
 - value : <SecTrustRef: 0x608000101440>
 ▿ 4 : 2 elements
 - key : "keyid"
 - value : <44575deb b566121b b1948bf8 13aab400 88f7f8db>
 */
    public func mitmRootCA() throws -> [String:Any]{
        //var identityRef:SecIdentity
        //let cert = SecCertificateCreateWithData(nil, rule.mitmConfig.p12 as CFData)
        return try rule.mitmConfig.getIdentityDict()
        
    }
    public func reSetSettings(_ fileName:String) ->Bool{
//        NSLog("[SFSettingModule] reload rule setting")
//        proxy.removeAll()
//        //guard let configName = readConfig() else  {return false}
//        var urlContain:NSURL
//        if fileName.components(separatedBy: "/").count > 1{
//            //path
//            urlContain = NSURL(string:fileName)!
//        }else  {
//            urlContain = groupContainerURL().appendingPathComponent(fileName)
//        }
//        
//        //let d = NSData(contentsOfFile: urlContain.path!)
//        guard let path = urlContain.path, d = NSData(contentsOfFile: path)   else  {return false}
//        let JSONObject:JSON = JSON(data: d)
//       
//        var  p =  JSONObject["Rule"]
//        rule = SFRule(c: p)
//        p = JSONObject["General"]
//        general = General(c: "xx")
//        self.readProxy(JSONObject)
//        level = SFSettingModule.loglevel(general!.loglevel)
//        NSLog("[SFSettingModule] ")
        return true
    }
//    static func verifySettings(fileName:String) ->Bool {
//         NSLog("[SFSettingModule] verifySettings \(fileName)")
//        
//        let configName = ProxyGroupSettings.defaultConfig
//        
//        let urlContain = groupContainerURL().appendingPathComponent(configName)
//        NSLog("[SFSettingModule] setting url:\(urlContain)")
//        //let d = NSData(contentsOfFile: urlContain.path!)
//        guard let path = urlContain.path, d = NSData(contentsOfFile: path)   else  {return false}
//        let JSONObject:JSON = JSON(data: d)
//        
//        var  p:JSON =  JSONObject["Rule"]
//        let rule:SFRule = SFRule(c: p)
//        //NSLog("[SFSettingModule] rule:\(rule)")
//        p = JSONObject["General"]
//        let general:General = General(c: "test")
//        let proxy = testProxy(JSONObject)
//        //NSLog("[SFSettingModule] proxy:\(proxy)")
//        let level = SFSettingModule.loglevel(general.loglevel)
//        //NSLog("[SFSettingModule] loglevel:\(level.description)")
//        return true
//    
//    }
    
//    func readProxy(config:JSON) {
//       
//        let p =  config["Proxy"]
//        for (name,value) in p {
//            let i = value
//            let px = i["protocol"].stringValue as NSString
//            let proto = px.uppercaseString
//            var type :SFProxyType
//            if proto == "HTTP"{
//                type = .HTTP
//            }else if proto == "HTTPS" {
//                type = .HTTPS
//            }else if proto == "CUSTOM" {
//                type = .SS
//            }else if proto == "SS" {
//                type = .SS
//            }else if proto == "SOCKS5" {
//                type = .SOCKS5
//            }else {
//                type = .LANTERN
//            }
//
//
//            let a = i["host"].stringValue, p = i["port"].stringValue , pass = i["passwd"].stringValue , m = i["method"].stringValue
//            
//            var tlsEnable = false
//            let tls = i["tls"]
//            if tls.error == nil {
//                tlsEnable = tls.boolValue
//            }
//            let sp = SFProxy(name: name, type: type, address: a, port: p, passwd: pass, method: m,tls: tlsEnable)
//            proxy[name.uppercaseString] = sp
//        }
//        
//    }
    

    public func proxyByName(_ name:String) -> SFProxy?{
        
        let up = name.uppercased()
        if up == "DIRECT"  {
            return nil
        }
        if up == "REJECT" {
            return nil
        }
        if let p = ProxyGroupSettings.share.findProxy(name) {
            return p 
        }
        
        if up == "RANDOM" {
            return randomProxy()
        }
        return nil

      
    }
    public func randomProxy() ->SFProxy?{
        let p = ProxyGroupSettings.share.findProxy("any")
        return p
//        let count = Int(proxy.count)
//        let r = Int(arc4random())%count
//        //let proxyNAme = (proxy.keys)[r]
//        let firstKey = Array(proxy.keys)[r]
//        return proxy[firstKey]!
    }
    public func findIPFromCache(_ hostName:String) ->String?{
        let  request_atyp:SOCKS5HostType = hostName.validateIpAddr()
        if  request_atyp  == .IPV4{
            return hostName
        }
        if let r = rule {
            for item in r.hosts {
                if item.name == hostName {
                    if let ip = item.ip() {
                        return ip
                    }
                }
            }
        }
        return nil
    }
    public  func getIPFromDNS(_ hostName:String) ->String? {
        //see here http://stackoverflow.com/questions/25890533/how-can-i-get-a-real-ip-address-from-dns-query-in-swift
        let  request_atyp:SOCKS5HostType = hostName.validateIpAddr()
        if  request_atyp  == .IPV4{
            return hostName
        }
        if let r = rule {
            for item in r.hosts {
                if item.name == hostName {
                    if let ip = item.ip() {
                        return ip
                    }
                }
            }
        }
        let host = CFHostCreateWithName(nil,hostName as CFString).takeRetainedValue()
        
        CFHostStartInfoResolution(host, .addresses, nil)
        var success: DarwinBoolean = false
        if let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray?,
            let theAddress = addresses.firstObject as? Data {
            var hostname = [CChar](repeating: 0, count: Int(256))
            let p = theAddress as Data
            let value = p.withUnsafeBytes { (ptr: UnsafePointer<sockaddr>)  in
                return ptr
            }
            if getnameinfo(UnsafePointer(value), socklen_t(theAddress.count),
                           &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                let numAddress = String(cString:hostname)
                
                return numAddress
                
            }
        }

        return nil
    }
//    func ipRule(ip:String) ->JSON?{
//        
//        //IP-CIDR test 
//        //GEOIP test 
//        //final
//        let x = rule.ipcidr(ip)
//        if x != nil {
//            return x!
//        }else {
//            //GeoIP
//            //return geoIPRule(ip)
//            return nil
//        }
//        //return JSON.init(NSNull())
//    }

    public func findRuleByStringDB(_ hostname:String, useragent:String)->SFRuleResult {
       
        
        var  ruler:SFRuler
        
        
        
        if let rule = rule , let r = rule.keyword(hostname) {
            ruler = r
        }else {
            //dmainSuffix test
            //移除前面, need deep dest
            if let x  = rule?.findRuleDB(hostname) {
                ruler = x
            }else {
                
                if let ip = findIPFromCache(hostname) {
                    //XRuler.log("\(hostname):\(ip) and find ip base rule", level:.Debug)
                    
                    ruler = findIPRuler(ip)
                    print(String.init(format:"######## %@ DNS %@ rule:%@", hostname,ip,ruler.proxyName))
                    //ruler.name
                }else {
                    ruler = rule!.finalRuler
                }
            }
            
        }
        
        let result:SFRuleResult = SFRuleResult.init(request: hostname,r: ruler)
        return result
    }
    public func findRuleByString(_ hostname:String, useragent:String)->SFRuleResult? {
        //hostname or ip string
        
        if let r = SFSettingModule.setting.findRuleResult(hostname){
            return r
        }
        
        
        
        var  ruler:SFRuler
        var ipaddr:String = ""
        if !useragent.isEmpty {
            if let r = rule {
                var decodeAgent:String
                if let d = useragent.removingPercentEncoding {
                    decodeAgent = d
                }else {
                    decodeAgent = useragent
                }
                if let ruler = r.agent(decodeAgent){
                    
                    //ruler.proxyName = j["Proxy"].stringValue
                    //ruler.configPolicy(ruler.proxyName)
                    //ruler.type = .AGENT
                    let result:SFRuleResult = SFRuleResult.init(request: hostname,r: ruler)
                    return result
                }

            }
            
        }
        //调整顺序
        if  hostname.validateIpAddr( ) == .IPV4{
            return findIPRuleResult(hostname, host: "")
        }
        
        if let r = findRule(hostname) {
            ruler = r
        }else {
            //dmainSuffix test
            //移除前面, need deep dest
            guard let rule = rule else {
                let ruler = SFRuler.init()
                ruler.proxyName = "Proxy"
                ruler.type = .final
                let result:SFRuleResult = SFRuleResult.init(request: hostname,r: ruler)
                return result
            }
            if let x  = rule.keyword(hostname) {
               ruler = x
            }else {
                
                if let ip = findIPFromCache(hostname) {
                     //XRuler.log("\(hostname):\(ip) and find ip base rule", level:.Debug)
                    //host
                    XRuler.log(String.init(format:"%@ DNS %@", hostname,ip),level: .Debug)
                    ruler = findIPRuler(ip)
                    ipaddr = ip
                    //ruler.name
                }else {
                    XRuler.log("now send async dns request \(hostname)",level: .Debug)
                    //ruler = rule.finalRuler
                    return nil
                }
            }

        }
 
        var result:SFRuleResult = SFRuleResult.init(request: hostname,r: ruler)
        result.ipAddr = ipaddr
        return result
    }

    
    public func findIPRuler(_ ip:String) ->  SFRuler{
       
        var  ruler:SFRuler = SFRuler()
        
        
        if let r = rule {
            if ip.isEmpty {
                
                return r.finalRuler
            }
            
            if let x = r.ipcidr(ip) {
                ruler.name = x.name
                ruler.proxyName = x.proxyName
                
                ruler.type = .ipcidr
            }else {
                if let ru = r.geoIPRule(ip){
                   
                    return ru
                }else {
                    ruler = r.finalRuler
                }
            }
            return ruler
        }else  {
            XRuler.log("Don't find config, all FINAL DIRECT",level: .Info)
            ruler.type = .final
            ruler.proxyName = "DIRECT"
            return ruler
        }
        
        
    }
    public func findIPRuleResult(_ ip:String,host:String) ->  SFRuleResult{
        let  ruler:SFRuler = findIPRuler(ip)
        ruler.ipAddress = ip
        var result:SFRuleResult = SFRuleResult.init(request: ip,r: ruler)
        result.ipAddr = ip
        return result
    }
    public func findRule(_ hostname:String) ->SFRuler? {
        // a.b.c.d.f
        
        let list = hostname.components(separatedBy: ".")
        for i in 0 ..< list.count-1 {
            var s = list[i]
            for j in i+1 ..< list.count {
                s = s + "." + list[j]
            }
            if let r = rule {
                if let ruler = r.dmainSuffix(s){
                    //let ruler:SFRuler = SFRuler()
                    //ruler.name = s
                    //ruler.proxyName = j["Proxy"].stringValue
                    //ruler.policy = .
                    //ruler.configPolicy(ruler.proxyName)
                    //ruler.type = .DOMAINSUFFIX
                    return ruler
                }
            }
            
        }
        return nil
        //return rule.final
    }
 
    func test(){
        //NSLog("\(proxy)")
        rule!.test()
        testrule()
    }
    func testrule(){
//        let nameList = ["google.com.sg","googleapi.com.sg","www.googlestatic.com","apple.com","instagram.com","cnbeta.com","www.baidu.com"]
//        let iplist = ["17.0.0.1","125.96.0.0","216.58.221.228","192.168.1.199","121.205.165.134"]
//        for hostname in nameList{
//            let j = findRuleByString(hostname,useragent: "",c:nil)
//            NSLog("\(hostname) rule \(j.resp())")
//        }
//        for ip  in iplist{
//            let j = findIPRuleResult(ip,host:"")
//            //ruler.name = ip
//            //ruler.proxyName = json["Proxy"].stringValue
//            //ruler.type = .IPCIDR
//
//            NSLog("\(ip) rule \(j.resp())")
//            
//        }
        
    }
    public func findRuleResult(_ dest:String) -> SFRuleResult?{
        return nil
    }
    deinit {
        XRuler.logX("[SFSettingModule deinit]", items: "", level: .Info)
    }
}
