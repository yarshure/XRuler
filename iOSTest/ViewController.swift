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
        XRuler.groupIdentifier = "group.com.yarshure.Surf"
        
        
        testFindProxy()
        // Do any additional setup after loading the view, typically from a nib.
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

