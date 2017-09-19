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
import KituraCORS
public class HttpServerComponent : BaseComponent{
    
    let router = Router()
    let credentials = Credentials()
    
    
    public override func componentType() -> ComponentType {
        return .HttpServer
    }
    public override func loadConfig() {
        
        Kitura.addHTTPServer(onPort: Engine.sharedInstance.getSession()?.http_port ?? 8080, with: router)
        
        let users = ["dungnt" : "12345","khanhnd":"12345"]
        let basicCredentials = CredentialsHTTPBasic(verifyPassword: { userId, password, callback in
            if let storedPassword = users[userId], storedPassword == password {
                callback(UserProfile(id: userId, displayName: userId, provider: "HTTPBasic"))
            } else {
                callback(nil)
            }
        })
        
        credentials.register(plugin: basicCredentials)
        
        router.all("/api", middleware: credentials)
        router.all(middleware: BodyParser())
        self.routerAPI()
        self.userAPI()
//        srouter.all("/ping", middleware: credentials)
        router.post("/ping") { (routerRequest, routerResponse, next) in
            routerResponse.headers["Access-Control-Allow-Origin"] = "*"
            //routerResponse.headers["Access-Control-Allow-Headers"] = "Accept"
            
            routerResponse.send("ok")
            next()
        }
        
    }
    public override func start() {
        Kitura.run()
    }
 
}
