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
                try Engine.sharedInstance.mySQLConnection()?.execute("select * from tbl_router ORDER BY id desc", onCompletion: { (results) in
                    if(results.success){
                        routerResponse.send(json: ["status":200,"data":results.asRows!])
                    }else{
                        routerResponse.send(json: ["status":400,"message":"\(results.asError?.localizedDescription ?? "Execute Error")"])
                    }
                })
            }catch{
                routerResponse.send(json: ["status":500,"message":"\(error.localizedDescription)"])
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
                routerResponse.send(json: ["status":400,"message":"missing id_router"])
                next()
                return
            }
            
            
            do{
                try Engine.sharedInstance.mySQLConnection()?.execute("DELETE FROM `tbl_router` WHERE id = \(id_router ?? "")", onCompletion: { (result) in
                    if(result.success){
                        routerResponse.send(json: ["status":200,"message":"\(result.asValue ?? "")"])
                        
                    }else{
                        routerResponse.send(json: ["status":400,"message":"\(result.asError?.localizedDescription ?? "Execute Query Error")"])
                        
                    }
                })
            }catch{
                routerResponse.send(json: ["status":500,"message":"\(error.localizedDescription)"])
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
                var port : Int = 8278
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
                    }else if p.name == "port" {
                        port = Int(p.body.asText ?? "8278")!
                    }
                }
                
                guard user_name != nil && ip_adddress != nil && name != nil && password != nil else{
                    routerResponse.send(json: ["status":400,"message":"missing param"])
                    next()
                    return
                }
                
                
                /// b1 connect to router test connect ok
                    ///b1.1 add radius server ( local va host )
                    ///b1.2 add limit + profile cho userman
                    ///b1.3 add router cho userman
                
                /// b2 gi vao` sql
                
                /// b3 tra lai thong tin
                
                
                try Engine.sharedInstance.mySQLConnection()?.execute("INSERT INTO `tbl_router` (`name`, `username`, `password`, `ip_address`, `description`,`port`) VALUES ('\(name ?? "")', '\(user_name ?? "")', '\(password ?? "")', '\(ip_adddress ?? "")', '\(des ?? "")', \(port))", onCompletion: { (results) in
                    if(results.success){
                        routerResponse.send(json: ["status":200,"message":"\(results.asValue ?? "")"])
                        
                    }else{
                        routerResponse.send(json: ["status":400,"message":"\(results.asError?.localizedDescription ?? "Unknow error")"])
                        
                    }
                })
                
                //next()
            }catch{
                routerResponse.send(json: ["status":500,"message":"\(error.localizedDescription)"])
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
                routerResponse.send(json: ["status":400,"message":"missing id_router"])
                next()
                return
            }
            
            guard user_name != nil || ip_adddress != nil || name != nil || password != nil else{
                routerResponse.send(json: ["status":400,"message":"no update"])
                next()
                return
            }
            
            
            
            do{
                try Engine.sharedInstance.mySQLConnection()?.execute("update `tbl_router` set \(strUpdate) WHERE `id` = \(id_router ?? "")", onCompletion: { (result) in
                    if(result.success){
                        routerResponse.send(json: ["status":200])
                    }else{
                        routerResponse.send(json: ["status":400,"message":"\(result.asError?.localizedDescription ?? "Unknow Error")"])
                    }
                })
            }catch{
                routerResponse.send(json: ["status":500,"message":"\(error.localizedDescription)"])
            }
            
            
            next()
        }
    }
}
