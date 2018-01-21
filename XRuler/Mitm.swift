//
//  File.swift
//  XRuler
//
//  Created by yarshure on 2018/1/21.
//  Copyright © 2018年 yarshure. All rights reserved.
//

import Foundation

public struct Mitm {
    var hosts:[String] = []
    var enable:Bool = false
    var passphrase:String = ""
    var p12:Data
    
}
