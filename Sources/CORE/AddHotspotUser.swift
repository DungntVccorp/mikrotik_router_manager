//
//  AddHotspotUser.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/23/17.
//
//

import Foundation
public class AddHotspotUser : AddBaseOperation{
    public override func apiString() -> String {
        return "/ip/hotspot/user/add"
    }
    public override func toRouter() -> MikrotikRouter? {
        return MikrotikRouter("admin", "123456", "10.3.2.149")
    }
    public override func params() -> Dictionary<String, String>? {
        return ["name":UUID().uuidString,"password":UUID().uuidString,"profile":"default"]
    }
    public override func onReply(isSuccess: Bool, error: MikrotikConnectionError?, response: Sentence?) {
        if isSuccess {
            print("SUCCESS \(response?.returnType)")
        }else{
            print("ERROR")
        }
    }
    
}
