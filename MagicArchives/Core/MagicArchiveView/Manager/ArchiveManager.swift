//
//  ArchiveManager.swift
//  MagicArchives
//
//  Created by Daniel Esteban Alcantara on 20/11/26.
//

import Foundation

enum ArchiveJSONError: LocalizedError {
    case fileNotFound(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            return "No se encontró el archivo: \(name)"
        }
    }
}

final class ArchiveManager {
    func loadArchive() throws -> ArchiveResponse {
        guard let url = Bundle.main.url(forResource: "magic_archive", withExtension: "json") else {
            throw ArchiveJSONError.fileNotFound("magic_archive.json")
        }

        let data = try Data(contentsOf: url)
        let decode = try JSONDecoder().decode(ArchiveResponse.self, from: data)
        return decode
    }
}
