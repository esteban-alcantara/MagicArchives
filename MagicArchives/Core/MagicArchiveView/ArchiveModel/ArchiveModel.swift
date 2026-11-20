//
//  ArchiveModel.swift
//  MagicArchives
//
//  Created by Daniel Esteban Alcantara on 20/11/26.
//

import Foundation

enum ArchiveSection: String, Decodable {
    case spells
    case potions
    case objects

    var title: String {
        switch self {
        case .spells: return "Hechizos"
        case .potions: return "Pociones"
        case .objects: return "Objetos misteriosos"
        }
    }
}

struct ArchiveResponse: Decodable {
    let sections: [ArchiveSectionData]
}

struct ArchiveSectionData: Decodable {
    let id: ArchiveSection
    let title: String
    var items: [ArchiveItem]
}

struct ArchiveItem: Decodable {
    let id: String
    let name: String
    let imageName: String
    let subtype: String
    let usage: String
    let detailValue: String
    let category: ArchiveSection
    let description: String?
    let difficulty: String?
    let dangerLevel: String?
    let incantation: String?
    let precautions: String?
    let isUnforgivable: Bool?
    let isHorcrux: Bool?
    let isRestricted: Bool?
}
