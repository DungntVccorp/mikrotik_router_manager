//
//  RemoveBaseOperation.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/22/17.
//
//

import Foundation
public class RemoveBaseOperation : BaseMikrotikApiOperation{
    public override func apiType() -> ApiType {
        return .DEL
    }
    
}
