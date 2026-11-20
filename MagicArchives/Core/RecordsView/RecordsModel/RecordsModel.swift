//
//  RecordsModel.swift
//  MagicArchives
//
//  Created by Daniel Esteban Alcantara on 19/11/26.
//

import Foundation

struct Record: Decodable {
    let id: String
    let name: String
    let imageName: String
    let house: String?
    let occupation: String
    let affiliation: String
    let status: String
    let description: String
    let reward: Int?
}
