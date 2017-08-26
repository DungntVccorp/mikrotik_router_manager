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
    public override func params() -> Dictionary<String, String>? {
        return ["name":UUID().uuidString,"password":UUID().uuidString,"profile":"default"]
    }
    public override func onReply(isSuccess: Bool, error: Error?, response: Sentence?) {
        if isSuccess {
            print("SUCCESS \(response?.returnType)")
        }else{
            print("ERROR")
        }
    }
    
}
