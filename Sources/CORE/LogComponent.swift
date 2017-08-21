//
//  LogComponent.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/21/17.
//
//

import Foundation
import HeliumLogger
import LoggerAPI
class LogComponent : BaseComponent{
    
    override func componentType() -> ComponentType {
        return .Logging
    }
    override func loadConfig() {
        HeliumLogger.use()
    }
    override func start() {
        Log.info("")
    }
}
