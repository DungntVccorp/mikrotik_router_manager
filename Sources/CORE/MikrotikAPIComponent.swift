//
//  MikrotikAPIComponent.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/21/17.
//
//

import Foundation

public class MikrotikAPIComponent : BaseComponent{
    
    public override func componentType() -> ComponentType {
        return ComponentType.MikrotikAPI
    }
    public override func loadConfig() {
        config()
    }
    public override func start() {
        
    }
    
}
