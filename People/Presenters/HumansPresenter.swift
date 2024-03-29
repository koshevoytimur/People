//
//  Presenter.swift
//  People
//
//  Created by Тимур Кошевой on 27.10.2019.
//  Copyright © 2019 Тимур Кошевой. All rights reserved.
//

import Foundation

protocol HumansPresenterDelegate: class {
    func loadHumans()
}

class HumansPresenter {
    
    weak var delegate: HumansPresenterDelegate?
    
    let networkManager = NetworkManager()
    let storeManager = StoreManager()
    
    init(with delegate: HumansPresenterDelegate) {
        self.delegate = delegate
    }
    
    func fetchHumans(completion: @escaping (_ humans: Humans?, _ error: String?) -> Void) {
        networkManager.fetchHumans { (response, error) in
            
            // Getting humans from network
            if let unwrResponse = response {
                self.storeManager.wrtiteHumansToLocalStorage(humansToStore: unwrResponse)
                completion(unwrResponse, nil)
                
                // Getting humans from local storage if error occur
            } else {
                print("Error occur while fetching humans from network: \(error!)")
                
                let humans = self.storeManager.fetchHumansFromLocalStorage()
                if humans != nil {
                    completion(humans, nil)
                } else {
                    completion(nil, "Local storage is empty.")
                }
            }
        }
    }
    
    func fetchFilteredHumans(sortTypeAscending: SortTypes, charA: String?, charB: String?, completion: @escaping (_ humanDataArray: [HumanData]?, _ error: String?) -> Void) {
        fetchHumans { (humans, error) in
            if let error = error {
                print(error)
                completion(nil, error)
            } else {
                var sortedHumans = [HumanData]()
                
                if let charA = charA {
                    if let charB = charB {
                        for humanData in humans!.humanDataArray {
                            if humanData.first_name!.lowercased().contains(charA.lowercased()) && humanData.first_name!.lowercased().contains(charB.lowercased()) {
                                sortedHumans.append(humanData)
                            }
                        }
                    }
                    
                    sortedHumans = self.sortHumans(sortTypeAscending: sortTypeAscending, humanDataArray: sortedHumans)
                    
                    completion(sortedHumans, nil)
                } else {
                    sortedHumans = self.sortHumans(sortTypeAscending: sortTypeAscending, humanDataArray: humans!.humanDataArray)
                    completion(sortedHumans, nil)
                }
            }
        }
    }
    
    func sortHumans(sortTypeAscending: SortTypes, humanDataArray: [HumanData]) -> [HumanData] {
        switch sortTypeAscending {
        case .ascending_true:
            return humanDataArray.sorted(by: { $0.first_name! < $1.first_name! })
        case .ascending_false:
            return humanDataArray.sorted(by: { $0.first_name! > $1.first_name! })
        default:
            return humanDataArray
        }
    }
    
    func deleteHuman(id: Int) {
        storeManager.deleteHumanFromLocalStorage(id: id)
    }
    
}
