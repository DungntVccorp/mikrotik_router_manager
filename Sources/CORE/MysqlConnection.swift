


public class MysqlConnection : BaseComponent{
    public func componentType() -> ComponentType{
      return ComponentType.DataBase
    }
    public func start(){
      print("MysqlConnection start")
    }
    public func loadConfig(){

    }
}
