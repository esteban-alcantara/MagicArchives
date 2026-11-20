//
//  RecordsViewController.swift
//  MagicArchives
//
//  Created by Daniel Esteban Alcantara on 19/11/26.
//

import UIKit

final class RecordsViewController: UIViewController {

    @IBOutlet weak var recordsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var houseButtonsStackView: UIStackView!

    private let manager = RecordsManager()
    private var houseButtons: [UIButton] = []
    private var records: [Record] = []
    private var filteredRecords: [Record] = []
    private var selectedHouseTag = 0
    private let houses = ["", "gryffindor", "slytherin", "ravenclaw", "hufflepuff", ""]

    override func viewDidLoad() {
        super.viewDidLoad()

        headingLabel.text = "Expedientes"
        subtitleLabel.text = "MINISTERIO DE MAGIA"
        searchBar.placeholder = "Buscar nombre u ocupación"
        setUpHouseButtons()
        setUpKeyboardDismissal()
        recordsTableView.register(
            UINib(nibName: "RecordsTableViewCell", bundle: nil),
            forCellReuseIdentifier: RecordsTableViewCell.reuseIdentifier
        )
        loadRecords()
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

    private func setUpKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func loadRecords() {
        do {
            records = try manager.loadRecords()
            applyFilters()
        } catch {
            recordsTableView.backgroundView = makeMessageView(
                title: "No se pudieron cargar los expedientes",
                message: error.localizedDescription,
                showsResetButton: false
            )
        }
    }

    private func setUpHouseButtons() {
        let titles = ["Todos", "Gryffindor", "Slytherin", "Ravenclaw", "Hufflepuff", "Sin casa"]

        for (index, title) in titles.enumerated() {
            var configuration = UIButton.Configuration.filled()
            configuration.title = title
            configuration.cornerStyle = .capsule
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 32, bottom: 0, trailing: 32)
            configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
                var attributes = attributes
                attributes.font = .preferredFont(forTextStyle: .subheadline)
                return attributes
            }

            let button = UIButton(configuration: configuration)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.titleLabel?.numberOfLines = 1
            button.setContentCompressionResistancePriority(.required, for: .horizontal)
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 160).isActive = true
            button.tag = index
            button.addTarget(self, action: #selector(houseFilterTapped(_:)), for: .touchUpInside)
            button.configurationUpdateHandler = { button in
                var configuration = button.configuration
                configuration?.baseBackgroundColor = button.isSelected ? .ministryForest : .ministryChip
                configuration?.baseForegroundColor = button.isSelected ? .ministryOnForest : .ministrySecondary
                button.configuration = configuration
            }

            houseButtonsStackView.addArrangedSubview(button)
            houseButtons.append(button)
        }

        updateHouseSelection()
    }

    @objc private func houseFilterTapped(_ sender: UIButton) {
        selectedHouseTag = sender.tag
        updateHouseSelection()
        applyFilters()
    }

    @objc private func resetFilters(_ sender: UIButton) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        selectedHouseTag = 0
        updateHouseSelection()
        applyFilters()
    }

    private func updateHouseSelection() {
        for button in houseButtons {
            button.isSelected = button.tag == selectedHouseTag
        }
    }

    private func applyFilters() {
        let query = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        filteredRecords = records.filter { record in
            let matchesHouse = selectedHouseTag == 0 || (record.house ?? "") == houses[selectedHouseTag]
            let matchesSearch = query.isEmpty || [record.name, record.occupation].contains { value in
                value.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
            }
            return matchesHouse && matchesSearch
        }

        recordsTableView.backgroundView = filteredRecords.isEmpty ? makeMessageView(
            title: "Sin expedientes",
            message: "Prueba otro nombre, ocupación o casa.",
            showsResetButton: true
        ) : nil
        recordsTableView.reloadData()
        recordsTableView.setContentOffset(.zero, animated: false)
    }

    private func makeMessageView(title: String, message: String, showsResetButton: Bool) -> UIView {
        let container = UIView()

        let imageView = UIImageView(image: UIImage(systemName: "plus.magnifyingglass"))
        imageView.tintColor = .ministryGold
        imageView.contentMode = .scaleAspectFit
        imageView.isAccessibilityElement = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: .boldSystemFont(ofSize: 22))
        titleLabel.textColor = .ministryForest
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true

        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = .preferredFont(forTextStyle: .body)
        messageLabel.textColor = .ministrySecondary
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.adjustsFontForContentSizeCategory = true

        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, messageLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.setCustomSpacing(28, after: imageView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        if showsResetButton {
            var configuration = UIButton.Configuration.filled()
            configuration.title = "Restablecer filtros"
            configuration.baseBackgroundColor = .ministryGoldSurface
            configuration.baseForegroundColor = .ministryForest
            configuration.cornerStyle = .fixed
            configuration.background.cornerRadius = 8
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)

            let button = UIButton(configuration: configuration)
            button.addTarget(self, action: #selector(resetFilters(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
            button.widthAnchor.constraint(lessThanOrEqualTo: stackView.widthAnchor).isActive = true
        }

        container.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24),
            titleLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            messageLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
        return container
    }
}

extension RecordsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let count = filteredRecords.count
        return count == 1 ? "1 expediente" : "\(count) expedientes"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredRecords.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: RecordsTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? RecordsTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(with: filteredRecords[indexPath.row])
        return cell
    }
}

extension RecordsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilters()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension RecordsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        searchBar.searchTextField.isFirstResponder && !(touch.view?.isDescendant(of: searchBar) ?? false)
    }
}
