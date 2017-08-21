//
//  EngineConfig.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/21/17.
//
//

import Foundation

extension Engine{ /// extension register
    func loadConfig(){
        registerComponent(component: LogComponent())
        registerComponent(component: MikrotikAPIComponent())
        registerComponent(component: OperationManager())
        
    }
}


public extension Engine{ /// extension get component
    public func mikrotikAPI() -> MikrotikAPIComponent?{
        if let com = self.getComponent(type: ComponentType.MikrotikAPI) as? MikrotikAPIComponent{
            return com
        }
        return nil
    }
    public func operationManager() -> OperationManager?{
        if let op = self.getComponent(type: ComponentType.Operation) as? OperationManager{
            return op
        }
        return nil
    }
}

