//
//  GetListHospot.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/26/17.
//
//

import Foundation
public class GetListHospot: GetBaseOperation {
    public override func apiString() -> String {
        return "/ip/hotspot/getall"
    }
    public override func onReply(isSuccess: Bool, error: MikrotikConnectionError?, response: Sentence?) {
        if isSuccess {
            self._onSuccess?(response?.SentenceData)
        }else{
            self._onFailure?(error)
        }
    }
}
