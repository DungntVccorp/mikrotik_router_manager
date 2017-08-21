//
//  BaseMikrotikApiOperation.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/21/17.
//
//

import Foundation
import LoggerAPI

public enum ApiType {
    case NONE
    case DONE
    case RESULT
    case ERROR
    case HALT
    case TRAP
    
}

public class MikrotikRouter{
    var userName : String!
    var password : String!
    var hostName : String!
    var hostPort : Int = 0
    
    init(_ user : String,_ pass : String, _ host : String, _ port : Int = 8728) {
        
        self.hostPort = port
        self.userName = user
        self.password = pass
        self.hostName = host
    }
}


public class BaseMikrotikApiOperation: BaseOperation {
    
    public var host : String = ""
    public var port : Int = 0
    public var user : String = ""
    public var pass : String = ""
    
    public func apiString() -> String{
        return ""
    }
    
    public func toRouter() -> MikrotikRouter?{
        return nil
    }
    
    
    public func onReply(type : ApiType,tag : String,response : String){
        
    }
    
    public override func main() {
        let apistr = apiString()
        let router = toRouter()
        if apistr.isEmpty || router == nil {
            return
        }
        
        let mk =  MikrotikConnection(host: router!.hostName, port: router!.hostPort, userName: router!.userName, password: router!.password)
        let response = mk.sendAPI(api: apistr)
        if response.0 {
            print(response.2!.SentenceData)
        }
        
        /// LOGIN
        
        /// SEND REQUEST
        
        /// DISCONECT
    }
    
}
