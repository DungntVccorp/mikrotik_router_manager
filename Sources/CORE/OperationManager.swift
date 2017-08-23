//
//  OperationManager.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/21/17.
//
//

import Foundation
public class OperationManager : BaseComponent{
    let operationQueue: OperationQueue = OperationQueue()
    
    public override func componentType() -> ComponentType {
        return .Operation
    }
    public override func loadConfig() {
        self.operationQueue.maxConcurrentOperationCount = 1//OperationQueue.defaultMaxConcurrentOperationCount
        self.operationQueue.qualityOfService = .default
    }
    public override func start() {
        
    }
    public func enqueue(operation:BaseOperation) {
        self.operationQueue.addOperation(operation)
    }
}
