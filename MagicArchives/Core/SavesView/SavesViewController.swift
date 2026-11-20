//
//  SavesViewController.swift
//  MagicArchives
//
//  Created by Daniel Esteban Alcantara on 19/11/26.
//

import UIKit

class SavesViewController: UIViewController {

    @IBOutlet weak var savesTableView: UITableView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    let model = SavesModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        model.loadSaves()
        savesTableView.reloadData()
        updateEmptyState()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setUpView() {
        title = "Guardados"
        navigationItem.backButtonTitle = "Guardados"
        headingLabel.text = "Guardados"
        subtitleLabel.text = "TUS EXPEDIENTES"
        view.backgroundColor = .ministryBackground
        savesTableView.register(
            UINib(nibName: "RecordsTableViewCell", bundle: nil),
            forCellReuseIdentifier: RecordsTableViewCell.reuseIdentifier
        )
        savesTableView.dataSource = self
        savesTableView.delegate = self
        savesTableView.rowHeight = UITableView.automaticDimension
        savesTableView.estimatedRowHeight = 132
        savesTableView.tableFooterView = UIView()
    }

    private func updateEmptyState() {
        savesTableView.backgroundView = model.getNumberOfRows() == 0 ? makeEmptyStateView() : nil
    }

    private func makeEmptyStateView() -> UIView {
        let container = UIScrollView()
        let imageView = UIImageView(image: UIImage(systemName: "heart"))
        imageView.tintColor = .ministryGold
        imageView.contentMode = .scaleAspectFit
        imageView.isAccessibilityElement = false

        let titleLabel = UILabel()
        titleLabel.text = "Aún no tienes expedientes guardados"
        titleLabel.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: .boldSystemFont(ofSize: 22))
        titleLabel.textColor = .ministryForest
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true

        let messageLabel = UILabel()
        messageLabel.text = "Guarda un personaje desde su expediente para consultarlo aquí."
        messageLabel.font = .preferredFont(forTextStyle: .body)
        messageLabel.textColor = .ministrySecondary
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.adjustsFontForContentSizeCategory = true

        var configuration = UIButton.Configuration.filled()
        configuration.title = "Explorar expedientes"
        configuration.baseBackgroundColor = .ministryGoldSurface
        configuration.baseForegroundColor = .ministryForest
        configuration.cornerStyle = .fixed
        configuration.background.cornerRadius = 8
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
        let button = UIButton(configuration: configuration)
        button.titleLabel?.numberOfLines = 0
        button.addTarget(self, action: #selector(exploreRecords), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, messageLabel, button])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.setCustomSpacing(28, after: imageView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stackView)

        let centerConstraint = stackView.centerYAnchor.constraint(equalTo: container.frameLayoutGuide.centerYAnchor)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(greaterThanOrEqualTo: container.contentLayoutGuide.topAnchor, constant: 56),
            stackView.bottomAnchor.constraint(equalTo: container.contentLayoutGuide.bottomAnchor, constant: -24),
            stackView.leadingAnchor.constraint(equalTo: container.contentLayoutGuide.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: container.contentLayoutGuide.trailingAnchor, constant: -24),
            stackView.widthAnchor.constraint(equalTo: container.frameLayoutGuide.widthAnchor, constant: -48),
            centerConstraint,
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24),
            titleLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            messageLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            button.widthAnchor.constraint(lessThanOrEqualTo: stackView.widthAnchor),
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
        return container
    }

    @objc private func exploreRecords() {
        tabBarController?.selectedIndex = 0
        if let recordsNavigation = tabBarController?.selectedViewController as? UINavigationController {
            recordsNavigation.popToRootViewController(animated: false)
        }
    }

    func showDeleteAlert(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let character = model.getSavedCharacter(index: indexPath)
        let alert = UIAlertController(
            title: "Eliminar expediente guardado",
            message: "¿Quieres quitar a \(character.name) de Guardados?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel) { _ in
            completion(false)
        })
        alert.addAction(UIAlertAction(title: "Eliminar", style: .destructive) { [weak self] _ in
            guard let self = self else {
                completion(false)
                return
            }
            self.model.removeCharacters(at: indexPath)
            completion(true)
            self.savesTableView.reloadData()
            self.updateEmptyState()
        })
        present(alert, animated: true)
    }
}

extension SavesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.getNumberOfRows()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let count = model.getNumberOfRows()
        return count == 1 ? "1 expediente guardado" : "\(count) expedientes guardados"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: RecordsTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? RecordsTableViewCell else {
            return UITableViewCell()
        }
        let character = model.getSavedCharacter(index: indexPath)
        cell.configure(with: character)
        return cell
    }
}

extension SavesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let character = model.getSavedCharacter(index: indexPath)
        let detailViewController = CharacterDetailViewController(record: character)
        navigationController?.pushViewController(detailViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteSave = UIContextualAction(style: .destructive, title: "Eliminar") { [weak self] _, _, completion in
            guard let self = self else {
                completion(false)
                return
            }
            self.showDeleteAlert(at: indexPath, completion: completion)
        }
        deleteSave.image = UIImage(systemName: "trash")
        let configuration = UISwipeActionsConfiguration(actions: [deleteSave])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}
