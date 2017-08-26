//
//  MikrotikConnection.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/21/17.
//
//

import Foundation
import Socket
import CryptoSwift

public enum ReturnType {
    case NONE
    case DONE
    case TRAP
    case HALT
    case RE
}
public enum SentenceError : Error{
    case NoData
    case DataFailure
    case DataInvalidFormat
}
public enum MikrotikConnectionError : Error{
    case LOGIN
    case API
    case MISSING_PARAM
    case UNKNOW
}

public class Sentence{
    
    
    
    var returnType : ReturnType = .NONE /// 0 = NONE
    var SentenceData = Array<Dictionary<String,String>>()
    var isDone : Bool = false
    private var oldData : Data!
    func ReadLength(data : Data) -> (Int,Int){ /// LEN - SIZE
        if data.count < 1 {
            return (-1,0)
        }
        let firstChar = data[0]
        if (firstChar & 0xE0) == 0xE0 {
            
        }else if (firstChar & 0xC0) == 0xC0 {
            
        }else if (firstChar & 0x80) == 0x80 { // 2-byte encoded length
            var c = Int(firstChar)
             c = c & ~0xC0;
             c = (c << 8) | Int(data[1])
            return (c,2)
        }else { // assume 1-byte encoded length...same on both LE and BE systems
            return (Int(firstChar),1)
        }
        return (-1,0)
    }
    
    init(data : Data) throws {
        
        guard data.count > 3 else {
            throw SentenceError.NoData
        }
        let len = self.ReadLength(data: data)
        guard len.0 > 0 else {
            throw SentenceError.DataInvalidFormat
        }
        let typeData = data.subdata(in: len.1..<len.0+len.1)
        let strType = String(data: typeData, encoding: String.Encoding.utf8)
        guard strType != nil else {
            throw SentenceError.DataInvalidFormat
        }
        if strType! == "!done" {
            self.returnType = .DONE
            isDone = true
            self.unPackDone(data: data.subdata(in: len.0+len.1..<data.count))
        }else if strType == "!trap"{
            self.returnType = .TRAP
            isDone = true
            self.unPackTrap(data: data.subdata(in: len.0+len.1..<data.count))
        }else if strType == "!re"{
            self.returnType = .RE
            SentenceData.append([:])
            self.unPackRe(data: data.subdata(in: len.0+len.1..<data.count))
        }
        
    }
    func updateData(data : Data){
        if oldData != nil {
            oldData.append(data)
            self.unPackRe(data: oldData)
            oldData = nil
        }else{
            self.unPackRe(data: data)
        }
    }
    
    func unPackDone(data : Data){
        let len = self.ReadLength(data: data)
        if len.0 > 0 {
            let contentData = data.subdata(in: len.1..<len.0+len.1)
            if let strContent = String(data: contentData, encoding: String.Encoding.utf8){
                let arr = strContent.components(separatedBy: "=")
                if arr.count == 3 {
                    var dic = Dictionary<String,String>()
                    dic[arr[1]] = arr[2]
                    SentenceData.append(dic)
                }
            }
            self.unPackDone(data: data.subdata(in: len.0+len.1..<data.count))
        }
    }
    
    func unPackTrap(data : Data){
        let len = self.ReadLength(data: data)
        if len.0 > 0 {
            let contentData = data.subdata(in: len.1..<len.0+len.1)
            if let strContent = String(data: contentData, encoding: String.Encoding.ascii){
                let arr = strContent.components(separatedBy: "=")
                if arr.count == 3 {
                    var dic = Dictionary<String,String>()
                    dic[arr[1]] = arr[2]
                    SentenceData.append(dic)
                }
            }
            self.unPackTrap(data: data.subdata(in: len.0+len.1..<data.count))
        }
    }
    
    func unPackRe(data : Data){
        let len = self.ReadLength(data: data)
        if len.0 < 0 {
            return
        }
        if data.count < len.1 || data.count < len.0 + len.1 {
            oldData = data
            return // dư data
        }
        let contentData = data.subdata(in: len.1..<len.0+len.1)
        if let strContent = String(data: contentData, encoding: String.Encoding.utf8){
            if strContent.isEmpty == false {
                if strContent == "!re" {
                    SentenceData.append([:])
                }else{
                    if strContent != "!done" {
                        let arr = strContent.components(separatedBy: "=")
                        if arr.count == 3 {
                            SentenceData[SentenceData.count - 1][arr[1]] = arr[2]
                        }
                        
                    }
                }
                //SentenceData.append(strContent)
            }
            if strContent != "!done" {
                self.unPackRe(data: data.subdata(in: len.0+len.1..<data.count))
            }else{
                isDone = true
            }
            
        }
        
    }
    
}


class MikrotikConnection{
    var userName : String!
    var password : String!
    var hostName : String!
    var hostPort : Int = 0
    var tcpSocket : Socket!
    
    init(host : String,port : Int,userName : String,password : String) {
        self.userName = userName
        self.password = password
        self.hostName = host
        self.hostPort = port
    }
    
    func send(word : String,endsentence : Bool) -> Bool{
        if word.isEmpty {
            if endsentence {
                do{
                    try self.tcpSocket.write(from: Data(bytes: [0x0]))
                }catch{
                    return false
                }
            }
            return true
        }else{
            if let data = word.data(using: String.Encoding.utf8){
                var len = data.count
                do{
                    
                    if len < 0x80 {
                        var data = Data()
                        data.append([UInt8(len)], count: 1)
                        try self.tcpSocket.write(from: data)
                    }else if len < 0x4000 {
                        len = len | 0x8000;
                        try self.tcpSocket.write(from: Data(bytes: [UInt8(len >> 8)]))
                        try self.tcpSocket.write(from: Data(bytes: [UInt8(len)]))
                    }else if len < 0x20000 {
                        len = len | 0xC00000;
                        try self.tcpSocket.write(from: Data(bytes: [UInt8(len >> 16)]))
                        try self.tcpSocket.write(from: Data(bytes: [UInt8(len >> 8)]))
                        try self.tcpSocket.write(from: Data(bytes: [UInt8(len)]))
                    }
                    else if len < 0x10000000 {
                        len = len | 0xE0000000;
                        try self.tcpSocket.write(from: Data(bytes: [UInt8(len >> 24)]))
                        try self.tcpSocket.write(from: Data(bytes: [UInt8(len >> 16)]))
                        try self.tcpSocket.write(from: Data(bytes: [UInt8(len >> 8)]))
                        try self.tcpSocket.write(from: Data(bytes: [UInt8(len)]))
                    }else{
                        try self.tcpSocket.write(from: Data(bytes: [0xF0]))
                        try self.tcpSocket.write(from: Data(bytes: [UInt8(len >> 24)]))
                        try self.tcpSocket.write(from: Data(bytes: [UInt8(len >> 16)]))
                        try self.tcpSocket.write(from: Data(bytes: [UInt8(len >> 8)]))
                        try self.tcpSocket.write(from: Data(bytes: [UInt8(len)]))
                    }
                    try self.tcpSocket.write(from: data)
                    if endsentence {
                        try self.tcpSocket.write(from: Data(bytes: [0x0]))
                    }
                    return true
                }catch{
                    return false
                }
                
            }
        }
        return false
    }
    func sendAPI(api : String , params : Dictionary<String,String>? = nil,apiType : ApiType = .GET,querys : Dictionary<String,String>? = nil,uid : String? = nil) -> (Bool,Error?,Sentence?){ // ISSUCCESS - ERROR - Sentence
        do {
            tcpSocket = try Socket.create()
            tcpSocket.readBufferSize = 4096
            try tcpSocket.connect(to: self.hostName, port: Int32(self.hostPort), timeout: 2000)
            /// SEND GET TOKEN
            var success : Bool = false
            success =  self.send(word: "/login", endsentence: true)
            guard success == true else {
                tcpSocket.close()
                return (false,MikrotikConnectionError.LOGIN,nil)
            }
            /// READ TOKEN
            var data : Data = Data()
            var lenRead =  try tcpSocket.read(into: &data)
            guard lenRead > 0 else {
                tcpSocket.close()
                return (false,MikrotikConnectionError.LOGIN,nil)
            }
            /// read type
            let sentence = try Sentence(data: data)
            guard sentence.returnType == .DONE else {
                tcpSocket.close()
                return (false,MikrotikConnectionError.LOGIN,nil)
            }
            /// SEND LOGIN
            success =  self.send(word: "/login", endsentence: false)
            guard success == true && self.userName != nil else {
                tcpSocket.close()
                return (false,MikrotikConnectionError.LOGIN,nil)
            }
            success = self.send(word: "=name=\(self.userName!)",endsentence: false)
            guard success == true && sentence.SentenceData.count == 1 else {
                tcpSocket.close()
                return (false,MikrotikConnectionError.LOGIN,nil)
            }
            
            
            
            var chal = self.hexStringToBytes("00")!
            chal = chal + password.data(using: String.Encoding.ascii)!.bytes
            chal = chal + self.hexStringToBytes(sentence.SentenceData[0]["ret"]!)!
            chal = chal.md5()
            success = self.send(word: "=response=00\(chal.toHexString())",endsentence: true)
            guard success == true && sentence.SentenceData.count == 1 else {
                tcpSocket.close()
                return (false,MikrotikConnectionError.LOGIN,nil)
            }
            data.removeAll()
            lenRead = 0
            lenRead =  try tcpSocket.read(into: &data)
            guard lenRead > 0 else {
                tcpSocket.close()
                return (false,MikrotikConnectionError.LOGIN,nil)
            }
            let sentenceLoginS2 = try Sentence(data: data)
            guard sentenceLoginS2.returnType == .DONE else {
                tcpSocket.close()
                return (false,MikrotikConnectionError.LOGIN,nil)
            }
            /// send abc
            
            if apiType == .GET {
                success = self.send(word: api, endsentence:false)
                guard success == true else {
                    tcpSocket.close()
                    return (false,MikrotikConnectionError.API,nil)
                }
                success = self.send(word: "=detail=", endsentence:false)
                guard success == true else {
                    tcpSocket.close()
                    return (false,MikrotikConnectionError.API,nil)
                }
                if querys != nil {
                    var i = 0
                    for p in querys! {
                        i = i + 1
                        success = self.send(word: "?\(p.key)=\(p.value)", endsentence: false)
                        guard success == true else {
                            tcpSocket.close()
                            return (false,MikrotikConnectionError.API,nil)
                            
                        }
                    }
                }
                success = self.send(word: "", endsentence: true)
                
                guard success == true else {
                    tcpSocket.close()
                    return (false,MikrotikConnectionError.API,nil)
                }
                
                var sentenceData : Sentence!
                repeat{
                    data.removeAll()
                    lenRead = 0
                    lenRead =  try tcpSocket.read(into: &data)
                    if sentenceData == nil {
                        sentenceData = try Sentence(data: data)
                    }
                    else{
                        sentenceData.updateData(data: data)
                    }
                }while !sentenceData.isDone
                
                
                tcpSocket.close()
                return (true,nil,sentenceData)
            }else if apiType == .SET{
                if params == nil || uid == nil {
                    return (false,MikrotikConnectionError.MISSING_PARAM,nil)
                }
                success = self.send(word: api, endsentence:false)
                guard success == true else {
                    tcpSocket.close()
                    return (false,MikrotikConnectionError.API,nil)
                }
                success = self.send(word: "=.id=\(uid!)", endsentence:false)
                guard success == true else {
                    tcpSocket.close()
                    return (false,MikrotikConnectionError.API,nil)
                }
                
                
                if params != nil {
                    var i = 0
                    for p in params! {
                        i = i + 1
                        success = self.send(word: "=\(p.key)=\(p.value)", endsentence: false)
                        guard success == true else {
                            tcpSocket.close()
                            return (false,MikrotikConnectionError.API,nil)
                            
                        }
                    }
                }
                success = self.send(word: "", endsentence: true)
                
                guard success == true else {
                    tcpSocket.close()
                    return (false,MikrotikConnectionError.API,nil)
                }
                
                var sentenceData : Sentence!
                repeat{
                    data.removeAll()
                    lenRead = 0
                    lenRead =  try tcpSocket.read(into: &data)
                    if sentenceData == nil {
                        sentenceData = try Sentence(data: data)
                    }
                    else{
                        sentenceData.updateData(data: data)
                    }
                }while !sentenceData.isDone
                
                
                tcpSocket.close()
                return (true,nil,sentenceData)
                
                
            }else if apiType == .ADD{
                if params == nil {
                    return (false,MikrotikConnectionError.MISSING_PARAM,nil)
                }
                success = self.send(word: api, endsentence:false)
                guard success == true else {
                    tcpSocket.close()
                    return (false,MikrotikConnectionError.API,nil)
                }
                if params != nil {
                    var i = 0
                    for p in params! {
                        i = i + 1
                        success = self.send(word: "=\(p.key)=\(p.value)", endsentence: false)
                        guard success == true else {
                            tcpSocket.close()
                            return (false,MikrotikConnectionError.API,nil)
                            
                        }
                    }
                }
                success = self.send(word: "", endsentence: true)
                
                guard success == true else {
                    tcpSocket.close()
                    return (false,MikrotikConnectionError.API,nil)
                }
                
                var sentenceData : Sentence!
                repeat{
                    data.removeAll()
                    lenRead = 0
                    lenRead =  try tcpSocket.read(into: &data)
                    if sentenceData == nil {
                        sentenceData = try Sentence(data: data)
                    }
                    else{
                        sentenceData.updateData(data: data)
                    }
                }while !sentenceData.isDone
                
                
                tcpSocket.close()
                return (true,nil,sentenceData)
                
            }else{ // DELETE
                if uid == nil {
                    return (false,MikrotikConnectionError.MISSING_PARAM,nil)
                }
                success = self.send(word: api, endsentence:false)
                guard success == true else {
                    tcpSocket.close()
                    return (false,MikrotikConnectionError.API,nil)
                }
                success = self.send(word: "=.id=\(uid!)", endsentence:true)
                guard success == true else {
                    tcpSocket.close()
                    return (false,MikrotikConnectionError.API,nil)
                }
                var sentenceData : Sentence!
                repeat{
                    data.removeAll()
                    lenRead = 0
                    lenRead =  try tcpSocket.read(into: &data)
                    if sentenceData == nil {
                        sentenceData = try Sentence(data: data)
                    }
                    else{
                        sentenceData.updateData(data: data)
                    }
                }while !sentenceData.isDone
                
                
                tcpSocket.close()
                return (true,nil,sentenceData)
            }
            
        } catch  {
            return (false,error,nil)
        }
    }
    
    func hexStringToBytes(_ string: String) -> [UInt8]? {
        let length = string.characters.count
        if length & 1 != 0 {
            return nil
        }
        var bytes = [UInt8]()
        bytes.reserveCapacity(length/2)
        var index = string.startIndex
        for _ in 0..<length/2 {
            let nextIndex = string.index(index, offsetBy: 2)
            if let b = UInt8(string[index..<nextIndex], radix: 16) {
                bytes.append(b)
            } else {
                return nil
            }
            index = nextIndex
        }
        return bytes
    }
}
