//
//  tcp_connection.swift
//  MK_API
//
//  Created by dung.nt on 8/14/17.
//
//

import Foundation
import Socket
import Dispatch
import CryptoSwift

class tcp_connection {
    
    var host : String!
    var port : Int!
    var userName : String!
    var password : String!
    var currentTag : Int = 0
    var loginTagStep1 : Int = -1
    var loginTagStep2 : Int = -1
    
    var tcpSocket : Socket!
    private var queue : DispatchQueue!
    convenience init(host : String,port : Int,userName : String,password : String) {
        self.init()
        self.host = host
        self.port = port
        self.userName = userName
        self.password = password
        self.connect_server()
    }
    func getNextTag() -> Int{
        self.currentTag = self.currentTag + 1
        return self.currentTag
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
    
    
    func send(word : String,endsentence : Bool){
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
            }catch{
                print("LOI")
            }
            
        }
        
    }
    
    
    func loginS1(){
        print("SEND LOGIN")
            //tag
            self.loginTagStep1 = self.getNextTag()
            self.send(word: "/login",endsentence: false)
            self.send(word: ".tag=\(self.loginTagStep1)",endsentence: true)
        
    }
    func loginS2(msg : ProtocolMessage){
        print("LOGIN STEP 2")
        var chal = self.hexStringToBytes("00")!
        chal = chal + password.data(using: String.Encoding.ascii)!.bytes
        chal = chal + self.hexStringToBytes(msg.parameter["hash"]!)!
        chal = chal.md5()
        self.send(word: "/login",endsentence: false)
        self.loginTagStep2 = self.getNextTag()
        self.send(word: ".tag=\(self.loginTagStep2)",endsentence: false)
        self.send(word: "=name=admin",endsentence: false)
        print("=response=00\(chal.toHexString())")
        self.send(word: "=response=00\(chal.toHexString())",endsentence: true)
    }
    func loginFinish(){
        print("LOGIN FINISH")
        self.test()
    }
    func loginError(){
        print("LOGIN ERROR")
    }
    
    func test(){
        let tag = self.getNextTag()
        self.send(word: "/ip/service/print", endsentence: false)
        self.send(word: ".tag=\(tag)",endsentence: true)
    }
    

    func readLen(data : Data) -> (Int , Int){ // number byte len , len
        if(data[0] > 0){
            if (data[0] & 0x80) == 0 {
                return (1,Int(data[0]))
            }else if ((data[0] & 0xC0) == 0x80) {
                var len = data[0] & ~0xC0
                len = (len << 8) | data[1]
                print(len)
                return (2,Int(len))
            }else if ((data[0] & 0xE0) == 0xC0) {
                
            }
        }else if(data[0] == 0 && data.count > 1){
            print("Còn dữ liệu")
            if (data[1] & 0x80) == 0 {
                return (2,Int(data[1]))
            }else if ((data[1] & 0xC0) == 0x80) {
                var len = data[1] & ~0xC0
                len = (len << 8) | data[1]
                return (3,Int(len))
            }else if ((data[1] & 0xE0) == 0xC0) {
                
            }
        }
        return (0,0)
    }
    
    
    func unpackResult(data : Data) -> ProtocolMessage{
        var data = data
        var len = self.readLen(data: data)
        var tag : String = ""
        var params = Dictionary<String,String>()
        repeat{
            if (len.0 + len.1) <= data.count {
                let strContent = String(data: data.subdata(in: len.0..<(len.0 + len.1)), encoding: String.Encoding.utf8)
                if strContent?.hasPrefix(".tag=") == true {
                    if let tag_ = strContent?.components(separatedBy: "=").last{
                        tag = tag_
                    }
                }
                else{
                    let split = strContent?.components(separatedBy: "=")
                    if split?.count != nil && split?.count == 3 {
                        params[split![1]] = split![2]
                    }
                }
                
                data = data.subdata(in: (len.0 + len.1)..<data.count)
                len = self.readLen(data: data)
            }else{
                len = (0,0)
            }
        }while len.1 != 0
        let msg =  ProtocolMessage()
        msg.tag = tag
        msg.type = .TRAP
        msg.parameter = params
        return msg
    }
    
    
    func unpackDone( data : Data) -> ProtocolMessage?{
        var data = data
        var len = self.readLen(data: data)
        var tag : String = ""
        var hash : String = ""
        
        repeat{
            if (len.0 + len.1) <= data.count {
                let strContent = String(data: data.subdata(in: len.0..<(len.0 + len.1)), encoding: String.Encoding.utf8)
                if strContent?.hasPrefix(".tag=") == true {
                    if let tag_ = strContent?.components(separatedBy: "=").last{
                        tag = tag_
                    }
                }
                else if strContent?.hasPrefix("=ret") == true{
                    if let hash_ = strContent?.components(separatedBy: "=").last{
                        hash = hash_
                    }
                }
                data = data.subdata(in: (len.0 + len.1)..<data.count)
                len = self.readLen(data: data)
            }
            else{
                len = (0,0)
            }
        }while len.1 != 0
        
        let msg =  ProtocolMessage()
        msg.tag = tag
        msg.parameter = ["hash":hash]
        return msg
    }
    func unpackTrap(data : Data) -> ProtocolMessage?{
        var data = data
        var len = self.readLen(data: data)
        var tag : String = ""
        var params = Dictionary<String,String>()
        repeat{
            if (len.0 + len.1) <= data.count {
                let strContent = String(data: data.subdata(in: len.0..<(len.0 + len.1)), encoding: String.Encoding.utf8)
                if strContent?.hasPrefix(".tag=") == true {
                    if let tag_ = strContent?.components(separatedBy: "=").last{
                        tag = tag_
                    }
                }
                else{
                    let split = strContent?.components(separatedBy: "=")
                    if split?.count != nil && split?.count == 3 {
                        params[split![1]] = split![2]
                    }
                }
                
                data = data.subdata(in: (len.0 + len.1)..<data.count)
                len = self.readLen(data: data)
            }else{
                len = (0,0)
            }
        }while len.1 != 0
        let msg =  ProtocolMessage()
        msg.tag = tag
        msg.type = .TRAP
        msg.parameter = params
        return msg
    }
    
    func unpack(data : Data){
        queue.sync {
            let len = self.readLen(data: data)
            var msg : ProtocolMessage? = nil
            if (len.0 + len.1) <= data.count {
                let subData = data.subdata(in: len.0..<(len.0 + len.1))
                let type = String(data: subData, encoding: String.Encoding.utf8)
                if "!re" == type{
                    msg = self.unpackResult(data: data.subdata(in: (len.0 + len.1)..<data.count))
                }else if "!done" == type{
                    msg = self.unpackDone(data: data.subdata(in: (len.0 + len.1)..<data.count))
                }else if "!trap" == type{
                    msg = self.unpackTrap(data: data.subdata(in: (len.0 + len.1)..<data.count))
                }else if "!halt" == type{
                    
                }else if "" == type{
                    
                }
                
            }
            if msg != nil{
                /// GOI OP
                DispatchQueue.main.async {
                    /// NEXT
                    if("\(self.loginTagStep1)" == msg!.tag){
                        self.loginS2(msg: msg!)
                    }else  if("\(self.loginTagStep2)" == msg!.tag){
                        if(msg?.type == .DONE){
                            self.loginFinish()
                        }else if(msg?.type == .TRAP){
                            self.loginError()
                        }
                    }else{
                        print(msg?.parameter)
                    }
                    
                }
            }
        }
    }
    
    
    func connect_server(){
        queue = DispatchQueue.global(qos: .userInteractive)
        queue.async {[unowned self] in
            do{
                self.tcpSocket = try Socket.create()
                try self.tcpSocket.connect(to: self.host, port: Int32(self.port))
                self.tcpSocket.readBufferSize = 4096
                self.loginS1()
                var bufferData = Data()
                var shouldKeepRunning : Bool = true
                
                repeat{
               
                
                    let bytesRead = try self.tcpSocket.read(into: &bufferData)
                    if(bytesRead > 0){
                        print("DID READ \(bytesRead) BYTE DATA")
                        print(String(data: bufferData, encoding: String.Encoding.utf8))
                        self.unpack(data: bufferData)
                        bufferData.removeAll()
                    }
                    if bytesRead == 0{
                        shouldKeepRunning = false
                    }
                }while shouldKeepRunning
                
            }catch{
                print("ERROR")
            }
        }
    }
    
    
}
