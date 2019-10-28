//
//  StoreManager.swift
//  People
//
//  Created by Тимур Кошевой on 27.10.2019.
//  Copyright © 2019 Тимур Кошевой. All rights reserved.
//

import Foundation

class StoreManager {
    
    func wrtiteHumansToLocalStorage(humansToStore: Humans) {
        let defaults = UserDefaults.standard
        defaults.set(try? PropertyListEncoder().encode(humansToStore), forKey: "humans")
    }
    
    func fetchHumansFromLocalStorage() -> Humans? {
        let defaults = UserDefaults.standard
        
        if let humans =  defaults.object(forKey: "humans") as? Data {
            let humans = try! PropertyListDecoder().decode(Humans.self, from: humans)
            
            return humans
        } else {
            return nil
        }
    }
    
    func deleteHumanFromLocalStorage(id: Int) {
        var humans = fetchHumansFromLocalStorage()
        if let unwHumans = humans {
            for n in 0..<unwHumans.humanDataArray.count {
                if unwHumans.humanDataArray[n].id == id {
                    humans!.humanDataArray.remove(at: n)
                }
            }
            wrtiteHumansToLocalStorage(humansToStore: humans!)
        }
    }
    
}
