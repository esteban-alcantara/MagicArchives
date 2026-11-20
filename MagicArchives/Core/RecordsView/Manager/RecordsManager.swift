//
//  RecordsManager.swift
//  MagicArchives
//
//  Created by Daniel Esteban Alcantara on 19/11/26.
//

import Foundation

enum LocalJSONError: LocalizedError {
    case fileNotFound(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            return "No se encontró el archivo: \(name)"
        }
    }
}


final class RecordsManager {

    func loadRecords() throws -> [Record] {
        guard let url = Bundle.main.url(forResource: "characters", withExtension: "json") else {
            throw LocalJSONError.fileNotFound("characters.json")
        }

        let data = try Data(contentsOf: url)
        let decode = try JSONDecoder().decode([Record].self, from: data)
        return decode
    }

}
