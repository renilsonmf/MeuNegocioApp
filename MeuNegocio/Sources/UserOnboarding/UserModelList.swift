//
//  UserModel.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 30/09/22.
//

import Foundation

// MARK: - UserModelElement
typealias UserModelList = [UserModel]

struct UserModel: Decodable {
    let name: String
    let barbershop: String
    let city: String
    let state: String
    let email: String
}

struct CreateUserModel: Codable {
    let name: String
    let barbershop: String
    let city: String
    let state: String
    let email: String
}

