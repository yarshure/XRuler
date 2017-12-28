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
class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        XRuler.groupIdentifier = "745WQDK4L7.com.yarshure.Surf"
        var url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: XRuler.groupIdentifier)!
        url.appendPathComponent("abigt.conf")
        SFSettingModule.setting.config(url.path)
        if let x = SFSettingModule.setting.findRuleByString("www.google.com", useragent: ""){
            print(x)
        }else {
            print("not found")
        }
        let x = "https,192.168.11.131,8000,,"
        if let p = SFProxy.createProxyWithLine(line: x, pname: "CN2"){
            
            _  = ProxyGroupSettings.share.addProxy(p)
        }
        
        print(ProxyGroupSettings.share.proxys)
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

