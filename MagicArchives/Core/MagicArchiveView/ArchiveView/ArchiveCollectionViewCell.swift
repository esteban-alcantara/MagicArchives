//
//  ArchiveCollectionViewCell.swift
//  MagicArchives
//
//  Created by Daniel Esteban Alcantara on 20/11/26.
//

import UIKit

final class ArchiveCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ArchiveCollectionViewCell"

    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let usageLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        contentView.backgroundColor = .ministrySurface
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        nameLabel.font = .preferredFont(forTextStyle: .headline)
        nameLabel.textColor = .ministryForest
        usageLabel.font = .preferredFont(forTextStyle: .subheadline)
        usageLabel.textColor = .ministryGold

        for label in [nameLabel, usageLabel] {
            label.numberOfLines = 2
            label.adjustsFontForContentSizeCategory = true
        }
        for subview in [imageView, nameLabel, usageLabel] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(subview)
        }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            usageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            usageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            usageLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            usageLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    func configure(with item: ArchiveItem, section: ArchiveSection) {
        imageView.image = UIImage(named: item.imageName)
        nameLabel.text = item.name
        usageLabel.text = section == .objects ? item.detailValue : item.usage
        accessibilityLabel = "\(item.name), \(usageLabel.text ?? "")"
    }
}
