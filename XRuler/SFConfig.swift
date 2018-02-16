//
//  SFConfig.swift
//  Surf
//
//  Created by yarshure on 16/2/3.
//  Copyright © 2016年 yarshure. All rights reserved.
//

import Foundation
import Xcon
import AxLogger
import XFoundation
public struct DNSRecord {
    public var name = ""
    public var ips:String = ""
    public var timing:TimeInterval = 0
    public init(name:String,ips:String){
        self.name = name
        self.ips = ips
    }
    public func resp() ->[String:String]{
        //        if let x = ips.first {
        //            return [name:x]
        //        }
        return [name:ips]
        
    }
    public func ip() -> String?{
        let xps = ips.components(separatedBy: ",")
        if xps.isEmpty {
            return nil
        }else {
            return xps.first!
        }
    }
}
public enum SFConfigWriteError:Int, CustomStringConvertible{
    case success = 0
    case exist = 1
    case noName = 2
    case other = 3
    public var description: String {
        switch self {
        case .success:return "Config Save Success"
        case .exist:return "Config Exist"
        case .noName:return "Config Need Name"
        case .other:return "Other Error"
        }
    }
}

public enum SFConfigSectionType:Int, CustomStringConvertible{
    case general = 0
    case proxy = 1
    case rule = 2
    case host = 3
    case proxyGroup = 4
    case mitm = 5
    public var description: String {
        switch self {
        case .general:return "General"
        case .proxy:return "Proxy"
        case .rule:return "Rule"
        case .host:return "Host"
        case .proxyGroup:return "ProxyGroup"
        case .mitm:return "MITM"
        }
    }
}
public protocol SFConfigDelegate {
    func addProxy(_ proxy:SFProxy)
    
}
public class SFConfig {
    public var configName:String = ""
    public var keyworldRulers:[SFRuler] = []
    public var ipcidrRulers:[SFRuler] = []
    public var sufixRulers:[SFRuler] = []
    public var geoipRulers:[SFRuler] = []
    public var finalRuler:SFRuler = SFRuler()
    public var agentRuler:[SFRuler] = []
    public var proxys:[SFProxy] = []
    public var hosts:[DNSRecord] = []//
    public var rewrite:[SFRuler] = []
    public var changed:Bool = false
    public var loadResult:Bool = true
    
    public var  general:General?
    public  var delegate:SFConfigDelegate?
    public var mitmConfig:Mitm!
  
    public  init(name:String){
        self.configName = name
        //let r = SFRuler.init()
        //r.type = SFRulerType.HEADER
        //# 搜索 URL 替换 ^http://www.google.cn http://www.google.com.hk 
        //^http://m.baidu.com/s\?from=1099b&word= http://google.com/search\?q= 
        //https://m.baidu.com/s?from=1099b&word=李白&s2bd=t
        //^http://www.baidu.com/s\?wd= http://google.com/search\?q=
        
        //r.name =
        //r.proxyName =
        //rewrite.append(r)
    }
    public  func rewriteRule(_ url:String) ->SFRuler?{
        for r in rewrite {
            if url.hasPrefix(r.name) {
                return r
            }
        }
        
        return nil
    }
    public var ipRuleEnable:Bool{
        get {
            if ipcidrRulers.count == 0 && geoipRulers.count == 0 {
                return false
            }else {
                return true
            }
        }
    }
    func parser(_ line:String) ->String {
        let p = line.components(separatedBy: "=")
        if p.count == 2 {
            let q = p.last
            return  q!.trimmingCharacters(in: .whitespacesAndNewlines)
            
        }
        return ""
    }
    func parser(_ line:String) ->([String]) {
        let x = line.components(separatedBy: "=")
        var result:[String] = []
        if x.count == 2 {
            let last = x.last!
            let items = last.components(separatedBy: ",")
            for i in items {
                result.append(i.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        
       
        return result
    }
    func parserM(_ line:String) ->(String,[String]) {
        let x = line.components(separatedBy: "=")
        if x.count == 2 {
            //found record
            let name = x.first!.trimmingCharacters(in: .whitespacesAndNewlines)
            let v = x.last!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            return(name,[v])
        }
        return ("",[])
    }
    public init(path:String, loadRule:Bool){
        if let fn = path.components(separatedBy: "/").last,let conf  = fn.components(separatedBy: ".conf").first {
            configName = conf
        }
        let rlist = ["http://www.google.cn":"http://www.google.com","http://m.baidu.com/s\\?from=1099b&word=":"http://www.google.com/search\\?q=","http://www.baidu.com/s\\?wd=":"http://www.google.com/search\\?q="]
        for (rk,rv) in rlist {
            let r = SFRuler.init()
            r.type = SFRulerType.header
            r.name = rk
            r.proxyName = rv
            rewrite.append(r)
        }
        
        print(" \(path) \(configName)")
        var content = ""
        do {
            content = try String.init(contentsOf: URL.init(fileURLWithPath: path))
            //content = try  NSString.init(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue) as String
        }catch let error {
            XRuler.logX("read \(path) failure ",items: error.localizedDescription, level: .Error)
            return
        }
        let x = content.components(separatedBy: "\n")
        
        //var rules:[SFRuler] = []
        //var proxys:[SFProxy] = []
        general = General.init(c: "abigt")
        
        var type:SFConfigSectionType = .general
        for item in x {
            
            //print("\(item)")
            if item.hasPrefix("[Host]"){
                type = .host
                continue
            }else if item.hasPrefix("[Proxy]"){
                type = .proxy
                continue
            }else if item.hasPrefix("[Rule]") {
                type = .rule
                continue
            }else if item.hasPrefix("[General]") {
                self.general = General.init(c: "")
                type = .general
                continue
            }else if item.hasPrefix("[ProxyGroup]") &&  item.hasPrefix("[Proxy Group]"){
                type = .proxyGroup
                continue
            }else if item.hasPrefix("[MITM]")  {
                type = .mitm
                self.mitmConfig = Mitm.init(hosts:[],enable: false,passphrase: "",p12: Data())
                continue
            }else {
                
            }
            switch type {
            case .general:
                if  item.hasPrefix("dns-server")  {
                    let items:[String] = parser(item)
                    general?.dnsserver = items
                    
                }else if item.hasPrefix("skip-proxy") {
                    let items:[String] = parser(item)
                    general?.skipproxy = items
                  
                    
                }else if  item.hasPrefix("bypass-tun") {
                    let items:[String] = parser(item)
                    general?.bypasstun = items
                 
                }else if  item.hasPrefix("logleve") {
                    general?.loglevel = parser(item)
                    
                }else if item.hasPrefix("interface"){
                    general?.interface = parser(item)
                   
                }else if item.hasPrefix("ipv6"){
                    if  parser(item) == "true"{
                        general?.ipv6  = true
                    }else {
                        general?.ipv6  = false
                    }
                    
                }else if item.hasPrefix("port"){
                    let p:String = parser(item)
                    if let x = Int(p.trimmingCharacters(in: .whitespacesAndNewlines)){
                        general?.port = x
                    }
                    
                }else {
                    print("General not process " + item)
                }


            case .proxy:
               
                let x = item.components(separatedBy: "=")
                print("proxy: \(item)")
                if x.count == 2 {
                    //found record
                    if let p = SFProxy.createProxyWithLine(line: x.last!, pname: x.first!){
                        _ = self.delegate?.addProxy(p)
                        proxys.append(p)
                    }
                    
                }
                
                break
            case .rule:
                if  let r  = SFRuler.createRulerWithLine(item){
                    if !r.name.isEmpty && !r.proxyName.isEmpty{
                        //print("RULE: " + r.name + " \(r.type.description) " + r.proxyName)
                        //saveRuler(r)
                        //rules.append(r)
                        switch r.type {
                        case .geoip:
                            geoipRulers.append(r)
                        case .agent:
                            agentRuler.append(r)
                            
                        case .final:
                            finalRuler = r
                            
                        case .domainkeyword:
                            keyworldRulers.append(r)
                            
                        case .domainsuffix:
                            sufixRulers.append(r)
                            
                        case .ipcidr:
                            ipcidrRulers.append(r)
                        case .header:
                            break
                        default:
                            break
                            
                        }
                    }
                }else {
                    //print("line rule :\(item) parser  error")
                }
                
            case .host:
                let x = parserM(item)
                if !x.0.isEmpty {
                    let d  = DNSRecord(name:x.0,ips: x.1.first!)
                    hosts.append(d)
                }
                

            case .proxyGroup:
                print("ProxyGroup Don't support")
            case .mitm:
                guard let r = item.range(of: "=") else {continue}
                let key = item.to(index: r.lowerBound)
                let value = String(item[r.upperBound...])
                print(key + ":" + value)
                let x = item.components(separatedBy: "=")
               
                    switch key.trimmingCharacters(in: .whitespacesAndNewlines) {
                    case "enable":
                       
                        if !value.isEmpty{
                            let enable = value.trimmingCharacters(in: .whitespacesAndNewlines)
                            if enable == "true"{
                                mitmConfig.enable = true
                            }
                        }
                    case "hostname":
                        if !value.isEmpty{
                            let hs = value.components(separatedBy: ",")
                            for z in hs {
                               mitmConfig.hosts.append(z.trimmingCharacters(in: .whitespacesAndNewlines))
                            }
                        }
                    case "ca-passphrase":
                        if !value.isEmpty{
                            mitmConfig.passphrase = value.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    case "ca-p12":
                        if !value.isEmpty{
                            let strbase64 = value.trimmingCharacters(in: .whitespacesAndNewlines)
                            if let d = Data.init(base64Encoded: strbase64){
                                mitmConfig.p12 = d
                            }
                            
                        }
                    default:
                        print("default: \(x)")
                    }
                
            }
            
        }
//        try! ProxyGroupSettings.share.save()
//        let error:SFConfigWriteError = config.writeConfig(config.configName, copy: false, force: true,shareiTunes: false)
//        print(error.description)
        
    }
    func checkMitm(_ remote:String) ->Bool {
        if mitmConfig == nil {
            return false
        }
        
        for x in mitmConfig.hosts{
            if x == remote {
                return true
            }
        }
        
        
        return false
    }
    public  func description() ->String {
        let count = agentRuler.count + keyworldRulers.count +  sufixRulers.count  + ipcidrRulers.count + geoipRulers.count + 1
        var geoIPCN = "GEOIPCN disable"
        for r in geoipRulers {
            if r.name == "CN" {
                geoIPCN = "GEOIPCN " + r.proxyName
            }
        }
        
      
        
        return "\(count) Rules ," + geoIPCN + ",FINAL: " + finalRuler.proxyName
    }
 
    

    public func verifyRules(_ r:SFRuler) ->Bool {
        let up = r.proxyName
        if  up == "DIRECT" || up == "REJECT" || up == "RANDOM" || up == "PROXY" {
            return true
        }
        
        if r.proxyName.count > 0  {
            var found = false
            for p in proxys {
                if p.proxyName == r.proxyName {
                    found = true
                    break
                }
            }
            return found
        }
        return true
    }
    public func genRuleString(_ rules:[SFRuler]) ->String{
        var result = ""
        for rule in rules {
            let x = rule.respString()
            //print( x)
            result += x
        }
        return result
    }
   
    public func genData() ->String{
       
        
        var result:String = ""
        if let g = general {
            let count = ipcidrRulers.count + agentRuler.count + geoipRulers.count + 1 + sufixRulers.count + keyworldRulers.count
            g.commnet = "\(count) Rules \(proxys.count) Proxy"
            result  += g.resp()
            
        }
        
        result += "[Rule]\n"
        
        result += genRuleString(agentRuler)
        result +=  genRuleString(keyworldRulers)
        result += genRuleString(sufixRulers)
        result += genRuleString(ipcidrRulers)
        result +=  genRuleString(geoipRulers)
        result +=  finalRuler.respString()//genRuleDict(finalRuler)
        
        //config["Rule"]  = ruleslist
        if hosts.count > 0 {
            result += "[Host]\n"
            
            for hx in hosts {
               result += "\(hx.name) = \(hx.ip()!)\n"
            }
            //config["Hosts"] = h
        }
        
        
        return result
    }

    

    
    public func findProxy(_ line:String, type:SFProxyType) ->SFProxy?{
        guard let proxy = SFProxy.create(name: "", type: .SS, address: "", port: "", passwd: "", method: "",tls:false) else {return nil}
        proxy.type = type
        let x = line.components(separatedBy: "=")
        if x.count == 2 {
            proxy.proxyName = x.first!.trimmingCharacters(in: .whitespacesAndNewlines)
            let p = x.last!
            let q = p.components(separatedBy: ",")
            
            var index = 0
            for item in q {
                switch index {
                case 0:
                    if item == "https"{
                        proxy.tlsEnable = true
                    }
                case 1:
                    proxy.serverAddress = item
                case 2:
                    proxy.serverPort = item
                case 3:
                    proxy.method = item
                case 4:
                    proxy.password = item
                default:
                    break
                }
                
                index += 1
            }
            _ = self.delegate?.addProxy(proxy)
            return proxy
        }
        
        return nil
    }

}
extension SFConfig: Equatable {}

public func ==(lhs:SFConfig,rhs:SFConfig) -> Bool {
    
    return (lhs.configName == rhs.configName) 
}
