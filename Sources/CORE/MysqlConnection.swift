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
        mysqlConnection = MySQLConnection(host: Engine.sharedInstance.getSession()?.mysqlHostName ?? "", user: Engine.sharedInstance.getSession()?.mysqlUserName ?? "", password: Engine.sharedInstance.getSession()?.mysqlPassword ?? "", database: Engine.sharedInstance.getSession()?.mysqlDBName ?? "", port: 3306, unixSocket: nil, clientFlag: 0, characterSet: nil, reconnect: true)
        mysqlConnection.connect { error in
            Log.info("MYSQL CONNECTED")
            if error != nil {
                Log.info("MYSQL CONFIG FAILURE" + (error?.localizedDescription ?? ""))
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
