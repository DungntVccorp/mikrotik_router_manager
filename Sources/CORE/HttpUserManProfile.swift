//
//  HttpUserManProfile.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/28/17.
//
//

import Foundation
extension HttpServerComponent{
    public func usermanManager(){
        let api = "/api/userman/"
        router.get(api + ":id") { (routerRequest, routerResponse, next) in
            
            if let parameter = routerRequest.parameters["id"]{
                
                
                
                do{
                    /// GET ROUTER WITH ID
                    try Engine.sharedInstance.mySQLConnection()?.execute("SELECT * FROM `tbl_router` WHERE id=\(parameter)", onCompletion: { queryResult in
                        if queryResult.success {
                            if let result = queryResult.asRows{
                                if result.count == 1 {
                                    let router = result[0]
                                    if let ip_address = router["ip_address"] as? String,let username = router["username"] as? String,let password = router["password"] as? String,let port = router["port"] as? Int32{
                                        let gethotspot = GetListHospot(onSuccess: { (params) in
                                            routerResponse.send(json: ["status":200,"data":(params ?? [])])
                                            next()
                                        }, onFailure: { (error) in
                                            routerResponse.send(json: ["status":400,"message":error?.localizedDescription ?? "Error get data mikrotik"])
                                            next()
                                        }).config(router_ip: ip_address, router_username: username, router_password: password, router_port: Int(port))
                                        
                                        Engine.sharedInstance.operationManager()?.enqueue(operation: gethotspot)
                                        
                                    }else{
                                        routerResponse.send(json: ["status":400,"message":"router config missing param connect"])
                                        next()
                                    }
                                }else{
                                    routerResponse.send(json: ["status":400,"message":"not found router"])
                                    next()
                                }
                            }else{
                                routerResponse.send(json: ["status":400,"message":"not found router"])
                                next()
                            }
                        }else{
                            routerResponse.send(json: ["status":400,"message":queryResult.asError?.localizedDescription ?? "Query Error"])
                            next()
                        }
                    })
                }catch{
                    routerResponse.send(json: ["status":500,"message":error.localizedDescription])
                    next()
                }
            }else{
                routerResponse.send(json: ["status":400,"message":"id invalid"])
                next()
            }
        }
        
        router.post(api + "createuser/:id") { (routerRequest, routerResponse, next) in
            
            if let parameter = routerRequest.parameters["id"]{
                
                
                
                do{
                    /// GET ROUTER WITH ID
                    try Engine.sharedInstance.mySQLConnection()?.execute("SELECT * FROM `tbl_router` WHERE id=\(parameter)", onCompletion: { queryResult in
                        if queryResult.success {
                            if let result = queryResult.asRows{
                                if result.count == 1 {
                                    let router = result[0]
                                    if let ip_address = router["ip_address"] as? String,let username = router["username"] as? String,let password = router["password"] as? String,let port = router["port"] as? Int32{
                                        
                                        let userName_create = UUID().uuidString
                                        let password_create = UUID().uuidString
                                        let create = AddUsermanUser(onSuccess: { (p) in
                                            
                                            // set quyen
                                            
                                            let create_activate_profile = AddUsermanUserActivateProfile(onSuccess: { (s) in
                                                routerResponse.send(json: ["status":200,"data":["username":userName_create,"password":password_create]])
                                                next()
                                            }, onFailure: { (error) in
                                                routerResponse.send(json: ["status":400,"message":error?.localizedDescription ?? "Error get data mikrotik"])
                                                next()
                                            }).config(router_ip: ip_address, router_username: username, router_password: password, router_port: Int(port)) as! AddUsermanUserActivateProfile
                                            create_activate_profile.number = userName_create
                                            Engine.sharedInstance.operationManager()?.enqueue(operation:create_activate_profile)
                                            
                                        }, onFailure: { (error) in
                                            routerResponse.send(json: ["status":400,"message":error?.localizedDescription ?? "Error get data mikrotik"])
                                            next()
                                        }).config(router_ip: ip_address, router_username: username, router_password: password, router_port: Int(port))  as! AddUsermanUser
                                        create.user_id = userName_create
                                        create.password = password_create
                                        Engine.sharedInstance.operationManager()?.enqueue(operation:create)
                                        
                                        
                                        
                                    }else{
                                        routerResponse.send(json: ["status":400,"message":"router config missing param connect"])
                                        next()
                                    }
                                }else{
                                    routerResponse.send(json: ["status":400,"message":"not found router"])
                                    next()
                                }
                            }else{
                                routerResponse.send(json: ["status":400,"message":"not found router"])
                                next()
                            }
                        }else{
                            routerResponse.send(json: ["status":400,"message":queryResult.asError?.localizedDescription ?? "Query Error"])
                            next()
                        }
                    })
                }catch{
                    routerResponse.send(json: ["status":500,"message":error.localizedDescription])
                    next()
                }
            }else{
                routerResponse.send(json: ["status":400,"message":"id invalid"])
                next()
            }
        }
    }
    
    
}
