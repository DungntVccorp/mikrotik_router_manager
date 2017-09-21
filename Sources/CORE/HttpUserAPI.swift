//
//  HttpUserAPI.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 9/14/17.
//
//

import Foundation

extension HttpServerComponent{
    func userAPI(){
        let api = "/user"

        router.post  (api) { (routerRequest, routerResponse, next) in
            routerResponse.headers["Access-Control-Allow-Origin"] = "*"
            routerResponse.headers["Content-type"] = "application/json"

            var profile_id : String?
            var router_id : String?
            var mac_address : String?
            var profileName : String!
            var connect_time : Int = 0
            for p in (routerRequest.body?.asURLEncoded ?? [:]){
                if(p.key == "profile_id"){
                    profile_id = p.value
                }else if(p.key == "router_id"){
                    router_id = p.value
                }else if(p.key == "mac_address"){
                    mac_address = p.value
                }
                
            }
            if(profile_id == nil || profile_id?.isEmpty == true || router_id == nil || router_id?.isEmpty == true || mac_address == nil || mac_address?.isEmpty == true){
                routerResponse.send(json: ["status":400,"message":"thiếu params"])
                next()
                return
            }
            if let p_name = Engine.sharedInstance.getSession()?.profiles[profile_id ?? ""]?["name"] as? String{
                profileName = p_name
            }
            if let _time = Engine.sharedInstance.getSession()?.profiles[profile_id ?? ""]?["time"] as? Int{
                connect_time = Int(_time)
            }
            if(profileName == nil || connect_time == 0){
                routerResponse.send(json: ["status":400,"message":"Không tìm thấy thông tin profile"])
                next()
                return
            }
            do{
                try Engine.sharedInstance.mySQLConnection()!.execute("SELECT * FROM `tbl_router` WHERE id = \(router_id!)", onCompletion: { (results) in
                    var arr = results.asRows
                    if(results.success && arr?.count == 1){
                        
                        if let data = arr?[0]{
                            if let server_ip = data["ip_address"] as? String, let username = data["username"] as? String , let pwd : String = data["password"] as? String,let port : Int32 = data["port"] as? Int32,let use_userman = data["use_userman"] as? Int32 {
                                let mk = MikrotikConnection(host: server_ip, port: Int(port), userName: username, password: pwd)
                                
                                let random_username = UUID().uuidString
                                let random_password = UUID().uuidString
                                if(use_userman == 1){
                                    /// USERMAN USER
                                    let req_create_user = Request(api: "/tool/user-manager/user/add", type: ApiType.ADD, p: ["username":random_username,"password":random_password,"customer":"admin","disabled":"no","shared-users":"1","caller-id":mac_address!], q: nil, u: nil)
                                    let add_profile_to_user = Request.init(api: "/tool/user-manager/user/create-and-activate-profile", type: ApiType.ADD, p: ["profile":profileName,"customer":"admin","numbers":random_username], q: nil, u: nil)
                                    
                                    _ = mk.sendAPIs(requests: [req_create_user,add_profile_to_user])
                                    
                                    routerResponse.send(json: ["status":200,"message":"ok","data":["username":random_username,"password":random_password]])
                                }else{
                                    /// HOTSPOT USER
                                    //ip hotspot user add name=abc password=abc profile=free_15p_2md_512 limit-uptime=15m
                                    let rq_add = Request(api: "/ip/hotspot/user/add", type: ApiType.ADD, p: ["name":random_username,"password":random_password,"profile":profileName,"limit-uptime":"\(connect_time)m"], q: nil, u: nil)
                                    _ = mk.sendAPIs(requests: [rq_add])
                                    
                                    routerResponse.send(json: ["status":200,"message":"ok","data":["username":random_username,"password":random_password]])
                                }
                                
                                
                            }else{
                                routerResponse.send(json: ["status":400,"message":"\(results.asError?.localizedDescription ?? "Lỗi lấy thông tin router")"])
                            }
                        }else{
                            routerResponse.send(json: ["status":400,"message":"\(results.asError?.localizedDescription ?? "Lỗi truy vấn SQL")"])
                        }
                        
                        //routerResponse.send(json: ["status":200,"message":"ok","data":results.asRows])
                    }else{
                        routerResponse.send(json: ["status":400,"message":"\(results.asError?.localizedDescription ?? "Lỗi truy vấn SQL")"])
                    }
                    
                    
                    
                    
                    next()
                })
                
                
            }catch{
                routerResponse.send(json: ["status":500,"message":"\(error.localizedDescription)"])
                next()
            }
            
            
            
            
        }
    }
}
