//
//  AddBaseOperation.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/22/17.
//
//

import Foundation
public class AddBaseOperation: BaseMikrotikApiOperation {
    override public func apiType() -> ApiType {
        return .ADD
    }
}
