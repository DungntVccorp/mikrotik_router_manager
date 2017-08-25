//
//  HtttpRouterAPI.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/25/17.
//
//

import Foundation


extension HttpServerComponent{
    //// ----------------------------------------- API ROUTER -------------------------------------------------///
    /// GET LIST ROUTER
    func routerAPI(){
        let api = "/api/router"
        router.get(api) { (routerRequest, routerResponse, next) in
            do{
                try Engine.sharedInstance.mySQLConnection()?.execute("select * from tbl_router", onCompletion: { (results) in
                    if(results.success){
                        routerResponse.send(json: results.asRows!)
                    }else{
                        routerResponse.send(json: ["ERROR":"ERROR DATABASE"])
                    }
                })
            }catch{
                routerResponse.send(json: ["ERROR":"ERROR DATABASE"])
            }
            
            next()
        }
        
        /// DELETE
        router.delete(api) { (routerRequest, routerResponse, next) in
            
            var id_router : String?
            for p in (routerRequest.body?.asMultiPart ?? []){
                if(p.name == "id"){
                    id_router = p.body.asText
                }
            }
            guard id_router != nil else{
                routerResponse.send(json: ["ERROR":"ERROR INVALID"])
                next()
                return
            }
            
            
            do{
                try Engine.sharedInstance.mySQLConnection()?.execute("DELETE FROM `tbl_router` WHERE id = \(id_router ?? "")", onCompletion: { (result) in
                    if(result.success){
                        routerResponse.send(json: ["OK":"DELETE"])
                        
                    }else{
                        routerResponse.send(json: ["ERROR":"ERROR DATABASE"])
                        
                    }
                })
            }catch{
                routerResponse.send(json: ["ERROR":"ERROR DATABASE"])
            }
            next()
        }
        /// CREATE
        router.post(api) { (routerRequest, routerResponse, next) in
            do{
                var user_name : String?
                var password : String?
                var ip_adddress : String?
                var name : String?
                var des : String?
                for p in (routerRequest.body?.asMultiPart ?? []){
                    if(p.name == "name"){
                        name = p.body.asText
                    }else if p.name == "ip_address" {
                        ip_adddress = p.body.asText
                    }else if p.name == "username"{
                        user_name = p.body.asText
                    }else if p.name == "password" {
                        password = p.body.asText
                    }else if p.name == "description" {
                        des = p.body.asText
                    }
                }
                
                guard user_name != nil && ip_adddress != nil && name != nil && password != nil else{
                    routerResponse.send(json: ["ERROR":"ERROR INVALID"])
                    next()
                    return
                }
                
                
                try Engine.sharedInstance.mySQLConnection()?.execute("INSERT INTO `tbl_router` (`name`, `username`, `password`, `ip_address`, `description`) VALUES ('\(name ?? "")', '\(user_name ?? "")', '\(password ?? "")', '\(ip_adddress ?? "")', '\(des ?? "")')", onCompletion: { (results) in
                    if(results.success){
                        routerResponse.send(json: ["OK":"CREATED"])
                        
                    }else{
                        routerResponse.send(json: ["ERROR":"ERROR DATABASE"])
                        
                    }
                })
                
                next()
            }catch{
                routerResponse.send(json: ["ERROR":"ERROR DATABASE"])
                next()
            }
            
        }
        router.put(api) { (routerRequest, routerResponse, next) in
            var user_name : String?
            var password : String?
            var ip_adddress : String?
            var name : String?
            var des : String?
            var id_router : String?
            var strUpdate = ""
            for p in (routerRequest.body?.asMultiPart ?? []){
                if(p.name == "name"){
                    name = p.body.asText
                    if(name?.isEmpty == false){
                        if(strUpdate.isEmpty == false){
                            strUpdate = strUpdate + ","
                        }
                        strUpdate += "`name`='\(name!)'"
                    }
                }else if p.name == "ip_address" {
                    ip_adddress = p.body.asText
                    if(ip_adddress?.isEmpty == false){
                        if(strUpdate.isEmpty == false){
                            strUpdate = strUpdate + ","
                        }
                        strUpdate += "`ip_address`='\(ip_adddress!)'"
                    }
                }else if p.name == "username"{
                    user_name = p.body.asText
                    if(user_name?.isEmpty == false){
                        if(user_name?.isEmpty == false){
                            strUpdate = strUpdate + ","
                        }
                        strUpdate += "`username`='\(user_name!)'"
                    }
                }else if p.name == "password" {
                    password = p.body.asText
                    if(password?.isEmpty == false){
                        if(password?.isEmpty == false){
                            strUpdate = strUpdate + ","
                        }
                        strUpdate += "`password`='\(password!)'"
                    }
                    
                }else if p.name == "description" {
                    des = p.body.asText
                    if(des?.isEmpty == false){
                        if(des?.isEmpty == false){
                            strUpdate = strUpdate + ","
                        }
                        strUpdate += "`description`='\(des!)'"
                    }
                }else if p.name == "id"{
                    id_router = p.body.asText
                }
            }
            
            guard id_router != nil else{
                routerResponse.send(json: ["ERROR":"ERROR INVALID"])
                next()
                return
            }
            
            guard user_name != nil || ip_adddress != nil || name != nil || password != nil else{
                routerResponse.send(json: ["ERROR":"NOTING UPDATE"])
                next()
                return
            }
            
            
            
            do{
                try Engine.sharedInstance.mySQLConnection()?.execute("update `tbl_router` set \(strUpdate) WHERE `id` = \(id_router ?? "")", onCompletion: { (result) in
                    if(result.success){
                        routerResponse.send(json: ["OK":"UPDATED"])
                    }else{
                        routerResponse.send(json: ["ERROR":"ERROR DATABASE"])
                    }
                })
            }catch{
                
            }
            
            
            next()
        }
    }
}
