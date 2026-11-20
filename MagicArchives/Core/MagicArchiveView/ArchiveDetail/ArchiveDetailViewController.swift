//
//  ArchiveDetailViewController.swift
//  MagicArchives
//
//  Created by Daniel Esteban Alcantara on 20/11/26.
//

import UIKit

final class ArchiveDetailViewController: UIViewController {

    private let item: ArchiveItem

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    init(item: ArchiveItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        configureView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setUpViews() {
        view.backgroundColor = .ministryBackground
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        contentStack.addArrangedSubview(itemImageView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -24),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -48),
            itemImageView.heightAnchor.constraint(equalToConstant: 350)
        ])
    }

    private func configureView() {
        title = item.name
        navigationItem.largeTitleDisplayMode = .never
        itemImageView.image = UIImage(named: item.imageName) ?? UIImage(systemName: "photo")

        let nameLabel = makeLabel(item.name, style: .title1, color: .ministryForest)
        nameLabel.accessibilityTraits.insert(.header)
        contentStack.addArrangedSubview(nameLabel)

        configureBadges()
        addInformation(title: "Categoría", value: item.category.title)
        addInformation(
            title: item.category == .objects ? "Clasificación" : "Tipo",
            value: item.subtype
        )
        addInformation(title: "Descripción", value: item.description)
        addInformation(title: "Uso principal", value: item.usage)
        addInformation(title: "Dificultad", value: difficultyTitle)
        addInformation(title: "Nivel de peligro", value: dangerTitle)
        addInformation(title: "Fórmula", value: item.incantation)
        addInformation(title: "Precauciones", value: item.precautions)
    }

    private func addInformation(title: String, value: String?) {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else { return }

        let titleLabel = makeLabel(title, style: .subheadline, color: .ministrySecondary)
        let valueLabel = makeLabel(value, style: .body, color: .ministryForest)
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 6
        contentStack.addArrangedSubview(stack)
    }

    private func makeLabel(_ text: String, style: UIFont.TextStyle, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: style)
        label.textColor = color
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }

    private func configureBadges() {
        if item.isUnforgivable == true {
            contentStack.addArrangedSubview(makeBadge(title: "Imperdonable"))
        }
        if item.isHorcrux == true {
            contentStack.addArrangedSubview(makeBadge(title: "Horrocrux"))
        }
        if item.isRestricted == true {
            contentStack.addArrangedSubview(makeBadge(title: "Acceso restringido"))
        }
    }

    private func makeBadge(title: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .ministryDangerSurface
        container.layer.cornerRadius = 12
        let label = makeLabel(title, style: .headline, color: .ministryDanger)
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        return container
    }

    private var difficultyTitle: String? {
        guard let difficulty = item.difficulty?.trimmingCharacters(in: .whitespacesAndNewlines),
              !difficulty.isEmpty else { return nil }
        switch difficulty {
        case "basica": return "Básica"
        case "intermedia": return "Intermedia"
        case "avanzada": return "Avanzada"
        default: return difficulty.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }

    private var dangerTitle: String? {
        guard let danger = item.dangerLevel?.trimmingCharacters(in: .whitespacesAndNewlines),
              !danger.isEmpty else { return nil }
        switch danger {
        case "bajo": return "Bajo"
        case "medio": return "Medio"
        case "alto": return "Alto"
        case "critico": return "Crítico"
        default: return danger.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
}
