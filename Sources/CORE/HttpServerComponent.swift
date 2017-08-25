//
//  HttpServerComponent.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/23/17.
//
//

import Foundation
import Kitura
import Credentials
import CredentialsHTTP

public class HttpServerComponent : BaseComponent{
    
    let router = Router()
    let credentials = Credentials()
    
    
    public override func componentType() -> ComponentType {
        return .HttpServer
    }
    public override func loadConfig() {
        Kitura.addHTTPServer(onPort: 8080, with: router)
        
        let users = ["dungnt" : "12345","admin":"12345"]
        let basicCredentials = CredentialsHTTPBasic(verifyPassword: { userId, password, callback in
            if let storedPassword = users[userId], storedPassword == password {
                callback(UserProfile(id: userId, displayName: userId, provider: "HTTPBasic"))
            } else {
                callback(nil)
            }
        })
        
        credentials.register(plugin: basicCredentials)
        
        router.all("/", middleware: credentials)
        router.all(middleware: BodyParser())
        self.routerAPI()
        device_interface_test()
    }
    public override func start() {
        Kitura.run()
    }
    
    
    
    
    
    
    
    
    
    
    
    
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
                        routerResponse.send(json: ["ERROR","ERROR DATABASE"])
                    }
                })
            }catch{
                routerResponse.send(json: ["ERROR","ERROR DATABASE"])
            }
            
            next()
        }
        
        router.post(api) { (routerRequest, routerResponse, next) in
            do{
                print(routerRequest)
               
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
                    routerResponse.send(json: ["ERROR","ERROR INVALID"])
                    next()
                    return
                }
                
                
                try Engine.sharedInstance.mySQLConnection()?.execute("INSERT INTO `tbl_router` (`name`, `username`, `password`, `ip_address`, `description`) VALUES ('\(name ?? "")', '\(user_name ?? "")', '\(password ?? "")', '\(ip_adddress ?? "")', '\(des ?? "")')", onCompletion: { (results) in
                    if(results.success){
                        routerResponse.send(json: ["OK":"CREATED"])
                    }else{
                        routerResponse.send(json: ["ERROR","ERROR DATABASE"])
                    }
                })
            }catch{
                routerResponse.send(json: ["ERROR","ERROR DATABASE"])
            }
            next()
        }
    }
    
    //// ----------------------------------------- API DEVICE -------------------------------------------------///
    func device_interface_test(){
        let test = "api/device/interface"
        router.get(test) { (routerRequest, routerResponse, next) in
            
            let getListInterface = GetListInterface(onSuccess: { (params) in
                routerResponse.send(json: ["Data":params ?? []])
                next()
            }, onFailure: { (error) in
                routerResponse.send(json: ["ERROR" :"DEO BIET"])
                next()
            })
            
            Engine.sharedInstance.operationManager()?.enqueue(operation: getListInterface)
            
            
        }
    }
    
    
    
    
}
