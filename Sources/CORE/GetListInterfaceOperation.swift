//
//  GetListInterfaceOperation.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/21/17.
//
//

import Foundation
public class GetListInterfaceOperation : BaseMikrotikApiOperation{
    public override func apiString() -> String {
        //return "/interface/set"
        return "/ip/hotspot/user/print"
    }
    
    public override func toRouter() -> MikrotikRouter? {
        return MikrotikRouter("admin", "123456", "10.3.2.88")
    }
}
