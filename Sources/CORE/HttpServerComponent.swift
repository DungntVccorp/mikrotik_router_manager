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
        
        self.routerAPI()
    }
    public override func start() {
        Kitura.run()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    //// ----------------------------------------- API ROUTER -------------------------------------------------///
    /// GET LIST ROUTER
    func routerAPI(){
        router.get("/api/router") { (routerRequest, routerResponse, next) in
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
    }
    
    
    
    
    
    
}
