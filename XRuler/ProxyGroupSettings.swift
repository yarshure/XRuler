//
//  ProxyGroupSettings.swift
//  Surf
//
//  Created by 孔祥波 on 16/4/5.
//  Copyright © 2016年 yarshure. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper
import AxLogger
import Xcon


public class SFItem:CommonModel {
    public var original_purchase_date:String = ""
    public var original_purchase_date_ms:String = ""
    public var product_id:String = ""
    
    public override func mapping(map: Map) {
        original_purchase_date  <- map["original_purchase_date"]
        original_purchase_date_ms <- map["original_purchase_date_ms"]
        product_id <- map["product_id"]
    }
}
public class SFStoreReceiptResult: CommonModel {
    public var status:Int = 0
    public var receipt:Receipt?
    public var environment:String = ""
    public override func mapping(map: Map) {
        status  <- map["status"]
        receipt <- map["receipt"]
        environment <- map["environment"]
    }
}
public class Receipt:CommonModel {
    public var adam_id:Int = 0
    public var app_item_id:Int  = 0
    public var application_version:Int = 0
    public var bundle_id:String = ""
    public var download_id:Int = 0
    public var in_app:[SFItem] = []
    public var original_application_version:String = ""
    public var original_purchase_date:String = ""
    public var original_purchase_date_ms:String = ""
    
    public override func mapping(map: Map) {
        adam_id  <- map["adam_id"]
        app_item_id <- map["app_item_id"]
        application_version <- map["application_version"]
        
        bundle_id  <- map["bundle_id"]
        download_id <- map["download_id"]
        original_application_version <- map["original_application_version"]
        
        original_purchase_date  <- map["original_purchase_date"]
        original_purchase_date_ms <- map["original_purchase_date_ms"]
        in_app <- map["in_app"]
        //original_application_version <- map["original_application_version"]
        
    }
}
public class ProxyGroupSettings:CommonModel {
    public static let share:ProxyGroupSettings = {
        assert(XRuler.groupIdentifier.count != 0)
        let url = groupContainerURL(XRuler.groupIdentifier).appendingPathComponent(XRuler.kProxyGroupFile)
        var content:String = "{}"
        do {
            content = try String.init(contentsOf: url, encoding: .utf8)
        }catch let e {
            print("\(#file)\(e)")
        }
        
        guard let set = Mapper<ProxyGroupSettings>().map(JSONString: content) else {
            fatalError()
        }
        if set.proxyMan == nil {
            guard let ps = Mapper<Proxys>().map(JSONString: "{}") else {
                fatalError()
            }
            set.proxyMan = ps
        }
        
        print("ProxyGroup store:\(content.count)")
        return set
    }()
    //var defaults:NSUserDefaults?// =
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
    public required init?(map: Map) {
        //super.init(map: map)
        super.init(map: map)
//        editing  <- map["editing"]
//        historyEnable <- map["historyEnable"]
//        proxyMan <- map["proxyMan"]
//        
//        
//        disableWidget  <- map["disableWidget"]
//        dynamicSelected <- map["dynamicSelected"]
//        proxyChain <- map["proxyChain"]
//        
//        
//        proxyChainIndex  <- map["proxyChainIndex"]
//        showCountry <- map["showCountry"]
//        widgetProxyCount <- map["widgetProxyCount"]
//        selectIndex <- map["selectIndex"]
//        
//        config  <- map["config"]
//        saveDBIng <- map["saveDBIng"]
//        lastupData <- (map["lastupData"],self.dateTransform)
        //self.mapping(map: map)
    }
    public override func mapping(map: Map) {
        editing  <- map["editing"]
        historyEnable <- map["historyEnable"]
        proxyMan <- map["proxyMan"]
        
        
        disableWidget  <- map["disableWidget"]
        dynamicSelected <- map["dynamicSelected"]
        proxyChain <- map["proxyChain"]
        
        
        proxyChainIndex  <- map["proxyChainIndex"]
        showCountry <- map["showCountry"]
        widgetProxyCount <- map["widgetProxyCount"]
        selectIndex <- map["selectIndex"]
        
        config  <- map["config"]
        wwdcStyle <- map["wwdcStyle"]
        saveDBIng <- map["saveDBIng"]
        lastupData <- (map["lastupData"],self.dateTransform)
        receipt <- map["receipt"]
        widgetFlow <- map["widgetFlow"]
    }
    
    public func updateStyle(_ s:Bool){
        self.wwdcStyle = s
        try! save()
    }
    public var selectedProxy:SFProxy? {
        return proxyMan!.selectedProxy( selectIndex)
    }
    public func updateProxyChain(_ isOn:Bool) ->String?{

        proxyChain = isOn
        try! save()
        return nil
        // todo dynamic send tunnel provider
    }
    public var chainProxy:SFProxy?{
        get {
            if proxyChainIndex < proxyMan!.chainProxys.count{
                return proxyMan!.chainProxys[proxyChainIndex]
            }else {
                return proxyMan!.chainProxys.first
            }
            
        }
    }
    public func changeIndex(_ srcPath:IndexPath,destPath:IndexPath){
        //有个status section pass
        proxyMan!.changeIndex(srcPath, destPath: destPath)
       
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
        
        return proxyMan!.findProxy(proxyName, dynamicSelected: dynamicSelected, selectIndex: selectIndex)
        //return nil
        
    }
    public func cutCount() ->Int{
        return proxyMan!.cutCount()
    }
    public func removeProxy(_ Index:Int,chain:Bool = false) {
        proxyMan!.removeProxy(Index, chain: chain)
        do {
            try save()
        }catch let e as NSError{
            print("proxy group save error \(e)")
        }
        
    }


    public var proxysAll:[SFProxy] {
        get {
            var new:[SFProxy] = []
            new.append(contentsOf: proxyMan!.proxys)
            new.append(contentsOf: proxyMan!.chainProxys)
            return new
        }
    }
   

    public func cleanDeleteProxy(){
        if let p = proxyMan {
            p.deleteproxys.removeAll()
            do {
                try save()
            }catch let e {
                print("cleanDeleteProxy \(e.localizedDescription)")
            }
        }
    }
    public func addProxy(_ proxy:SFProxy) -> Bool {
        
        if let p = proxyMan {
            let x  = p.addProxy(proxy)
            if x != -1 {
                selectIndex = x
            }
           
            do {
                try save()
            }catch let e {
                print("add proxy failure \(e.localizedDescription)")
            }
            
            return true
        }else {
            return false
        }
        
        
    }
    
    public func updateProxy(_ p:SFProxy){
        //todo
        proxyMan!.updateProxy(p)
    }
    public func saveReceipt(_ r:Receipt) throws{
        self.receipt = r
        try save()
    }
    public func save() throws {//save to group dir

        if let js = self.toJSONString() {
            let url = groupContainerURL(XRuler.groupIdentifier).appendingPathComponent(XRuler.kProxyGroupFile)
            XRuler.log("save to \(url)",level: .Info)
            try js.write(to: url, atomically: true, encoding: .utf8)
        }

    }
    
    public func loadProxyFromFile() throws {
      
        let url = groupContainerURL(XRuler.groupIdentifier).appendingPathComponent(XRuler.kProxyGroupFile)
        var content:Data

        do {
            content = try Data.init(contentsOf: url)
            let json = try JSON.init(data: content)
            self.widgetProxyCount = json["widgetProxyCount"].intValue
            self.widgetFlow =  json["widgetFlow"].boolValue
            self.selectIndex = json["selectIndex"].intValue

            if let man = Mapper<Proxys>().map(JSONObject: json["proxyMan"]){
                self.proxyMan = man
                XRuler.logX("loadProxyFromFile OK", level: .Info)
            }

        }catch let e {
            throw e
        }

    }
    public var chainProxys:[SFProxy]{
        get {
            return proxyMan!.chainProxys
        }
    }
    public var proxys:[SFProxy] {

        get {
            return proxyMan!.proxys
        }
        set {
            proxyMan?.proxys = newValue
        }
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
                
                
                let d = Date()
                
                
                
                p.dnsValue = d.timeIntervalSince(start)
                var remoteAddr = sockaddr_in()
                remoteAddr.sin_family = sa_family_t(AF_INET)
                bcopy(remoteHost.pointee.h_addr_list[0], &remoteAddr.sin_addr.s_addr, Int(remoteHost.pointee.h_length))
                if let port = UInt16(p.serverPort) {
                    remoteAddr.sin_port = port.bigEndian
                    
                }else {
                    _  = p.serverPort
                    print("\(p.serverPort) error")
                    close(socketfd)
                    p.tcpValue = -1
                    return
                }
                
                
                
                // Now, do the connection...
                let rc = withUnsafePointer(to: &remoteAddr) {
                    // Temporarily bind the memory at &addr to a single instance of type sockaddr.
                    $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                        connect(socketfd, $0, socklen_t(MemoryLayout<sockaddr_in>.stride))
                    }
                }
                
                
                if rc < 0 {
                    print("\(p.serverAddress):\(p.serverPort) socket connect failed")
                   
                    p.tcpValue = -1
                }else {
                    let end = Date()
                    p.tcpValue = end.timeIntervalSince(d)
                    close(socketfd)
                }
                
              
                
            })
        }
    }
}
