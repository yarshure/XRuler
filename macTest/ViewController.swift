//
//  ViewController.swift
//  macTest
//
//  Created by yarshure on 2017/12/13.
//  Copyright © 2017年 yarshure. All rights reserved.
//

import Cocoa
import XRuler
import Xcon
import DarwinCore
class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
//        testIPAddress()
//        testMitm()
        testFindProxy()
        //testAddProxy()
        
        // Do any additional setup after loading the view.
    }

    func testIPAddress(){
        let x = DCIPAddr.cellAddress()
        let p = SFNetworkInterfaceManager.ipForType("192.168.11.3")
        print(p)
        print(x)
    }
    func testFindProxy(){
        XRuler.groupIdentifier = "745WQDK4L7.com.yarshure.Surf"
        SFSettingModule.setting.config("abigt.conf")
        if let p = SFSettingModule.setting.proxyByName("Proxy") {
            print(p)
        }else {
            print("not found proxy")
        }
        if let x = SFSettingModule.setting.findRuleByString("www.google.com", useragent: ""){
            print(x.result.proxyName)
            if let px =  ProxyGroupSettings.share.findProxy(x.result.proxyName) {
                print(px)
            }
        }else {
            print("not found rule")
        }
        ProxyGroupSettings.share.monitorProxys()
        testAddProxy()
    }
    func testAddProxy(){
        print(ProxyGroupSettings.share.proxys.count)
        let x = "https,192.168.11.131,8002,,"
        if let p = SFProxy.createProxyWithLine(line: x, pname: "CN2"){
            
            _  = ProxyGroupSettings.share.addProxy(p)
        }
        print(ProxyGroupSettings.share.proxys.count)
       // SFVPNStatistics.shared.startReporting()
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    func testMitm(){
        let p = Bundle.main.path(forResource: "Mitm.conf", ofType: nil)!
        SFSettingModule.setting.config(p)
        do {
           let result =  try SFSettingModule.setting.mitmRootCA()
           print( result)
        }catch let e {
            print(e.localizedDescription)
        }
        
    }

}

