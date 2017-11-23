//
//  SFRuleResult.swift
//  Surf
//
//  Created by yarshure on 16/2/5.
//  Copyright © 2016年 yarshure. All rights reserved.
//

import Foundation
import AxLogger
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
public class SFRuleResult {
    public var req:String = ""
    public var result:SFRuler
    public var ipAddr:String = ""
    public var method:SFRuleResultMethod = SFRuleResultMethod.init(rawValue: 0)!
    public init(request:String, r:SFRuler) {
        req = request
        result = r
    }
    public func resp() -> [String:AnyObject] {
        var r:[String:AnyObject] = [:]
        r[req] = result.resp() as AnyObject?
        return r
    }
    deinit {
        XRuler.log("[SFSettingModule] RuleResult deinit ",level: .Debug)
    }
}
