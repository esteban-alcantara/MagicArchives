//
//  RecordsTableViewCell.swift
//  MagicArchives
//
//  Created by Daniel Esteban Alcantara on 19/11/26.
//

import UIKit

class RecordsTableViewCell: UITableViewCell {

    static let reuseIdentifier = "RecordsTableViewCell"

    @IBOutlet weak var characterImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var occupationLabel: UILabel!
    @IBOutlet weak var houseLabel: UILabel!
    @IBOutlet weak var rewardLabel: UILabel!

    func configure(with record: Record) {
        characterImageView.image = UIImage(named: record.imageName)
        nameLabel.text = record.name
        occupationLabel.text = record.occupation
        houseLabel.text = record.house?.capitalized ?? "Sin casa"

        if let reward = record.reward {
            rewardLabel.text = "SE BUSCA · \(reward.formatted()) galeones"
            rewardLabel.isHidden = false
        } else {
            rewardLabel.text = nil
            rewardLabel.isHidden = true
        }
    }
    
}
