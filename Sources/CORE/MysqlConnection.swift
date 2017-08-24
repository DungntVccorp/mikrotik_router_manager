import SwiftKueryMySQL
import SwiftKuery


public enum executeError : Error {
    case NoConnected
}
/// CONNECTION

public class MysqlConnection : BaseComponent{
    
    var mysqlConnection : MySQLConnection!
    
    public override func componentType() -> ComponentType{
      return ComponentType.DataBase
    }
    public override func start(){
      print("MysqlConnection start")
        
        mysqlConnection.connect { error in
            /// CREATE
//            mysqlConnection.execute("select * from tbl_router") { results in
//                for r in results.asRows!{
//                    print(r["id"])
//                }
//            }
            /// ADD
//            mysqlConnection.execute("INSERT INTO `tbl_router` (`name` , `username` , `password` , `ip_address` , `description`) VALUES ('d','admin','123456','10.10.10.2','test');", onCompletion: { queryResult in
//                print(queryResult)
//                print(queryResult.success)
//            })
                /// UPDATE
//            mysqlConnection.execute("update `tbl_router` set `name`='test doi ten' WHERE `id` = 3", onCompletion: { result in
//                print(result.success)
//            })
            /// DELETE
//            mysqlConnection.execute("DELETE FROM `tbl_router` WHERE id = 2", onCompletion: { (result) in
//                print(result.success)
//            })
            
            
        }
    }
    public override func loadConfig(){
        mysqlConnection = MySQLConnection(host: "localhost", user: "root", password: "123456", database: "router_manager", port: 3306, unixSocket: nil, clientFlag: 0, characterSet: nil, reconnect: true)
        
    }
    
    
    public func execute(_ raw: String, onCompletion: @escaping ((QueryResult) -> ())) throws{
        if mysqlConnection.isConnected {
            mysqlConnection.execute(raw, onCompletion: onCompletion)
        }else{
            throw executeError.NoConnected
        }
    }
    
}
