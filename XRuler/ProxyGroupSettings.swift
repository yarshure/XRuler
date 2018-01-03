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
//Verify receipt Success: ["status": 0, "receipt": {
//"adam_id" = 0;
//"app_item_id" = 0;
//"application_version" = 465;
//"bundle_id" = "com.yarshure.Surf";
//"download_id" = 0;
//"in_app" =     (
//{
//"is_trial_period" = false;
//"original_purchase_date" = "2017-06-16 03:16:20 Etc/GMT";
//"original_purchase_date_ms" = 1497582980000;
//"original_purchase_date_pst" = "2017-06-15 20:16:20 America/Los_Angeles";
//"original_transaction_id" = 1000000307670913;
//"product_id" = "com.yarshure.Surf.Pro";
//"purchase_date" = "2017-06-16 03:16:20 Etc/GMT";
//"purchase_date_ms" = 1497582980000;
//"purchase_date_pst" = "2017-06-15 20:16:20 America/Los_Angeles";
//quantity = 1;
//"transaction_id" = 1000000307670913;
//}
//);
//"original_application_version" = "1.0";
//"original_purchase_date" = "2013-08-01 07:00:00 Etc/GMT";
//"original_purchase_date_ms" = 1375340400000;
//"original_purchase_date_pst" = "2013-08-01 00:00:00 America/Los_Angeles";
//"receipt_creation_date" = "2017-06-16 03:21:00 Etc/GMT";
//"receipt_creation_date_ms" = 1497583260000;
//"receipt_creation_date_pst" = "2017-06-15 20:21:00 America/Los_Angeles";
//"receipt_type" = ProductionSandbox;
//"request_date" = "2017-06-16 03:43:07 Etc/GMT";
//"request_date_ms" = 1497584587369;
//"request_date_pst" = "2017-06-15 20:43:07 America/Los_Angeles";
//"version_external_identifier" = 0;
//}, "environment": Sandbox]


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


//    public var proxysAll:[SFProxy] {
//        get {
//            var new:[SFProxy] = []
//            new.append(contentsOf: proxyMan!.proxys)
//            new.append(contentsOf: proxyMan!.chainProxys)
//            return new
//        }
//    }
   

    public func cleanDeleteProxy(){
//        if let p = proxyMan {
//            p.deleteproxys.removeAll()
//            do {
//                try save()
//            }catch let e {
//                print("cleanDeleteProxy \(e.localizedDescription)")
//            }
//        }
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
