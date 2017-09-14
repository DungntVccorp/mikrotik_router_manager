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
    var dataStorePath : String = "db.plist"
    var public_server_radius_ip : String = "10.3.3.202"
    var public_server_radius_username : String = "admin"
    var public_server_radius_password : String = "123456"
    var public_server_radius_port : Int = 8728
    
    
    
    var http_port : Int = 8080
    
    var profiles : Array<Dictionary<String,Any>> = [
        ["id":1,"name":"free_15p_2md_1mu","md":2,"mu":1,"time":15],
        ["id":2,"name":"free_15p_2md_2mu","md":2,"mu":2,"time":15],
        ["id":3,"name":"free_15p_3md_1mu","md":3,"mu":1,"time":15],
        ["id":4,"name":"free_15p_3md_2mu","md":3,"mu":2,"time":15],
        ["id":5,"name":"free_15p_5md_2mu","md":5,"mu":2,"time":15],
        ["id":6,"name":"free_15p_5md_3mu","md":5,"mu":3,"time":15],
        ["id":7,"name":"free_30p_2md_1mu","md":2,"mu":1,"time":30],
        ["id":8,"name":"free_30p_2md_2mu","md":2,"mu":2,"time":30],
        ["id":9,"name":"free_30p_3md_1mu","md":3,"mu":1,"time":30],
        ["id":10,"name":"free_30p_3md_2mu","md":3,"mu":2,"time":30],
        ["id":11,"name":"free_30p_5md_2mu","md":5,"mu":2,"time":30],
        ["id":12,"name":"free_30p_5md_3mu","md":5,"mu":3,"time":30],
        ["id":13,"name":"free_45p_2md_1mu","md":2,"mu":1,"time":45],
        ["id":14,"name":"free_45p_2md_2mu","md":2,"mu":2,"time":45],
        ["id":15,"name":"free_45p_3md_1mu","md":3,"mu":1,"time":45],
        ["id":16,"name":"free_45p_3md_2mu","md":3,"mu":2,"time":45],
        ["id":17,"name":"free_45p_5md_2mu","md":5,"mu":2,"time":45],
        ["id":18,"name":"free_45p_5md_3mu","md":5,"mu":3,"time":45],
        ["id":19,"name":"free_60p_2md_1mu","md":2,"mu":1,"time":60],
        ["id":20,"name":"free_60p_2md_2mu","md":2,"mu":2,"time":60],
        ["id":21,"name":"free_60p_3md_1mu","md":3,"mu":1,"time":60],
        ["id":22,"name":"free_60p_3md_2mu","md":3,"mu":2,"time":60],
        ["id":23,"name":"free_60p_5md_2mu","md":5,"mu":2,"time":60],
        ["id":24,"name":"free_60p_5md_3mu","md":5,"mu":3,"time":60]
    ]
    
    public let manager = ConfigurationManager()
    
    public override func componentType() -> ComponentType {
        return .Session
    }
    override init() {
        manager.load(.commandLineArguments)
    }
    public override func loadConfig() {
        
    }
    public override func start() {
        
    }
}
