//
//  SFRuleResult.swift
//  Surf
//
//  Created by yarshure on 16/2/5.
//  Copyright © 2016年 yarshure. All rights reserved.
//

import Foundation
import AxLogger
import Xcon

public enum SFRuleResultMethod :Int, CustomStringConvertible{
    case cache = 0
    case sync = 1
    case async = 2
    public var description: String {
        switch self {
        case .cache: return "Cache"
        case .sync: return "Sync"
        case .async: return "Async"
            
        }
    }
}
extension SFRuleResultMethod:Codable{
    
}
public struct SFRuleResult:Codable {
    public var req:String = ""
    public var result:SFRuler
    public var ipAddr:String = ""
    public var method:SFRuleResultMethod = .cache
    public init(request:String, r:SFRuler) {
        req = request
        result = r
    }
}

