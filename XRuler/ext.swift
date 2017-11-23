//
//  ext.swift
//  XRuler
//
//  Created by yarshure on 2017/11/23.
//  Copyright © 2017年 yarshure. All rights reserved.
//

import Foundation
public enum SFPolicy :String{
    case Direct = "DIRECT"
    case Reject = "REJECT"
    case Proxy = "Proxy"
    case Random =  "RANDOM"
    public var description: String {
        switch self {
        case .Direct: return "DIRECT"
        case .Reject: return "REJECT"
        case .Proxy: return "Proxy"
        case .Random: return "RANDOM"
        }
    }
}
func  groupContainerURL(_ iden:String) ->URL{
    
    return fm.containerURL(forSecurityApplicationGroupIdentifier: iden)!
    
    
    //#endif
    //return URL.init(fileURLWithPath: "")
    
}
let  fm = FileManager.default
extension String{
    func delLastN(_ n:Int) ->String{
        
        let i = self.index(self.endIndex, offsetBy: 0 - n)
        let d = self.to(index: i)
        return d
        
    }
    func to(index:String.Index) ->String{
        return String(self[..<index])
        
    }
}
//public enum SFProxyType :Int, CustomStringConvertible{
//    case HTTP = 0
//    case HTTPS = 1
//    case SS = 2
//    case SS3 = 6
//    case SOCKS5 = 3
//    case HTTPAES  = 4
//    case LANTERN  = 5
//    //case KCPTUN = 7
//    public var description: String {
//        switch self {
//        case .HTTP: return "HTTP"
//        case .HTTPS: return "HTTPS"
//        case .SS: return "SS"
//        case .SS3: return "SS3"
//        case .SOCKS5: return "SOCKS5"
//        case .HTTPAES: return "GFW Press"
//        case .LANTERN: return "LANTERN"
//            //case .KCPTUN: return "KCPTUN"
//        }
//    }
//}

