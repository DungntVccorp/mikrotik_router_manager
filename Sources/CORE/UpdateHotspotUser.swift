//
//  UpdateHotspotUser.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/23/17.
//
//

import Foundation
public class UpdateHotspotUser : UpdateBaseOperation{
    public override func apiString() -> String {
        return "/ip/hotspot/user/set"
    }
    public override func uidString() -> String? {
        return "*2"
    }
    public override func params() -> Dictionary<String, String>? {
        return ["disabled":"true"]
    }
    public override func onReply(isSuccess: Bool, error: Error?, response: Sentence?) {
        if isSuccess {
            print("SUCCESS \(response?.returnType) \(response?.SentenceData)")
        }else{
            print("ERROR")
        }
    }
}
