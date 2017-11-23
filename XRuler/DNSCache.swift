//
//  DNSCache.swift
//  Surf
//
//  Created by yarshure on 2016/8/10.
//  Copyright © 2016年 yarshure. All rights reserved.
//

import Foundation

struct DNSCache {
    var domain:String
    var ips:[String]
    init(d:String, i:[String]) {
        domain = d
        ips = i
    }
}
