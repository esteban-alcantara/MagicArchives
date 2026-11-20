//
//  CharacterDetailViewController.swift
//  MagicArchives
//
//  Created by Daniel Esteban Alcantara on 20/11/26.
//

import UIKit

final class CharacterDetailViewController: UIViewController {

    private let record: Record
    private let savesModel = SavesModel()
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let saveButton = UIButton(type: .system)

    init(record: Record) {
        self.record = record
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Usa init(record:) para abrir un expediente.")
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .ministryBackground
        setUpLayout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Expediente"
        setUpContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        updateSaveButton()
    }

    private func setUpLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        contentStackView.axis = .vertical
        contentStackView.spacing = 24
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 24),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -24),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -48)
        ])
    }

    private func setUpContent() {
        let imageView = UIImageView(image: UIImage(named: record.imageName))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        imageView.isAccessibilityElement = true
        imageView.accessibilityLabel = "Retrato de \(record.name)"
        contentStackView.addArrangedSubview(imageView)
        imageView.heightAnchor.constraint(equalToConstant: 350).isActive = true

        let nameLabel = makeLabel(record.name, style: .title1, color: .ministryForest)
        contentStackView.addArrangedSubview(nameLabel)

        saveButton.addTarget(self, action: #selector(toggleSave), for: .touchUpInside)
        saveButton.titleLabel?.numberOfLines = 0
        saveButton.titleLabel?.adjustsFontForContentSizeCategory = true
        contentStackView.addArrangedSubview(saveButton)
        saveButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 52).isActive = true
        updateSaveButton()

        let informationStack = UIStackView(arrangedSubviews: [
            makeField(title: "Ocupación", value: record.occupation),
            makeField(title: "Casa", value: record.house?.capitalized ?? "Sin casa"),
            makeField(title: "Afiliación", value: record.affiliation),
            makeField(title: "Estado", value: statusTitle)
        ])
        informationStack.axis = .vertical
        informationStack.spacing = 20
        informationStack.backgroundColor = .ministrySurface
        informationStack.layer.cornerRadius = 16
        informationStack.isLayoutMarginsRelativeArrangement = true
        informationStack.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 20, leading: 20, bottom: 20, trailing: 20
        )
        contentStackView.addArrangedSubview(informationStack)

        if let reward = record.reward {
            let rewardStack = makeField(
                title: "RECOMPENSA",
                value: "\(reward.formatted()) galeones",
                color: .ministryDanger
            )
            rewardStack.backgroundColor = .ministryDangerSurface
            rewardStack.layer.cornerRadius = 16
            rewardStack.isLayoutMarginsRelativeArrangement = true
            rewardStack.directionalLayoutMargins = NSDirectionalEdgeInsets(
                top: 20, leading: 20, bottom: 20, trailing: 20
            )
            contentStackView.addArrangedSubview(rewardStack)
        }

        contentStackView.addArrangedSubview(makeField(
            title: "Antecedentes", value: record.description
        ))
    }

    private var statusTitle: String {
        switch record.status {
        case "activo": return "Activo"
        case "archivado": return "Archivado"
        case "buscado": return "Se busca"
        case "en_observacion": return "En observación"
        case "protegido": return "Protegido"
        case "reservado": return "Reservado"
        default: return "Sin Estado definido"
        }
    }

    private func makeLabel(_ text: String, style: UIFont.TextStyle, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: style)
        label.textColor = color
        label.numberOfLines = 0
        return label
    }

    private func makeField(title: String, value: String, color: UIColor = .ministryForest) -> UIStackView {
        let titleLabel = makeLabel(title, style: .subheadline, color: .ministrySecondary)
        let valueLabel = makeLabel(value, style: .body, color: color)
        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stackView.axis = .vertical
        stackView.spacing = 6
        return stackView
    }

    @objc private func toggleSave() {
        savesModel.loadSaves()
        if let index = savesModel.savedCharacters.firstIndex(where: { $0.id == record.id }) {
            savesModel.removeCharacters(at: IndexPath(row: index, section: 0))
        } else {
            saveCharacter(savedCharacter: record)
        }
        updateSaveButton()
    }

    private func saveCharacter(savedCharacter: Record) {
        var savedCharacters: [Record] = []

        if let data = UserDefaults.standard.data(forKey: userDefaultsKeys.saves.rawValue) {
            guard let saved = try? JSONDecoder().decode([Record].self, from: data) else {
                return
            }
            savedCharacters = saved
        }

        guard !savedCharacters.contains(where: { $0.id == savedCharacter.id }) else {
            return
        }

        savedCharacters.append(savedCharacter)

        guard let data = try? JSONEncoder().encode(savedCharacters) else {
            return
        }

        UserDefaults.standard.set(data, forKey: userDefaultsKeys.saves.rawValue)
    }

    private func updateSaveButton() {
        savesModel.loadSaves()
        let isSaved = savesModel.savedCharacters.contains(where: { $0.id == record.id })
        var configuration = UIButton.Configuration.filled()
        configuration.title = isSaved ? "Quitar de guardados" : "Guardar expediente"
        configuration.image = UIImage(systemName: isSaved ? "bookmark.fill" : "bookmark")
        configuration.imagePadding = 10
        configuration.baseBackgroundColor = isSaved ? .ministryGoldSurface : .ministryForest
        configuration.baseForegroundColor = isSaved ? .ministryForest : .ministryOnForest
        configuration.cornerStyle = .fixed
        configuration.background.cornerRadius = 12
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.font = .preferredFont(forTextStyle: .headline)
            return attributes
        }
        saveButton.configuration = configuration
    }
}

