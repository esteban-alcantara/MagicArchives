//
//  PotionCollectionViewCell.swift
//  MagicArchives
//
//  Created by Daniel Esteban Alcantara on 20/11/26.
//

import UIKit

final class PotionCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "PotionCollectionViewCell"

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
            label.numberOfLines = 0
            label.adjustsFontForContentSizeCategory = true
        }

        let textStack = UIStackView(arrangedSubviews: [nameLabel, usageLabel])
        textStack.axis = .vertical
        textStack.spacing = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        textStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        contentView.addSubview(textStack)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 96),
            textStack.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textStack.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 12),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    func configure(with item: ArchiveItem) {
        imageView.image = UIImage(named: item.imageName)
        nameLabel.text = item.name
        usageLabel.text = item.usage
        accessibilityLabel = "\(item.name), \(item.usage)"
    }
}
