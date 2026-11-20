//
//  SavesModel.swift
//  MagicArchives
//
//  Created by Daniel Esteban Alcantara on 20/11/26.
//

import Foundation
import UIKit

enum userDefaultsKeys: String {
    case saves = "saves"
}

class SavesModel {

    var savedCharacters: [Record] = []

    init() {
        loadSaves()
    }

    func loadSaves() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKeys.saves.rawValue) else {
            savedCharacters = []
            return
        }

        savedCharacters = (try? JSONDecoder().decode([Record].self, from: data)) ?? []
    }

    func getNumberOfRows() -> Int {
        savedCharacters.count
    }

    func getSavedCharacter(index: IndexPath) -> Record {
        savedCharacters[index.row]
    }

    func removeCharacters(at index: IndexPath) {
        var updatedSaves = savedCharacters
        updatedSaves.remove(at: index.row)

        guard let data = try? JSONEncoder().encode(updatedSaves) else {
            return
        }

        UserDefaults.standard.set(data, forKey: userDefaultsKeys.saves.rawValue)
        savedCharacters = updatedSaves
    }

}
