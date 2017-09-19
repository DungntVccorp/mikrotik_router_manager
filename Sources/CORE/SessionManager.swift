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
    
    var profiles : Dictionary<String,Dictionary<String,Any>> = [
        "0":["id":0,"name":"free_test_1p_2md_2mu","md":2048,"mu":2048,"time":1],
        
        "1":["id":1,"name":"free_15p_2md_512kmu","md":2048,"mu":512,"time":15],
        "3":["id":3,"name":"free_15p_3md_640kmu","md":3072,"mu":640,"time":15],
        "5":["id":5,"name":"free_15p_5md_1mu","md":5 * 1024,"mu":1024,"time":15],
        
        "7":["id":7,"name":"free_30p_2md_512kmu","md":2048,"mu":512,"time":30],
        "9":["id":9,"name":"free_30p_3md_640kmu","md":3072,"mu":640,"time":30],
        "11":["id":11,"name":"free_30p_5md_1mu","md":5 * 1024,"mu":1024,"time":30],
        
        "13":["id":13,"name":"free_45p_2md_512kmu","md":2048,"mu":512,"time":45],
        "15":["id":15,"name":"free_45p_3md_640kmu","md":3072,"mu":640,"time":45],
        "17":["id":17,"name":"free_45p_5md_1mu","md":5 * 1024,"mu":1024,"time":45],
        
        "19":["id":19,"name":"free_60p_2md_512kmu","md":2048,"mu":512,"time":60],  // 1h
        "21":["id":21,"name":"free_60p_3md_640kmu","md":3072,"mu":640,"time":60],
        "23":["id":23,"name":"free_60p_5md_1mu","md":5 * 1024,"mu":1024,"time":60],
        
        "25":["id":25,"name":"package_1d_5md_1mu","md":5 * 1024,"mu":1024,"time":1440], // 1 day
        "27":["id":27,"name":"package_1d_9md_1.3mu","md":9 * 1024,"mu":1331,"time":1440],
        "29":["id":29,"name":"package_1d_15md_2.2mu","md":15 * 1024,"mu":2191,"time":1440],
        "30":["id":30,"name":"package_1d_20md_2.8mu","md":20 * 1024,"mu":2918,"time":1440]
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
