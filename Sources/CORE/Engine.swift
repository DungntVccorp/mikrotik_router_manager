//
//  Engine.swift
//  mikrotik_router_manager
//
//  Created by dung.nt on 8/21/17.
//
//

import Foundation
public class Engine {
    
    public static let sharedInstance = Engine()
    
    private init() {
        loadConfig()
        
    }
    
    var ListComponent = Dictionary<ComponentType,BaseComponent>()
    
    func registerComponent(component :  BaseComponent){
        ListComponent[component.componentType()] = component
    }
    func getComponent(type : ComponentType) -> BaseComponent?{
        return ListComponent[type]
    }
    
    func loadComponentConfig(){
        
        for c in ListComponent {
            c.value.loadConfig()
        }
    }
    func startComponent(){
        for c in ListComponent {
            c.value.start()
        }
    }
    
    public func start(){
        loadComponentConfig()
        startComponent()
    }
}
