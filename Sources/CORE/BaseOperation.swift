//
//  BaseOperation.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/21/17.
//
//

import Foundation
import LoggerAPI
public class BaseOperation : Operation{
    
    public func fire(){
        Engine.sharedInstance.operationManager()?.enqueue(operation: self)
    }
    public override init() {
        super.init()
    }
    
    public override func main() {

        Log.info("MAIN RUNNING")
        
    }
    
    
    
}
