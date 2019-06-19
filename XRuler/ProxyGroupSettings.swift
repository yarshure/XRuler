//
//  ProxyGroupSettings.swift
//  Surf
//
//  Created by 孔祥波 on 16/4/5.
//  Copyright © 2016年 yarshure. All rights reserved.
//

import Foundation

import AxLogger
import Xcon


public struct SFItem:Codable {
    public var original_purchase_date:String = ""
    public var original_purchase_date_ms:String = ""
    public var product_id:String = ""
    

}
public struct SFStoreReceiptResult:  Codable{
    public var status:Int = 0
    public var receipt:Receipt?
    public var environment:String = ""

}
public struct Receipt:Codable {
    public var adam_id:Int = 0
    public var app_item_id:Int  = 0
    public var application_version:Int = 0
    public var bundle_id:String = ""
    public var download_id:Int = 0
    public var in_app:[SFItem] = []
    public var original_application_version:String = ""
    public var original_purchase_date:String = ""
    public var original_purchase_date_ms:String = ""
    
}

public struct ProxySettings:Codable
{
//    let wwdcStyle: Bool
//    let selectIndex: Int
//    let historyEnable: Bool
//    let proxyChain: Bool
//    let disableWidget: Bool
//    let config: String
//    let editing: Bool
//    let lastupData: Date
//    let proxyChainIndex: Int
//    
//    
//    let saveDBIng: Bool
//    let dynamicSelected: Bool
//    let widgetFlow: Bool
//    let widgetProxyCount: Int
//    let showCountry: Bool
//    
    
    public var editing:Bool = false
    public static let defaultConfig = ".surf"
    public var historyEnable:Bool = false
    var proxyMan:Proxys?
    public var disableWidget:Bool = false
    public var dynamicSelected:Bool = false
    public var proxyChain:Bool = false
    public var wwdcStyle:Bool = true
    public var proxyChainIndex:Int = 0
    public var showCountry:Bool = true
    public var widgetProxyCount:Int = 3
    public var selectIndex:Int = 0
    public var config:String = "surf.conf"
    public var saveDBIng:Bool = false
    public var widgetFlow:Bool = false
    public var lastupData:Date = Date()
    public var receipt:Receipt?
    static func load() throws  ->ProxySettings {
        assert(XRuler.groupIdentifier.count != 0)
        let url = groupContainerURL(XRuler.groupIdentifier).appendingPathComponent(XRuler.kProxyGroupFile)
        var content:Data
        var setting:ProxySettings
        do {
            content = try Data.init(contentsOf: url)
            setting =  try JSONDecoder().decode(ProxySettings.self ,from:content)
        }catch let e {
            
            print("\(#file)\(e)")
            throw e
        }
        return setting
    }
   
    mutating func cleanDeleteProxy() {
        proxyMan!.deleteproxys.removeAll()
    }
    public func addProxy(_ proxy:SFProxy) -> Bool {
        return false
    }
}
public class ProxyGroupSettings {
    public static let share:ProxyGroupSettings = {
       
        let st = ProxyGroupSettings()
        do{
            st.config = try ProxySettings.load()
        }catch let e  {
            fatalError()
        }
        
        return st
    }()
    //var defaults:NSUserDefaults?// =
    public var config:ProxySettings!
 


    
    public func updateStyle(_ s:Bool){
        self.config.wwdcStyle = s
        try! save()
    }
    public var selectedProxy:SFProxy? {
        return self.config.proxyMan!.selectedProxy( self.config.selectIndex)
    }
    public func updateProxyChain(_ isOn:Bool) ->String?{

        config.proxyChain = isOn
        try! save()
        return nil
        // todo dynamic send tunnel provider
    }
    public var chainProxy:SFProxy?{
        get {
            if config.proxyChainIndex < config.proxyMan!.chainProxys.count{
                return config.proxyMan!.chainProxys[config.proxyChainIndex]
            }else {
                return config.proxyMan!.chainProxys.first
            }
            
        }
    }
    public func changeIndex(_ srcPath:IndexPath,destPath:IndexPath){
        //有个status section pass
        config.proxyMan!.changeIndex(srcPath, destPath: destPath)
       
    }
    
    public func iCloudSyncEnabled() ->Bool{
        return UserDefaults.standard.bool(forKey: "icloudsync");
    }
    public func saveiCloudSync(_ t:Bool) {
        UserDefaults.standard.set(t, forKey:"icloudsync" )
    }
    public func writeCountry(_ config:String,county:String){
        guard let defaults = UserDefaults(suiteName:XRuler.groupIdentifier) else {return }
        defaults.set(county , forKey: config)
        defaults.synchronize()
    }
    public func readCountry(_ config:String) ->String?{
        guard let defaults = UserDefaults(suiteName:XRuler.groupIdentifier) else {return nil}
        
        return defaults.object(forKey: config)  as? String
    }
    
    public func findProxy(_ proxyName:String) ->SFProxy? {
        
        return config.proxyMan!.findProxy(proxyName, dynamicSelected: config.dynamicSelected, selectIndex: config.selectIndex)
        //return nil
        
    }
    public func cutCount() ->Int{
        return config.proxyMan!.cutCount()
    }
    public func removeProxy(_ Index:Int,chain:Bool = false) {
        config.proxyMan!.removeProxy(Index, chain: chain)
        do {
            try save()
        }catch let e as NSError{
            print("proxy group save error \(e)")
        }
        
    }


    public var proxysAll:[SFProxy] {
        get {
            var new:[SFProxy] = []
            new.append(contentsOf: config.proxyMan!.proxys)
            new.append(contentsOf: config.proxyMan!.chainProxys)
            return new
        }
    }
   

    public func cleanDeleteProxy(){
        config.cleanDeleteProxy()
    }
    public func addProxy(_ proxy:SFProxy) -> Bool {
       
        return config.addProxy(proxy)
//        if let p = config.proxyMan {
//            let x  = p.addProxy(proxy)
//            if x != -1 {
//                config.selectIndex = x
//            }
//
//            do {
//                try save()
//            }catch let e {
//                print("add proxy failure \(e.localizedDescription)")
//            }
//
//            return true
//        }else {
//            return false
//        }
        
        
    }
    
    public func updateProxy(_ p:SFProxy){
        //todo
        config.proxyMan!.updateProxy(p)
    }
    public func saveReceipt(_ r:Receipt) throws{
        self.config.receipt = r
        try save()
    }
    public func save() throws {//save to group dir

        let url = groupContainerURL(XRuler.groupIdentifier).appendingPathComponent(XRuler.kProxyGroupFile)
        //MARK: todo

    }
    
    public func loadProxyFromFile() throws {
      
        let url = groupContainerURL(XRuler.groupIdentifier).appendingPathComponent(XRuler.kProxyGroupFile)
        var content:Data

        do {
            content = try Data.init(contentsOf: url)
//            let json = try JSON.init(data: content)
//            self.widgetProxyCount = json["widgetProxyCount"].intValue
//            self.widgetFlow =  json["widgetFlow"].boolValue
//            self.selectIndex = json["selectIndex"].intValue
//
//            if let man = Mapper<Proxys>().map(JSONObject: json["proxyMan"]){
//                self.proxyMan = man
//                XRuler.logX("loadProxyFromFile OK", level: .Info)
//            }

        }catch let e {
            throw e
        }

    }
    public var chainProxys:[SFProxy]{
        get {
            guard let c = self.config else {
                return []
            }
            return c.proxyMan!.chainProxys
        }
    }
    public var proxys:[SFProxy] {

        get {
            guard let c = self.config else {
               return []
            }
             return c.proxyMan!.proxys
        }
        set {
            guard var c = self.config else{
                return
            }
            
            c.proxyMan!.proxys = newValue
        }
    }
}

extension SFProxy {
    mutating func reset(d:Date){
        self.dnsValue = Date().timeIntervalSince(d)
    }
    mutating func resetPing(){
        self.tcpValue = -1
    }
}
extension ProxyGroupSettings{
    public func monitorProxys(){
        //proxys maybe don't available now
        //only support TCP server
        let queue = DispatchQueue.init(label: "com.yarshure.monitor", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        
        
        for p in ProxyGroupSettings.share.proxys {
            if p.kcptun {
                continue
            }
            queue.async(execute: {
                
                let start = Date()
                
                // Look up the host...
                let socketfd: Int32 = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
                let remoteHostName = p.serverAddress
                //let port = Intp.serverPort
                
                guard let remoteHost = gethostbyname2(remoteHostName, AF_INET)else {
                    return
                }
                
                
                
                
                //MARK: todo fix
                
//                p.reset(d: start)
//                var remoteAddr = sockaddr_in()
//                remoteAddr.sin_family = sa_family_t(AF_INET)
//                bcopy(remoteHost.pointee.h_addr_list[0], &remoteAddr.sin_addr.s_addr, Int(remoteHost.pointee.h_length))
//                if let port = UInt16(p.serverPort) {
//                    remoteAddr.sin_port = port.bigEndian
//
//                }else {
//                    _  = p.serverPort
//                    print("\(p.serverPort) error")
//                    close(socketfd)
//                    p.resetPing()
//                    return
//                }
//
//
//
//                // Now, do the connection...
//                let rc = withUnsafePointer(to: &remoteAddr) {
//                    // Temporarily bind the memory at &addr to a single instance of type sockaddr.
//                    $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
//                        connect(socketfd, $0, socklen_t(MemoryLayout<sockaddr_in>.stride))
//                    }
//                }
//
//                if rc < 0 {
//                    print("\(p.serverAddress):\(p.serverPort) socket connect failed")
//                     p.resetPing()
//                }else {
//                    p.reset(d: d)
//                    close(socketfd)
//                }
                
              
                
            })
        }
    }
}
