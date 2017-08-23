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
        
        let users = ["John" : "12345", "Mary" : "qwerasdf"]
        let digestCredentials = CredentialsHTTPDigest(userProfileLoader: { userId, callback in
            if let storedPassword = users[userId] {
                callback(UserProfile(id: userId, displayName: userId, provider: "HTTPDigest"), storedPassword)
            }
            else {
                callback(nil, nil)
            }
        }, opaque: "0a0b0c0d", realm: "Kitura-users")
        
        credentials.register(plugin: digestCredentials)
        
        router.all("/", middleware: credentials)
    }
    public override func start() {
        Kitura.run()
    }
}
