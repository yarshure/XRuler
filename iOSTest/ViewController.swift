//
//  ViewController.swift
//  iOSTest
//
//  Created by yarshure on 2018/1/2.
//  Copyright © 2018年 yarshure. All rights reserved.
//

import UIKit
import XRuler
import Xcon

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
        prepare("group.com.yarshure.Surf", app: "xxxx", config: "surf.con")
        
       // XRuler.groupIdentifier = "group.com.yarshure.Surf"
        
        
       // SFNetworkInterfaceManager.updateIPAddress()
        testFindProxy()
       let x = SFSettingModule.setting.custormDNS()
        print(x)
        // Do any additional setup after loading the view, typically from a nib.
    }

    func prepare(_ bundle:String,app:String, config:String){
        //SKit.groupIdentifier = bundle
        //SKit.app = app
        XRuler.groupIdentifier =  bundle
        
        
        
        ProxyGroupSettings.share.historyEnable = true
        if ProxyGroupSettings.share.historyEnable {
            
            //let helper = RequestHelper.shared
            //let session = SFEnv.session.idenString()
            
            
            //helper.open( session,readonly: false,session: session)
        }
        
        
        if !config.isEmpty {
            ProxyGroupSettings.share.config = config
        }
        SFSettingModule.setting.config(config)
        

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func testFindProxy(){
        var url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: XRuler.groupIdentifier)!
        url.appendPathComponent("abigt.conf")
        SFSettingModule.setting.config(url.path)
        if let p = SFSettingModule.setting.proxyByName("Proxy") {
            print(p)
        }else {
            print("not found proxy")
        }
        if let x = SFSettingModule.setting.findRuleByString("www.google.com", useragent: ""){
            print(x)
            
        }else {
            print("not found rule")
        }
        
    }
    func testAddProxy(){
        let x = "https,192.168.11.131,8000,,"
        if let p = SFProxy.createProxyWithLine(line: x, pname: "CN2"){
            
            _  = ProxyGroupSettings.share.addProxy(p)
        }
        print(ProxyGroupSettings.share.proxys)
    }
}

