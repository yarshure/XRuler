//
//  XRuler.swift
//  XRuler
//
//  Created by yarshure on 2017/11/23.
//  Copyright © 2017年 yarshure. All rights reserved.
//

import Foundation
import AxLogger
public class XRuler {
    static func log(_ msg:String,items: Any...,level:AxLoggerLevel , category:String="default",file:String=#file,line:Int=#line,ud:[String:String]=[:],tags:[String]=[],time:Date=Date()){
        
        if level != AxLoggerLevel.Debug {
            AxLogger.log(msg,level:level)
        }
        print("XRuler:" + msg)
    }
    public static var kProxyGroupFile:String = ".proxygroup"
    public static var groupIdentifier:String = ""
    
    static func logX(_ msg:String,items: Any...,level:AxLoggerLevel , category:String="default",file:String=#file,line:Int=#line,ud:[String:String]=[:],tags:[String]=[],time:Date=Date()){
        
        if level != AxLoggerLevel.Debug {
            AxLogger.log(msg,level:level)
        }
        print("XRuler:" + msg)
    }
    public static func load(_ group:String,proxy:String){
        XRuler.groupIdentifier = group
        XRuler.kProxyGroupFile = proxy
        
    }
    public static func reload(){
        
    }
    
}
