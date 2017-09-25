//
//  HttpCustomerLogin.swift
//  CORE
//
//  Created by dung.nt on 9/25/17.
//

import Foundation
extension HttpServerComponent{
    func apiForCustommer(){
        let api = "/api/customer"
        router.get("\(api)/login") { (request, response, next) in
            response.send(json: ["status":200,"message":"ok"])
            next()
        }
    }
}
