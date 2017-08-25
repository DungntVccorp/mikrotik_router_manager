//
//  SessionManager.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/25/17.
//
//

import Foundation
import Configuration

public class SessionManager : BaseComponent{
    
    var mysqlHostName : String = "localhost"
    var mysqlUserName : String = "root"
    var mysqlPassword : String = "123456"
    var mysqlDBName : String = "router_manager"
    
    
    
    public let manager = ConfigurationManager()
    
    public override func componentType() -> ComponentType {
        return .Session
    }
    public override func loadConfig() {
        
        manager.load(.commandLineArguments)
    }
    public override func start() {
        
    }
}
