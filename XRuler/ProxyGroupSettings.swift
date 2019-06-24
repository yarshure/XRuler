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
func customDataEncoder(data: Data, encoder: Encoder) throws {
    let str = (0..<data.count).map {
        String(data[$0], radix: 16, uppercase: true)
        }.joined(separator: " ")
    
    var container = encoder.singleValueContainer()
    try container.encode(str)
}
func customDataDecoder(decoder: Decoder) throws -> Data {
    let container = try decoder.singleValueContainer()
    let str = try container.decode(String.self)
    
    let bytes = str.components(separatedBy: " ").map {
        UInt8($0, radix: 16)!
    }
    return Data(bytes)
}
extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX" //2019-06-05T16:40:19.814GMT+08:00",
        return formatter
    }()
}
public struct ProxySettings:Codable
{

    
    public var editing:Bool = false
    public static let defaultConfig = ".surf"
    public var config:String = "surf.conf"
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
    public var saveDBIng:Bool = false
    public var widgetFlow:Bool = false
    public var lastupData:Date? = Date()
    public var receipt:Receipt?
    
    static func load() throws  ->ProxySettings {
        assert(XRuler.groupIdentifier.count != 0)
        let url = groupContainerURL(XRuler.groupIdentifier).appendingPathComponent(XRuler.kProxyGroupFile)
        var content:Data
        var setting:ProxySettings
        do {
            content = try Data.init(contentsOf: url)
            let decoder = JSONDecoder()
             decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)

            //dateDecodingStrategyFormatters = [dateFormatterWithTime]
            setting =  try decoder.decode(ProxySettings.self ,from:content)
        }catch let e {
            
            print("\(#file)\(e)")
            throw e
        }
        return setting
    }
    public func save() throws{
        let en = JSONEncoder()
        en.dateEncodingStrategy = .formatted(Formatter.iso8601)
        //en.dateDecodingStrategy = .formatted(Formatter.iso8601)
        do {
            
           let data =  try en.encode(self)
            let url = groupContainerURL(XRuler.groupIdentifier).appendingPathComponent(XRuler.kProxyGroupFile)
            try data.write(to: url)
        }catch let e {
            throw e
        }
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
            st.configManager = try ProxySettings.load()
        }catch let e  {
            print(e)
            st.configManager = ProxySettings()
        }
        //CONTAIN APP ALSO RELOAD CONFIG?
        st.startObservingFileChanges()
        return st
    }()
    //var defaults:NSUserDefaults?// =
    public var configManager:ProxySettings!
 
    //Ruler config path
    public var config:String = "surf.conf" {
        didSet {
            do{
                self.configManager.config = self.config
                try self.configManager.save()
            }catch let e  {
                print(e)
            }
        }
    }
    public var eventSource:DispatchSource?


    private var filePath:String {
        get {
            return groupContainerURL(XRuler.groupIdentifier).appendingPathComponent(XRuler.kProxyGroupFile).path
        }
    }
    private func fileExists() ->Bool{
    
        return true
    }
    public func startObservingFileChanges(){
        guard fileExists() == true else {
            return
        }
        
        let descriptor = open(self.filePath, O_EVTONLY)
        if descriptor == -1 {
            return
        }
        self.eventSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: descriptor, eventMask: DispatchSource.FileSystemEvent.write, queue: DispatchQueue.main) as? DispatchSource

        self.eventSource?.setEventHandler {
            [weak self] in
            do{
                self!.configManager = try ProxySettings.load()
            }catch let e  {
                print(e)
                fatalError()
            }
        }

        self.eventSource?.setCancelHandler() {
            close(descriptor)
        }
        
        self.eventSource?.resume()
    }
    public var onFileEvent: (() -> ())? {
        willSet {
            self.eventSource?.cancel()
        }
        didSet {
            if (onFileEvent != nil) {
                self.startObservingFileChanges()
            }
        }
    }
    public func updateStyle(_ s:Bool){
        self.configManager.wwdcStyle = s
        try! save()
    }
    public var selectedProxy:SFProxy? {
        return self.configManager.proxyMan!.selectedProxy( self.configManager.selectIndex)
    }
    public func updateProxyChain(_ isOn:Bool) ->String?{

        configManager.proxyChain = isOn
        try! save()
        return nil
        // todo dynamic send tunnel provider
    }
    public var chainProxy:SFProxy?{
        get {
            if configManager.proxyChainIndex < configManager.proxyMan!.chainProxys.count{
                return configManager.proxyMan!.chainProxys[configManager.proxyChainIndex]
            }else {
                return configManager.proxyMan!.chainProxys.first
            }
            
        }
    }
    public func changeIndex(_ srcPath:IndexPath,destPath:IndexPath){
        //有个status section pass
        configManager.proxyMan!.changeIndex(srcPath, destPath: destPath)
       
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
        
        return configManager.proxyMan!.findProxy(proxyName, dynamicSelected: configManager.dynamicSelected, selectIndex: configManager.selectIndex)
        //return nil
        
    }
    public func cutCount() ->Int{
        return configManager.proxyMan!.cutCount()
    }
    public func removeProxy(_ Index:Int,chain:Bool = false) {
        configManager.proxyMan!.removeProxy(Index, chain: chain)
        do {
            try save()
        }catch let e as NSError{
            print("proxy group save error \(e)")
        }
        
    }


    public var proxysAll:[SFProxy] {
        get {
            var new:[SFProxy] = []
            new.append(contentsOf: configManager.proxyMan!.proxys)
            new.append(contentsOf: configManager.proxyMan!.chainProxys)
            return new
        }
    }
   

    public func cleanDeleteProxy(){
        configManager.cleanDeleteProxy()
    }
    public func addProxy(_ proxy:SFProxy) -> Bool {
       
        return configManager.addProxy(proxy)
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
        configManager.proxyMan!.updateProxy(p)
    }
    public func saveReceipt(_ r:Receipt) throws{
        self.configManager.receipt = r
        try save()
    }
    public func save() throws {//save to group dir

       try  self.configManager.save()

    }
    

    public var chainProxys:[SFProxy]{
        get {
            guard let c = self.configManager else {
                return []
            }
            return c.proxyMan!.chainProxys
        }
    }
    public var proxys:[SFProxy] {

        get {
            guard let c = self.configManager else {
               return []
            }
             return c.proxyMan!.proxys
        }
        set {
            guard var c = self.configManager else{
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
