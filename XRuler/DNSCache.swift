//
//  DNSCache.swift
//  Surf
//
//  Created by yarshure on 2016/8/10.
//  Copyright © 2016年 yarshure. All rights reserved.
//

import Foundation

public struct DNSCache {
    public var domain:String
    public var ips:[String]
    public init(d:String, i:[String]) {
        domain = d
        ips = i
    }
}
