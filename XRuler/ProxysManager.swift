//
//  ProxysManager.swift
//  XRuler
//
//  Created by yarshure on 2017/12/28.
//  Copyright © 2017年 yarshure. All rights reserved.
//

import Foundation
import Xcon

public struct Proxys:Codable {
    public var chainProxys:[SFProxy] = []
    public var proxys:[SFProxy] = []
    var deleteproxys:[SFProxy] = []

 
    public func  selectedProxy(_ selectIndex:Int ) ->SFProxy? {
        if proxys.count > 0 {
            if selectIndex >= proxys.count {
                return proxys.first!
            }
            return proxys[selectIndex]
        }
        return nil
    }
    // for tunnel
    public func findProxy(_ proxyName:String,dynamicSelected:Bool,selectIndex:Int) ->SFProxy? {
        
        
        
        if proxys.count > 0  {
            
            
            var proxy:SFProxy?
            //dynamic first
            if dynamicSelected {
                if selectIndex < proxys.count {
                    proxy =   proxys[selectIndex]
                    if proxy!.tcpValue >= Double(0.0) {
                        return proxy
                    }
                }
            }
            //index name equal
            //name second
            if selectIndex < proxys.count {
                let p =  proxys[selectIndex]
                if p.proxyName == proxyName && p.tcpValue >= 0.0{
                    return p
                }else {
                    proxy = p
                }
                
            }
            var proxy2:SFProxy?
            for item in proxys {
                
                if item.proxyName == proxyName && item.tcpValue >= 0.0 {
                    proxy2 =  item
                    break
                }
            }
            if let p = proxy2 {
                return p
            }else {
                if let p = proxy {
                    return p
                }
            }
            
        }
        
        if proxys.count > 0 {
            return proxys.first!
        }
        
        
        return nil
    }
    
    public func cutCount() ->Int{
        if proxys.count <= 3{
            return proxys.count
        }
        return 3
    }
    
    public mutating func removeProxy(_ Index:Int,chain:Bool = false) {
        var p:SFProxy
        if chain {
            p = chainProxys.remove(at: Index)
        }else {
            p = proxys.remove(at: Index)
        }
        deleteproxys.append(p)
        
    }
    public mutating func changeIndex(_ srcPath:IndexPath,destPath:IndexPath){
        #if os(iOS)
            if srcPath.section == destPath.section {
                if srcPath.section == 0 {
                    changeIndex(srcPath.row, dest: destPath.row, proxylist: &proxys)
                }else {
                    changeIndex(srcPath.row, dest: destPath.row, proxylist: &chainProxys)
                }
            }else {
                if srcPath.section == 0{
                    let p = proxys.remove(at: srcPath.row)
                    chainProxys.insert(p, at: destPath.row)
                }else {
                    let p = chainProxys.remove(at: srcPath.row)
                    proxys.insert(p, at: destPath.row)
                }
            }
        #endif
    }
    public func changeIndex(_ src:Int,dest:Int,proxylist:inout [SFProxy] ){
        let r = proxylist.remove(at: src)
        proxylist.insert(r, at: dest)
        
    }
    func save()  {
        
    }

    
    public func updateProxy(_ p:SFProxy){
        //todo
        var oldArray:[SFProxy]
        var newArray:[SFProxy]
        if p.chain {
            oldArray = chainProxys
            newArray = proxys
        }else {
            oldArray = proxys
            newArray = chainProxys
        }
        if let firstSuchElement = oldArray.firstIndex(where: { $0 == p })
            .map({ oldArray.remove(at: $0) }) {
            
            
            newArray.append(firstSuchElement)
        }
    }
    
    
    public mutating func addProxy(_ proxy:SFProxy) ->Int {
        var index  = 0
        var found = false
        for p in deleteproxys {
            if p.base64String() == proxy.base64String() {
                //
                return -1
            }else {
                if p.serverAddress == proxy.serverAddress && p.serverPort == proxy.serverPort {
                    found = true
                }
            }
            index += 1
        }
        if !proxy.serverAddress.isEmpty && !proxy.serverPort.isEmpty{
            if found {
                deleteproxys[index] = proxy
                return -1
            }
        }
        found = false
        
        index  = 0
        for idx in 0 ..< proxys.count {
            let p = proxys[idx]
            if p.serverAddress == proxy.serverAddress && p.serverPort == proxy.serverPort {
                found = true
                index = idx
                break
            }
        }
        if found {
            proxys.remove(at: index)
            proxys.insert(proxy, at: index)
            
            return index
        }else {
            proxys.append(proxy)
            let selectIndex = proxys.count - 1
            return selectIndex
            
        }
        
    }
}
