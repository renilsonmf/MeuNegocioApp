//
//  RemoteConfigManager.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 19/09/23.
//

import Foundation
import FirebaseAuth
import Firebase

enum RemoteConfigKey: String {
    case urlEndpoints = "urlEndpoints"
}

public struct ListKeysRemoteConfig: Codable {
    let addUser: String?
    let getUserByEmail: String?
    let getAllProcedures: String?
    let getProcedureByEmail: String?
    let addProcedure: String?
    let updateProcedureById: String?
    let deleteProcedureById: String?
    let deleteAccountByEmail: String?
    let deleteAllProcedures: String?
}

class RemoteConfigManager {
    static let shared = RemoteConfigManager()
    
    private var remoteConfig: RemoteConfig!
    private var expirationDuration: TimeInterval = 18
    
    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "RemoteConfig")
    }
    
    func fetch() {
        remoteConfig.fetch(withExpirationDuration: expirationDuration) { [weak self] (status, error) in
            if status == .success {
                self?.remoteConfig.activate { changed, error in
                    if changed {
                        self?.remoteConfig.activate(completion: nil)
                    }
                }
            } else {
                //
            }
        }
    }
    
    public func getObject<T: Decodable>(_ type: T.Type, forKey key: RemoteConfigKey) -> T? {
        let data = remoteConfig.configValue(forKey: key.rawValue).dataValue
        return try? JSONDecoder().decode(type, from: data)
    }
}
