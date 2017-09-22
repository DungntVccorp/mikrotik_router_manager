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
        router.all("/ping") { (routerRequest, routerResponse, next) in
            routerResponse.headers["Access-Control-Allow-Origin"] = "*"
            try? Engine.sharedInstance.mySQLConnection()?.execute("SELECT * from tbl_router where ip_address='\(routerRequest.remoteAddress)'", onCompletion: { (results) in
                var arr = results.asRows
                if(results.success && arr?.count == 1){
                    
                    if let data = arr?[0]{
                        if let server_ip = data["ip_address"] as? String, let username = data["username"] as? String , let pwd : String = data["password"] as? String,let port : Int32 = data["port"] as? Int32 {
                            let mk = MikrotikConnection(host: server_ip, port: Int(port), userName: username, password: pwd)
                            let rs_ip = Request(api: "/ip/address/print", type: ApiType.GET, p: nil, q: ["comment":"hotspotip"], u: nil)
                            let r =  mk.sendAPI2(r: rs_ip)
                            if(r.0 == true && r.2?.SentenceData.count == 1){
                                if let address = r.2?.SentenceData[0]["address"]{
                                    if let ip = address.components(separatedBy: "/").first{
                                        routerResponse.send(json: ["status":200,"message":"ok","data":["ip":"http://\(ip)"]])
                                    }else{
                                        routerResponse.send(json: ["status":400,"message":"ok","data":["ip":""]])
                                    }
                                }else{
                                    routerResponse.send(json: ["status":400,"message":"không tồn tại remove trên database"])
                                }
                                
                            }else{
                               routerResponse.send(json: ["status":400,"message":"không tồn tại remove trên database"])
                            }
                        }else{
                            routerResponse.send(json: ["status":400,"message":"không tồn tại remove trên database"])
                        }
                    }else{
                        routerResponse.send(json: ["status":400,"message":"không tồn tại remove trên database"])
                    }
                }else{
                    routerResponse.send(json: ["status":400,"message":"không tồn tại remove trên database"])
                }
                
                
                next()
            })
            
            
            
        }
        
    }
    public override func start() {
        Kitura.run()
    }
 
}
