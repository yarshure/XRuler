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
extension SFPolicy:Codable{
    
}
func  groupContainerURL(_ iden:String) ->URL{
    return fm.containerURL(forSecurityApplicationGroupIdentifier: iden)!
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


