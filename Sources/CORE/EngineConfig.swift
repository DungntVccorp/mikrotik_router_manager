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
        registerComponent(component: SessionManager())
        registerComponent(component: LogComponent())
        registerComponent(component: OperationManager())
        registerComponent(component: HttpServerComponent())
        registerComponent(component: MysqlConnection())
    }
    public func operationManager() -> OperationManager?{
        if let op = self.getComponent(type: ComponentType.Operation) as? OperationManager{
            return op
        }
        return nil
    }
}
public extension Engine{ /// extension get component
    public func mySQLConnection() -> MysqlConnection?{
        if let op = self.getComponent(type: ComponentType.DataBase) as? MysqlConnection{
            return op
        }
        return nil
    }
    public func Session() -> SessionManager?{
        if let op = self.getComponent(type: ComponentType.Session) as? SessionManager{
            return op
        }
        return nil
    }
}
