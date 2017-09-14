//
//  BaseComponent.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/21/17.
//
//

import Foundation

public enum ComponentType {
    case None
    case MikrotikAPI
    case DataBase
    case HttpServer
    case Operation
    case Logging
    case Session
    case DataStoreFile
}
public class BaseComponent {
    
    public func componentType() -> ComponentType{
        return .None
    }
   
    public func loadConfig(){
        
    }
    public func start(){
        
    }
}
