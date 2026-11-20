//
//  ArchiveSectionHeader.swift
//  MagicArchives
//
//  Created by Daniel Esteban Alcantara on 20/11/26.
//

import UIKit

final class ArchiveSectionHeader: UICollectionReusableView {
    static let reuseIdentifier = "ArchiveSectionHeader"
    private let titleLabel = UILabel()
    private let countLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        titleLabel.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: .boldSystemFont(ofSize: 24))
        titleLabel.textColor = .ministryForest
        titleLabel.numberOfLines = 0
        countLabel.font = .preferredFont(forTextStyle: .subheadline)
        countLabel.textColor = .ministryGold
        countLabel.textAlignment = .right
        countLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        for label in [titleLabel, countLabel] {
            label.adjustsFontForContentSizeCategory = true
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
        }
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            countLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 12),
            countLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            countLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
        isAccessibilityElement = true
        accessibilityTraits = .header
    }

    func configure(with title: String, count: Int) {
        titleLabel.text = title
        countLabel.text = "\(count)"
        accessibilityLabel = "\(title), \(count) registros"
    }
}
