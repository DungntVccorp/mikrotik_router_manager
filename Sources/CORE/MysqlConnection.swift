import SwiftKueryMySQL
import SwiftKuery
import LoggerAPI

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
        mysqlConnection = MySQLConnection(host: Engine.sharedInstance.Session()?.mysqlHostName ?? "", user: Engine.sharedInstance.Session()?.mysqlUserName ?? "", password: Engine.sharedInstance.Session()?.mysqlPassword ?? "", database: Engine.sharedInstance.Session()?.mysqlDBName ?? "", port: 3306, unixSocket: nil, clientFlag: 0, characterSet: nil, reconnect: true)
        mysqlConnection.connect { error in
            Log.info("MYSQL CONNECTED")
            if error != nil {
                Log.info("MYSQL CONFIG FAILURE")
                fatalError()
            }
        }
    }
    public override func loadConfig(){
        
        
        
        
        
    }
    
    
    public func execute(_ raw: String, onCompletion: @escaping ((QueryResult) -> ())) throws{
        if mysqlConnection.isConnected {
            mysqlConnection.execute(raw, onCompletion: onCompletion)
        }else{
            throw executeError.NoConnected
        }
    }
    
}
