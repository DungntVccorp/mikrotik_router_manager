

import Foundation
import SwiftKueryMySQL
import Dispatch
import Kitura
import HeliumLogger

HeliumLogger.use()

// Create a new router
let router = Router()
let dbConnection = MySQLConnection(host: "localhost", user: "root", password: "", database: nil, port: 3306, unixSocket: nil, clientFlag: 1, characterSet: nil, reconnect: true)
dbConnection.connect { (err) in
    DispatchQueue.main.async {
        
    }
    
}
let tcp = tcp_connection(host: "192.168.1.5", port: 8728,userName: "admin",password: "")


router.get("/") {
    request, response, next in
    response.send("Hello, World!")
    next()
}

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: 8080, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.start()
RunLoop.current.run()
//430065650a01791338ad6c6127749c4c

