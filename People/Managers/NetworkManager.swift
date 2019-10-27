//
//  NetworkManager.swift
//  People
//
//  Created by Тимур Кошевой on 25.10.2019.
//  Copyright © 2019 Тимур Кошевой. All rights reserved.
//

import Foundation
import SystemConfiguration

class NetworkManager {
    
    let HUMANS_URL = "https://reqres.in/api/users?page=2"
    
    func getHumansURLSession(completion: @escaping (_ response: Humans?, _ error: String?) -> Void) {
        
        if connection() {
            guard let url = URL(string: HUMANS_URL) else { return }
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    var humans: Humans = try! JSONDecoder().decode(Humans.self, from: data)
                    
                    for n in 0..<humans.humanDataArray.count {
                        let url = URL(string: humans.humanDataArray[n].avatar!)
                        if let data = try? Data(contentsOf: url!) {
                            humans.humanDataArray[n].avatarData = data
                        }
                    }
                    completion(humans, nil)
                } else if let unwrError = error{
                    completion(nil, "Error occur while fetching data: \(unwrError)")
                }
            }.resume()
        } else {
            completion(nil, "No internet connection.")
        }

    }
    
    func connection() -> Bool{
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero:(0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress){
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1){zeroSockAdress in SCNetworkReachabilityCreateWithAddress(nil, zeroSockAdress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false{
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
    
}
