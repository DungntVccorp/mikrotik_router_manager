//
//  RemoveHotspotUser.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/23/17.
//
//

import Foundation
public class RemoveHotspotUser: RemoveBaseOperation {
    public override func apiString() -> String {
        return "/ip/hotspot/user/remove"
    }
    public override func toRouter() -> MikrotikRouter? {
        return MikrotikRouter("admin", "123456", "10.3.2.149")
    }
    public override func uidString() -> String? {
        return "*3"
    }
    public override func onReply(isSuccess: Bool, error: MikrotikConnectionError?, response: Sentence?) {
        if isSuccess {
            print("SUCCESS \(response?.returnType)")
        }else{
            print("ERROR")
        }
    }
}
