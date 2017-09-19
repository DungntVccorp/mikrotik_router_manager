//
//  HtttpRouterAPI.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/25/17.
//
//

import Foundation


extension HttpServerComponent{
    //// ----------------------------------------- API ROUTER -------------------------------------------------///
    /// GET LIST ROUTER
    func routerAPI(){
        let api = "/api/router"
        router.get(api) { (routerRequest, routerResponse, next) in
            do{
                try Engine.sharedInstance.mySQLConnection()?.execute("select * from tbl_router ORDER BY id desc", onCompletion: { (results) in
                    if(results.success){
                        routerResponse.send(json: ["status":200,"data":results.asRows!])
                    }else{
                        routerResponse.send(json: ["status":400,"message":"\(results.asError?.localizedDescription ?? "Execute Error")"])
                    }
                })
            }catch{
                routerResponse.send(json: ["status":500,"message":"\(error.localizedDescription)"])
            }
            
            next()
        }
        
        /// DELETE
        router.delete(api) { (routerRequest, routerResponse, next) in
            
            var id_router : String?
            for p in (routerRequest.body?.asMultiPart ?? []){
                if(p.name == "id"){
                    id_router = p.body.asText
                }
            }
            guard id_router != nil else{
                routerResponse.send(json: ["status":400,"message":"missing id_router"])
                next()
                return
            }
            
            
            do{
                try Engine.sharedInstance.mySQLConnection()?.execute("DELETE FROM `tbl_router` WHERE id = \(id_router ?? "")", onCompletion: { (result) in
                    if(result.success){
                        routerResponse.send(json: ["status":200,"message":"\(result.asValue ?? "")"])
                        
                    }else{
                        routerResponse.send(json: ["status":400,"message":"\(result.asError?.localizedDescription ?? "Execute Query Error")"])
                        
                    }
                })
            }catch{
                routerResponse.send(json: ["status":500,"message":"\(error.localizedDescription)"])
            }
            next()
        }
        /// CREATE
        router.post(api) { (routerRequest, routerResponse, next) in
            var user_name : String?
            var password : String?
            var ip_adddress : String?
            var name : String?
            var des : String?
            var port : Int = 8728
            var type : Int = 0
            for p in (routerRequest.body?.asMultiPart ?? []){
                if(p.name == "name"){
                    name = p.body.asText
                }else if p.name == "ip_address" {
                    ip_adddress = p.body.asText
                }else if p.name == "username"{
                    user_name = p.body.asText
                }else if p.name == "password" {
                    password = p.body.asText
                }else if p.name == "description" {
                    des = p.body.asText
                }else if p.name == "port" {
                    port = Int(p.body.asText ?? "8278")!
                }else if p.name == "type" {
                    type = Int(p.body.asText ?? "0")!
                }
            }
            
            let password_for_radius_login = UUID().uuidString
            
            /// 10.3.3.200 là ip cua router host
            
            /// TODO CHECK ROUTER DA DUOC ADD HAY CHUA
            
            if (user_name != nil && ip_adddress != nil && name != nil && password != nil){
                //// TRƯỜNG HỢP ROUTER LÀM LUÔN HOST RADIUS
                try? Engine.sharedInstance.mySQLConnection()?.execute("select * from `tbl_router` where ip_address = '\(ip_adddress ?? "")'", onCompletion: { (QueryResult) in
                    if(QueryResult.success == true && QueryResult.asRows?.count == 0){
                        let mk =  MikrotikConnection(host: ip_adddress!, port: port, userName: user_name!, password: password!)
                        
                        /// RADIUS SERVER
                        /// 1.0 lấy danh sách radius cũ
                        if (type == 0){
                            let requset = Request(api: "/radius/getall")
                            let result =  mk.sendAPIs(requests: [requset])
                            if result.0 == false {
                                routerResponse.send(json: ["status":400,"message":"\(result.1?.localizedDescription ?? "có thể do lỗi ko lấy được danh sách radius")"])
                                next()
                                return
                            }
                            
                            /// 1.1 Xoá hết danh sách radius cũ
                            for r in result.2 ?? []{
                                for s in r.SentenceData{
                                    if let uid = s[".id"]{
                                        let requset_remove = Request(api: "/radius/remove")
                                        requset_remove.uid = uid
                                        requset_remove.apiType = .DEL
                                        _ = mk.sendAPI2(r: requset_remove)
                                        
                                    }
                                }
                            }
                            
                            /// 1.2 thêm máy chủ radius mới
                            let create_radius_params = ["address":"127.0.0.1","comment":"LOCAL_RADIUS","secret":password_for_radius_login,"service":"hotspot"]
                            let request_create_radius = Request(api: "/radius/add", type: ApiType.ADD, p: create_radius_params, q: nil, u: nil)
                            let rs_create_radius = mk.sendAPI2(r: request_create_radius)
                            if (rs_create_radius.0 == false){
                                routerResponse.send(json: ["status":400,"message":"không tạo được radius"])
                                next()
                                return
                            }
                            
                            let set_enable_incoming = Request(api: "/radius/incoming/set", type: ApiType.SET, p: ["accept":"yes","port":"1700"], q: nil, u: nil)
                            _ = mk.sendAPI2(r: set_enable_incoming)
                            
                            
                            /// b2 add profile and limit cho new router
                            /// b2.1 set path save DB
                            
                            let userman_set_db_path = Request(api: "/tool/user-manager/database/set", type: ApiType.SET, p: ["db-path":"mk/\(UUID().uuidString)/db"], q: nil, u: nil)
                            let rs_userman_set_db_path = mk.sendAPI2(r: userman_set_db_path)
                            
                            if (rs_userman_set_db_path.0 == false){
                                routerResponse.send(json: ["status":400,"message":"userman không khởi tạo được đường dẫn db \(rs_userman_set_db_path.1?.localizedDescription ?? "")"])
                                next()
                                return
                            }
                            /// b2.2 add limit and profile
                            
                            for p in Engine.sharedInstance.getSession()!.profiles{
                                if let name : String = p.value["name"] as? String,let md = p.value["md"] as? Int,let mu = p.value["mu"] as? Int,let time = p.value["time"] as? Int{
                                    //rq profile , profile limitation , profile profile-limitation
                                    let rq_add = Request(api: "/tool/user-manager/profile/add", type: ApiType.ADD, p: ["name":name,"owner":"admin","starts-at":"logon","validity":"\(time * 60)"], q: nil, u: nil)
                                    let rq_add_profile_limitation = Request(api: "/tool/user-manager/profile/limitation/add", type: ApiType.ADD, p: ["name":name,"owner":"admin","uptime-limit":"\(time * 60)","rate-limit-rx":"\(mu * 1024)","rate-limit-tx":"\(md * 1024)","rate-limit-min-rx":"\((mu * 1024) / 2)","rate-limit-min-tx":"\((md * 1024) / 2)"], q: nil, u: nil)
                                    let rq_add_profile_profile_limitation = Request(api: "/tool/user-manager/profile/profile-limitation/add", type: ApiType.ADD, p: ["limitation":name,"profile":name], q: nil, u: nil)
                                    _ = mk.sendAPIs(requests: [rq_add,rq_add_profile_limitation,rq_add_profile_profile_limitation])
                                }
                            }
                            
                            
                            /// LOCAL USERMAN ADD ROUTER
                            /// 3.1 kiểm tra danh sách đã được add xem đã add ip này hay chưa
                            let rq_get_router_in_userman = Request(api: "/tool/user-manager/router/print")
                            let rs_get_router_in_userman = mk.sendAPI2(r: rq_get_router_in_userman)
                            if rs_get_router_in_userman.0 == false {
                                routerResponse.send(json: ["status":400,"message":"lỗi không lấy được thông tin id của rourer được đăng ký trên userman \(rs_get_router_in_userman.1?.localizedDescription ?? "")"])
                                next()
                                return
                            }
                            /// 3.2 xoá nếu tồn tại
                            for s in rs_get_router_in_userman.2?.SentenceData ?? []{
                                if let _ip = s["ip-address"],let uid = s[".id"] {
                                    if ("127.0.0.1" == _ip){
                                        let requset_remove = Request(api: "/tool/user-manager/router/remove")
                                        requset_remove.uid = uid
                                        requset_remove.apiType = .DEL
                                        _ = mk.sendAPI2(r: requset_remove)
                                    }
                                }
                            }
                            
                            
                            
                            /// 3.3 thêm mới router
                            let usernam_add_router_params = ["coa-port":"1700","customer":"admin","disabled":"no","log":"auth-fail","use-coa":"yes","ip-address":"127.0.0.1","shared-secret":password_for_radius_login,"name":"Localhost"]
                            let userman_create_router = Request(api: "/tool/user-manager/router/add", type: ApiType.ADD, p: usernam_add_router_params, q: nil, u: nil)
                            let rs_userman_create_router = mk.sendAPI2(r: userman_create_router)
                            if (rs_userman_create_router.0 == false){
                                routerResponse.send(json: ["status":400,"message":"userman không tạo được router \(rs_userman_create_router.1?.localizedDescription ?? "")"])
                                next()
                                return
                            }
                            
                            /// 4 CONFIG HOTSPOT // DEFAULT ether2
                            
                            /// 4.1 dns --> ip dns set servers=8.8.8.8 allow-remote-requests=yes
                            //let rq_add_dns = Request(api: "/ip/dns/set", type: ApiType.SET, p: ["servers":"8.8.8.8","allow-remote-requests":"yes"], q: nil, u: nil)
                            /// 4.2 create IP address -> ip address add address=192.168.50.1/24 interface=ether2
                            //let rq_cr_ip_add = Request(api: "/ip/address/add", type: ApiType.ADD, p: ["address":"192.168.50.1/24","interface":"ether2"], q: nil, u: nil)
                            /// 4.3 create add pool -> ip pool add name=hotspot-pool ranges=192.168.50.2-192.168.50.254
                            //Request(api: "", type: ApiType.ADD, p: ["":""], q: nil, u: nil)
                            //let rq_cr_pool = Request(api: "/ip/pool/add", type: ApiType.ADD, p: ["name":"hotspot-pool","ranges":"192.168.50.2-192.168.50.254"], q: nil, u: nil)
                            /// 4.4 create dhcp-server network -> ip dhcp-server network add address=192.168.50.0/24 gateway=192.168.50.1 dns-server=8.8.8.8
                            //let rq_cr_dhcp_server_network = Request(api: "/ip/dhcp-server/network/add", type: ApiType.ADD, p: ["address":"192.168.50.0/24","gateway":"192.168.50.1","dns-server":"8.8.8.8"], q: nil, u: nil)
                            /// 4.5 create dhcp-server -> ip dhcp-server add name=dhcp-for-hotspot interface=ether2 lease-time=10m address-pool=hotspot-pool bootp-support=static authoritative=yes  disabled=no
                            //let rq_cr_dhcp_server = Request(api: "/ip/dhcp-server/add", type: ApiType.ADD, p: ["name":"dhcp-for-hotspot","interface":"ether2","lease-time":"10m","address-pool":"hotspot-pool","bootp-support":"static","authoritative":"yes","disabled":"no"], q: nil, u: nil)
                            /// 4.6 add nas cho day ip -> ip firewall nat add chain=srcnat action=masquerade src-address=192.168.50.0/24
                            //let rq_cr_add_nad_ip = Request(api: "/ip/firewall/nat/add", type: ApiType.ADD, p: ["chain":"srcnat","action":"masquerade","src-address":"192.168.50.0/24"], q: nil, u: nil)
                            /// 4.7 create hotspot profile server -> ip hotspot profile add name=hotspot-profile hotspot-address=192.168.50.1 use-radius=no
                            //let rq_cr_add_hotspot_profile = Request(api: "/ip/hotspot/profile/add", type: ApiType.ADD, p: ["name":"hotspot-profile","hotspot-address":"192.168.50.1","use-radius":"yes"], q: nil, u: nil)
                            /// 4.8 create hotspot -> ip hotspot add address-pool=hotspot-pool interface=ether2 profile=hotspot-profile disabled=no name=HOTSPOT
                            //let rq_cr_add_hotspot = Request(api: "/ip/hotspot/add", type: ApiType.ADD, p: ["address-pool":"hotspot-pool","interface":"ether2","profile":"hotspot-profile","disabled":"no","name":"HOTSPOT"], q: nil, u: nil)
                            /// 4.9 mở ip (if use PUBLIC ROUTER ) -> ip hotspot walled-garden ip add action=accept disabled=no dst-address=192.168.70.253 server=!HOTSPOT
                            //_ = mk.sendAPIs(requests: [rq_add_dns,rq_cr_ip_add,rq_cr_pool,rq_cr_dhcp_server_network,rq_cr_dhcp_server,rq_cr_add_nad_ip,rq_cr_add_hotspot_profile,rq_cr_add_hotspot])
                            try? Engine.sharedInstance.mySQLConnection()?.execute("INSERT INTO `tbl_router` (`name`, `username`, `password`, `ip_address`, `description`,`port`,`type`) VALUES ('\(name ?? "")', '\(user_name ?? "")', '\(password ?? "")', '\(ip_adddress ?? "")', '\(des ?? "")', \(port), \(type))", onCompletion: { (results) in
                                if(results.success){
                                    try? Engine.sharedInstance.mySQLConnection()?.execute("select * from `tbl_router` where ip_address = '\(ip_adddress ?? "")'", onCompletion: { (QueryResult) in
                                        
                                        let resultRow = QueryResult.asRows ?? []
                                        if(resultRow.count == 1){
                                            if let _newID = resultRow[0]["id"] as? Int32{
                                                let rq_edit_id = Request(api: "/system/identity/set", type: ApiType.ADD, p: ["name":"\(_newID)"], q: nil, u: nil)
                                                let r = mk.sendAPI2(r: rq_edit_id)
                                                print(r.0)
                                            }
                                        }
                                        
                                        
                                        routerResponse.send(json: ["status":200,"message":"ok","data":resultRow])
                                        next()
                                    })
                                    
                                }else{
                                    routerResponse.send(json: ["status":400,"message":"\(results.asError?.localizedDescription ?? "Unknow error")"])
                                    next()
                                }
                            })
                        }
                        else{
                            /// host radius server public
                            
                            let mk_public = MikrotikConnection(host: Engine.sharedInstance.getSession()!.public_server_radius_ip, port: Engine.sharedInstance.getSession()!.public_server_radius_port, userName: Engine.sharedInstance.getSession()!.public_server_radius_username, password: Engine.sharedInstance.getSession()!.public_server_radius_password)
                            
                            let requset = Request(api: "/radius/getall")
                            let result =  mk.sendAPIs(requests: [requset])
                            if result.0 == false {
                                routerResponse.send(json: ["status":400,"message":"\(result.1?.localizedDescription ?? "có thể do lỗi ko lấy được danh sách radius")"])
                                next()
                                return
                            }
                            
                            /// 1.1 Xoá hết danh sách radius cũ
                            for r in result.2 ?? []{
                                for s in r.SentenceData{
                                    if let uid = s[".id"]{
                                        let requset_remove = Request(api: "/radius/remove")
                                        requset_remove.uid = uid
                                        requset_remove.apiType = .DEL
                                        _ = mk.sendAPI2(r: requset_remove)
                                        
                                    }
                                }
                            }
                            
                            /// 1.2 thêm máy chủ radius mới
                            let create_radius_params = ["address":Engine.sharedInstance.getSession()!.public_server_radius_ip,"comment":"PUBLIC_RADIUS","secret":password_for_radius_login,"service":"hotspot,ppp"]
                            let request_create_radius = Request(api: "/radius/add", type: ApiType.ADD, p: create_radius_params, q: nil, u: nil)
                            let rs_create_radius = mk.sendAPI2(r: request_create_radius)
                            if (rs_create_radius.0 == false){
                                routerResponse.send(json: ["status":400,"message":"không tạo được radius"])
                                next()
                                return
                            }
                            
                            let set_enable_incoming = Request(api: "/radius/incoming/set", type: ApiType.SET, p: ["accept":"yes","port":"1700"], q: nil, u: nil)
                            _ = mk.sendAPI2(r: set_enable_incoming)
                            
                            
                            /// 4 CONFIG HOTSPOT // DEFAULT ether2
                            
                            /// 4.1 dns --> ip dns set servers=8.8.8.8 allow-remote-requests=yes
                            //let rq_add_dns = Request(api: "/ip/dns/set", type: ApiType.SET, p: ["servers":"8.8.8.8","allow-remote-requests":"yes"], q: nil, u: nil)
                            /// 4.2 create IP address -> ip address add address=192.168.50.1/24 interface=ether2
                            //let rq_cr_ip_add = Request(api: "/ip/address/add", type: ApiType.ADD, p: ["address":"192.168.50.1/24","interface":"ether2"], q: nil, u: nil)
                            /// 4.3 create add pool -> ip pool add name=hotspot-pool ranges=192.168.50.2-192.168.50.254
                            //Request(api: "", type: ApiType.ADD, p: ["":""], q: nil, u: nil)
                            //let rq_cr_pool = Request(api: "/ip/pool/add", type: ApiType.ADD, p: ["name":"hotspot-pool","ranges":"192.168.50.2-192.168.50.254"], q: nil, u: nil)
                            /// 4.4 create dhcp-server network -> ip dhcp-server network add address=192.168.50.0/24 gateway=192.168.50.1 dns-server=8.8.8.8
                            //let rq_cr_dhcp_server_network = Request(api: "/ip/dhcp-server/network/add", type: ApiType.ADD, p: ["address":"192.168.50.0/24","gateway":"192.168.50.1","dns-server":"8.8.8.8"], q: nil, u: nil)
                            /// 4.5 create dhcp-server -> ip dhcp-server add name=dhcp-for-hotspot interface=ether2 lease-time=10m address-pool=hotspot-pool bootp-support=static authoritative=yes  disabled=no
                            //let rq_cr_dhcp_server = Request(api: "/ip/dhcp-server/add", type: ApiType.ADD, p: ["name":"dhcp-for-hotspot","interface":"ether2","lease-time":"10m","address-pool":"hotspot-pool","bootp-support":"static","authoritative":"yes","disabled":"no"], q: nil, u: nil)
                            /// 4.6 add nas cho day ip -> ip firewall nat add chain=srcnat action=masquerade src-address=192.168.50.0/24
                            //let rq_cr_add_nad_ip = Request(api: "/ip/firewall/nat/add", type: ApiType.ADD, p: ["chain":"srcnat","action":"masquerade","src-address":"192.168.50.0/24"], q: nil, u: nil)
                            /// 4.7 create hotspot profile server -> ip hotspot profile add name=hotspot-profile hotspot-address=192.168.50.1 use-radius=no
                            //let rq_cr_add_hotspot_profile = Request(api: "/ip/hotspot/profile/add", type: ApiType.ADD, p: ["name":"hotspot-profile","hotspot-address":"192.168.50.1","use-radius":"yes"], q: nil, u: nil)
                            /// 4.8 create hotspot -> ip hotspot add address-pool=hotspot-pool interface=ether2 profile=hotspot-profile disabled=no name=HOTSPOT
                            //let rq_cr_add_hotspot = Request(api: "/ip/hotspot/add", type: ApiType.ADD, p: ["address-pool":"hotspot-pool","interface":"ether2","profile":"hotspot-profile","disabled":"no","name":"HOTSPOT"], q: nil, u: nil)
                            /// 4.9 mở ip (if use PUBLIC ROUTER ) -> ip hotspot walled-garden ip add action=accept disabled=no dst-address=192.168.70.253 server=!HOTSPOT
                            //_ = mk.sendAPIs(requests: [rq_add_dns,rq_cr_ip_add,rq_cr_pool,rq_cr_dhcp_server_network,rq_cr_dhcp_server,rq_cr_add_nad_ip,rq_cr_add_hotspot_profile,rq_cr_add_hotspot])
                            
                            
                            /// ADD ROUTER TO PUBLIC RADIUS
                            let usernam_add_router_params = ["coa-port":"1700","customer":"admin","disabled":"no","log":"auth-fail","use-coa":"yes","ip-address":ip_adddress!,"shared-secret":password_for_radius_login,"name":"\(name ?? "")__\(ip_adddress ?? "")"]
                            let userman_create_router = Request(api: "/tool/user-manager/router/add", type: ApiType.ADD, p: usernam_add_router_params, q: nil, u: nil)
                            let rs_userman_create_router = mk_public.sendAPI2(r: userman_create_router)
                            if (rs_userman_create_router.0 == false){
                                routerResponse.send(json: ["status":400,"message":"userman không tạo được router \(rs_userman_create_router.1?.localizedDescription ?? "")"])
                                next()
                                return
                            }
                            
                            try? Engine.sharedInstance.mySQLConnection()?.execute("INSERT INTO `tbl_router` (`name`, `username`, `password`, `ip_address`, `description`,`port`,`type`) VALUES ('\(name ?? "")', '\(user_name ?? "")', '\(password ?? "")', '\(ip_adddress ?? "")', '\(des ?? "")', \(port), \(type))", onCompletion: { (results) in
                                if(results.success){
                                    try? Engine.sharedInstance.mySQLConnection()?.execute("select * from `tbl_router` where ip_address = '\(ip_adddress ?? "")'", onCompletion: { (QueryResult) in
                                        routerResponse.send(json: ["status":200,"message":"ok","data":QueryResult.asRows ?? []])
                                        next()
                                    })
                                    
                                }else{
                                    routerResponse.send(json: ["status":400,"message":"\(results.asError?.localizedDescription ?? "Unknow error")"])
                                    next()
                                }
                            })
                        }
                    }else{
                        routerResponse.send(json: ["status":400,"message":"Đã tồn tại server"])
                        next()
                    }
                })
                
                /// b1 connect to router lấy về danh sách radius
            }else{
                routerResponse.send(json: ["status":400,"message":"missing param"])
                next()
            }
            
        }
        router.put(api) { (routerRequest, routerResponse, next) in
            var user_name : String?
            var password : String?
            var ip_adddress : String?
            var name : String?
            var des : String?
            var id_router : String?
            var strUpdate = ""
            for p in (routerRequest.body?.asMultiPart ?? []){
                if(p.name == "name"){
                    name = p.body.asText
                    if(name?.isEmpty == false){
                        if(strUpdate.isEmpty == false){
                            strUpdate = strUpdate + ","
                        }
                        strUpdate += "`name`='\(name!)'"
                    }
                }else if p.name == "ip_address" {
                    ip_adddress = p.body.asText
                    if(ip_adddress?.isEmpty == false){
                        if(strUpdate.isEmpty == false){
                            strUpdate = strUpdate + ","
                        }
                        strUpdate += "`ip_address`='\(ip_adddress!)'"
                    }
                }else if p.name == "username"{
                    user_name = p.body.asText
                    if(user_name?.isEmpty == false){
                        if(user_name?.isEmpty == false){
                            strUpdate = strUpdate + ","
                        }
                        strUpdate += "`username`='\(user_name!)'"
                    }
                }else if p.name == "password" {
                    password = p.body.asText
                    if(password?.isEmpty == false){
                        if(password?.isEmpty == false){
                            strUpdate = strUpdate + ","
                        }
                        strUpdate += "`password`='\(password!)'"
                    }
                    
                }else if p.name == "description" {
                    des = p.body.asText
                    if(des?.isEmpty == false){
                        if(des?.isEmpty == false){
                            strUpdate = strUpdate + ","
                        }
                        strUpdate += "`description`='\(des!)'"
                    }
                }else if p.name == "id"{
                    id_router = p.body.asText
                }
            }
            
            guard id_router != nil else{
                routerResponse.send(json: ["status":400,"message":"missing id_router"])
                next()
                return
            }
            
            guard user_name != nil || ip_adddress != nil || name != nil || password != nil else{
                routerResponse.send(json: ["status":400,"message":"no update"])
                next()
                return
            }
            
            
            
            do{
                try Engine.sharedInstance.mySQLConnection()?.execute("update `tbl_router` set \(strUpdate) WHERE `id` = \(id_router ?? "")", onCompletion: { (result) in
                    if(result.success){
                        routerResponse.send(json: ["status":200])
                    }else{
                        routerResponse.send(json: ["status":400,"message":"\(result.asError?.localizedDescription ?? "Unknow Error")"])
                    }
                })
            }catch{
                routerResponse.send(json: ["status":500,"message":"\(error.localizedDescription)"])
            }
            
            
            next()
        }
    }
}
