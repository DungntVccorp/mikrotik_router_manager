//
//  AddUsermanUserActivateProfile.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/28/17.
//
//

import Foundation
public class AddUsermanUserActivateProfile : AddBaseOperation{
    public var number : String = ""
    public override func apiString() -> String {
        return "/tool/user-manager/user/create-and-activate-profile"
    }
    public override func params() -> Dictionary<String, String>? {
        return ["profile":"5M","customer":"admin","numbers":number]
    }
}
