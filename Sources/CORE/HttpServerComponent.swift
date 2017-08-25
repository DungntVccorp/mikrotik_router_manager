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
