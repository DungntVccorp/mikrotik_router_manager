//
//  BaseMikrotikApiOperation.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/21/17.
//
//

import Foundation
import LoggerAPI

public enum ApiResultType {
    case NONE
    case DONE
    case RESULT
    case ERROR
    case HALT
    case TRAP
    
}
public enum ApiType {
    case SET
    case GET
    case ADD
    case DEL
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
    
    public var host : String!
    public var port : Int = 8728
    public var user : String!
    public var pass : String!
    
    var _onSuccess : ((Any?) -> Void)?
    var _onFailure : ((Error?) -> Void)?
    
    public init(onSuccess : ((Any?) -> Void)? = nil,onFailure : ((Error?) -> Void)? = nil) {
        super.init()
        _onSuccess = onSuccess
        _onFailure = onFailure
    }
    
    public func config(router_ip : String,router_username : String,router_password : String,router_port : Int = 8728) -> BaseMikrotikApiOperation{
        self.port = router_port
        self.host = router_ip
        self.user = router_username
        self.pass = router_password
        return self
    }
    
    public func apiString() -> String{
        return ""
    }
    
    public func apiType() -> ApiType{
        return .GET
    }
    
    public func queryParam() -> Dictionary<String,String>?{
        return nil
    }
    public func uidString() -> String?{
        return nil
    }
    
    public func params() -> Dictionary<String,String>?{
        return nil
    }
    
    public func onReply(isSuccess : Bool,error : MikrotikConnectionError?,response : Sentence?){
        
    }
    
    public override func main() {
        let apistr = apiString()
        if apistr.isEmpty || host == nil || host.isEmpty || user == nil || user.isEmpty || pass == nil || pass.isEmpty {
            Log.warning("router NIL || apistr NIL")
            return
        }
        
        
        let mk =  MikrotikConnection(host: host, port: port, userName: user, password: pass)
        let response = mk.sendAPI(api: apistr, params: params(),apiType: self.apiType(),querys : self.queryParam(),uid: uidString())
        onReply(isSuccess: response.0, error: response.1, response: response.2)
        
        /// LOGIN
        
        /// SEND REQUEST
        
        /// DISCONECT
    }
    
}
