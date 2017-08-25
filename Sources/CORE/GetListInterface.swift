//
//  GetListInterface.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/23/17.
//
//

import Foundation
public class GetListInterface : GetBaseOperation{
    public override func apiString() -> String {
        return "/ip/hotspot/user/getall"
    }
    public override func toRouter() -> MikrotikRouter? {
        return MikrotikRouter("admin", "123456", "10.3.2.113")
    }
    public override func queryParam() -> Dictionary<String, String>? {
        return nil//[".id":"*2"]
    }
    public override func onReply(isSuccess: Bool, error: MikrotikConnectionError?, response: Sentence?) {
        if isSuccess {
            self._onSuccess?(response?.SentenceData)
        }else{
            self._onFailure?(error)
        }
    }
}
