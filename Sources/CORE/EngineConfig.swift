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
        registerComponent(component: OperationManager())
        registerComponent(component: HttpServerComponent())
    }
    public func operationManager() -> OperationManager?{
        if let op = self.getComponent(type: ComponentType.Operation) as? OperationManager{
            return op
        }
        return nil
    }
}
public extension Engine{ /// extension get component
    
}

