//
//  StoreManager.swift
//  People
//
//  Created by Тимур Кошевой on 27.10.2019.
//  Copyright © 2019 Тимур Кошевой. All rights reserved.
//

import Foundation

class StoreManager {
    
    func wrtiteHumans(humansToStore: Humans) {
        let defaults = UserDefaults.standard
        defaults.set(try? PropertyListEncoder().encode(humansToStore), forKey: "humans")
        
        print("Humans stored")
    }
    
    func getHumans() -> Humans? {
        let defaults = UserDefaults.standard
        
        if let humans =  defaults.object(forKey: "humans") as? Data {
            let humans = try! PropertyListDecoder().decode(Humans.self, from: humans)
            
            print("Humans fetched from local storage")
            
            return humans
        } else {
            return nil
        }
    }
    
    func deleteHuman(id: Int) {
        var humans = getHumans()
        if let unwHumans = humans {
            for n in 0..<unwHumans.humanDataArray.count {
                if unwHumans.humanDataArray[n].id == id {
                    humans!.humanDataArray.remove(at: n)
                }
            }
            wrtiteHumans(humansToStore: humans!)
        }
    }
    
}
