//
//  ProtocolMessage.swift
//  MK_API
//
//  Created by dung.nt on 8/18/17.
//
//

import Foundation

class ProtocolMessage{
    enum MessageType {
        case DONE
        case TRAP
        case HALT
        case RE
    }
    var type : MessageType = .DONE
    var tag : String!
    var parameter : Dictionary<String,String>!
}
