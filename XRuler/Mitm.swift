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
    
    func getIdentityDict() throws ->[String:Any]{
        var importResult: CFArray? = nil
        let err = SecPKCS12Import(
            p12 as NSData,
            [kSecImportExportPassphrase as String: passphrase] as NSDictionary,
            &importResult
        )
        guard err == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(err), userInfo: nil)
        }
        let identityDictionaries = importResult as! [[String:Any]]
        return identityDictionaries[0]
    }
}
