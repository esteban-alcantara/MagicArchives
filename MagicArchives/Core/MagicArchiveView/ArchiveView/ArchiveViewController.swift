//
//  ArchiveViewController.swift
//  MagicArchives
//
//  Created by Daniel Esteban Alcantara on 19/11/26.
//

import UIKit

final class ArchiveViewController: UIViewController {

    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var archiveCollectionView: UICollectionView!

    private let manager = ArchiveManager()
    private var sections: [ArchiveSectionData] = []
    private var filteredSections: [ArchiveSectionData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        loadArchive()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setUpView() {
        title = "Archivo mágico"
        navigationItem.backButtonTitle = "Archivo"
        headingLabel.text = "Archivo mágico"
        subtitleLabel.text = "CATÁLOGO DEL MINISTERIO"
        searchBar.placeholder = "Buscar nombre, tipo o uso"
        searchBar.delegate = self
        view.backgroundColor = .ministryBackground

        archiveCollectionView.register(
            ArchiveCollectionViewCell.self,
            forCellWithReuseIdentifier: ArchiveCollectionViewCell.reuseIdentifier
        )
        archiveCollectionView.register(
            PotionCollectionViewCell.self,
            forCellWithReuseIdentifier: PotionCollectionViewCell.reuseIdentifier
        )
        archiveCollectionView.register(
            ArchiveSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ArchiveSectionHeader.reuseIdentifier
        )
        archiveCollectionView.dataSource = self
        archiveCollectionView.delegate = self
        archiveCollectionView.allowsSelection = true
        archiveCollectionView.keyboardDismissMode = .onDrag

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)

        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (self: ArchiveViewController, _) in
            self.archiveCollectionView.collectionViewLayout.invalidateLayout()
        }
    }

    private func loadArchive() {
        do {
            let response = try manager.loadArchive()
            sections = response.sections
            applyFilters()
        } catch {
            countLabel.text = "0 registros"
            archiveCollectionView.backgroundView = makeMessageView(
                title: "No se pudo cargar el archivo",
                message: error.localizedDescription
            )
            searchBar.isUserInteractionEnabled = false
        }
    }

    private func applyFilters() {
        let query = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        filteredSections = sections.compactMap { section in
            var filteredSection = section
            filteredSection.items = section.items.filter { item in
                query.isEmpty || [item.name, item.subtype, item.usage, item.detailValue].contains { value in
                    value.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
                }
            }
            return filteredSection.items.isEmpty ? nil : filteredSection
        }
        updateCollection()
    }

    private func updateCollection() {
        let count = filteredSections.reduce(0) { $0 + $1.items.count }
        countLabel.text = count == 1 ? "1 registro" : "\(count) registros"
        archiveCollectionView.backgroundView = count == 0 ? makeMessageView(
            title: "Sin registros",
            message: "Prueba otro nombre, tipo o uso."
        ) : nil
        // Las secciones visibles pueden cambiar de posición después de buscar.
        archiveCollectionView.setCollectionViewLayout(makeLayout(), animated: false)
        archiveCollectionView.reloadData()
        archiveCollectionView.setContentOffset(.zero, animated: false)
    }

    private func makeMessageView(title: String, message: String) -> UIView {
        let container = UIView()
        let imageView = UIImageView(image: UIImage(systemName: "sparkle.magnifyingglass"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .ministryGold
        imageView.isAccessibilityElement = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: .boldSystemFont(ofSize: 22))
        titleLabel.textColor = .ministryForest
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = .preferredFont(forTextStyle: .body)
        messageLabel.textColor = .ministrySecondary
        for label in [titleLabel, messageLabel] {
            label.numberOfLines = 0
            label.textAlignment = .center
            label.adjustsFontForContentSizeCategory = true
        }

        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, messageLabel])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            imageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        return container
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension ArchiveViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        filteredSections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredSections[section].items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = filteredSections[indexPath.section].items[indexPath.item]
        if filteredSections[indexPath.section].id == .potions {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PotionCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? PotionCollectionViewCell else { return UICollectionViewCell() }
            cell.configure(with: item)
            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ArchiveCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? ArchiveCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: item, section: filteredSections[indexPath.section].id)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: ArchiveSectionHeader.reuseIdentifier,
            for: indexPath
        ) as? ArchiveSectionHeader else { return UICollectionReusableView() }
        header.configure(
            with: filteredSections[indexPath.section].title,
            count: filteredSections[indexPath.section].items.count
        )
        return header
    }
}

extension ArchiveViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let item = filteredSections[indexPath.section].items[indexPath.item]
        let detailViewController = ArchiveDetailViewController(item: item)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

extension ArchiveViewController {
    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self = self,
                  self.filteredSections.indices.contains(sectionIndex) else { return nil }
            let type = self.filteredSections[sectionIndex].id
            let section: NSCollectionLayoutSection
            let availableWidth = environment.container.effectiveContentSize.width - 40
            switch type {
            case .spells:
                section = self.makeSpellsSection(width: min(260, availableWidth))
            case .potions:
                section = self.makePotionsSection(width: min(320, availableWidth))
            case .objects:
                section = self.makeObjectsSection(width: availableWidth)
            }

            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 32, trailing: 20)
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(56)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            return section
        }
    }

    private var cardTextHeight: CGFloat {
        let nameHeight = UIFont.preferredFont(forTextStyle: .headline).lineHeight * 2
        let usageHeight = UIFont.preferredFont(forTextStyle: .subheadline).lineHeight * 2
        return ceil(nameHeight + usageHeight + 40)
    }

    private func makeSpellsSection(width: CGFloat) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)
        ))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(width), heightDimension: .absolute(width + cardTextHeight)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.orthogonalScrollingBehavior = .continuous
        return section
    }

    private func makePotionsSection(width: CGFloat) -> NSCollectionLayoutSection {
        let height = UIFontMetrics(forTextStyle: .body).scaledValue(for: 160)
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height))
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(width), heightDimension: .absolute(height * 2 + 12)),
            subitems: [NSCollectionLayoutItem(layoutSize: itemSize), NSCollectionLayoutItem(layoutSize: itemSize)]
        )
        group.interItemSpacing = .fixed(12)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.orthogonalScrollingBehavior = .continuous
        return section
    }

    private func makeObjectsSection(width: CGFloat) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1)
        ))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute((width - 12) / 2 + cardTextHeight)
            ),
            repeatingSubitem: item,
            count: 2
        )
        group.interItemSpacing = .fixed(12)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        return section
    }
}

extension ArchiveViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilters()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension ArchiveViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        searchBar.searchTextField.isFirstResponder && !(touch.view?.isDescendant(of: searchBar) ?? false)
    }
}
