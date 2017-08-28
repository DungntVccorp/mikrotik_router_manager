//
//  AddUsermanUser.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/28/17.
//
//

import Foundation
public class AddUsermanUser : AddBaseOperation{
    
    public var user_id : String = ""
    public var password : String = ""
    
    public override func apiString() -> String {
        return "/tool/user-manager/user/add"
    }
    public override func params() -> Dictionary<String, String>? {
        return ["username":user_id,"password":password,"customer":"admin","disabled":"no","shared-users":"1"]
    }
    
}
