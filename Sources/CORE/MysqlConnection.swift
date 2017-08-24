


 class MysqlConnection : BaseComponent{
    override func componentType() -> ComponentType{
      return ComponentType.DataBase
    }
    override func start(){
      print("MysqlConnection start")
    }
    override func loadConfig(){

    }
}
