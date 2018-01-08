//
//  XRuler.swift
//  XRuler
//
//  Created by yarshure on 2017/11/23.
//  Copyright © 2017年 yarshure. All rights reserved.
//

import Foundation
import AxLogger
import os.log
public class XRuler {
    static var debugEnable = false
    static func log(_ msg:String,level:AxLoggerLevel , category:String="default",file:String=#file,line:Int=#line,ud:[String:String]=[:],tags:[String]=[],time:Date=Date()){
        
        if level != AxLoggerLevel.Debug {
            AxLogger.log(msg,level:level)
        }
        #if os(iOS)
            if #available(iOSApplicationExtension 10.0, *) {
                os_log("XRuler: %@", log: .default, type: .debug, msg)
            } else {
                print(msg)
                
            }
        #elseif os(macOS)
            if #available(OSXApplicationExtension 10.12, *) {
                os_log("XRuler: %@", log: .default, type: .debug, msg)
            } else {
                print(msg)
                
            }
        #endif
        
    }
    public static var kProxyGroupFile:String = ".ProxyGroup"
    public static var groupIdentifier:String = ""
    
    static func logX(_ msg:String,items: Any...,level:AxLoggerLevel , category:String="default",file:String=#file,line:Int=#line,ud:[String:String]=[:],tags:[String]=[],time:Date=Date()){
        
        if level != AxLoggerLevel.Debug {
            AxLogger.log(msg,level:level)
        }
        if debugEnable {
            #if os(iOS)
                if #available(iOSApplicationExtension 10.0, *) {
                    os_log("XRuler: %@", log: .default, type: .debug, msg)
                } else {
                    print(msg)
                    
                }
            #elseif os(macOS)
                if #available(OSXApplicationExtension 10.12, *) {
                    os_log("XRuler: %@", log: .default, type: .debug, msg)
                } else {
                    print(msg)
                    
                }
            #endif
        }
        
    }
    public static func load(_ group:String,proxy:String){
        XRuler.groupIdentifier = group
        XRuler.kProxyGroupFile = proxy
        
    }
    public static func reload(){
        
    }
    
}
