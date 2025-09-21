//
//  CharacterDetailViewController.swift
//  ToDoList
//
//  Created by Dotan Tamir on 17/9/2025.
//

import UIKit
import SwiftUI

class CharacterDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let character: DisneyCharacter
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let characterImageView = UIImageView()
    private let nameLabel = UILabel()
    private let stackView = UIStackView()
    
    private var imageTask: URLSessionDataTask?
    
    // MARK: - Initialization
    
    init(character: DisneyCharacter) {
        self.character = character
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithCharacter()
    }
    
    deinit {
        imageTask?.cancel()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = character.name
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        
        // Setup content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup image view
        characterImageView.translatesAutoresizingMaskIntoConstraints = false
        characterImageView.contentMode = .scaleAspectFit
        characterImageView.clipsToBounds = true
        characterImageView.layer.cornerRadius = 12
        characterImageView.backgroundColor = .systemGray6
        
        // Setup name label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.boldSystemFont(ofSize: 28)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0
        
        // Setup stack view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(characterImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(stackView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            characterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            characterImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            characterImageView.widthAnchor.constraint(equalToConstant: 200),
            characterImageView.heightAnchor.constraint(equalToConstant: 200),
            
            nameLabel.topAnchor.constraint(equalTo: characterImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            stackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Configuration
    
    private func configureWithCharacter() {
        nameLabel.text = character.name
        
        // Load character image
        if let imageUrlString = character.imageUrl, let imageUrl = URL(string: imageUrlString) {
            loadImage(from: imageUrl)
        } else {
            characterImageView.image = UIImage(systemName: "person.circle.fill")
            characterImageView.tintColor = .systemGray3
        }
        
        // Add category buttons to stack view
        addCategoryButton(title: "Films", items: character.films, icon: "film")
        addCategoryButton(title: "TV Shows", items: character.tvShows, icon: "tv")
        addCategoryButton(title: "Short Films", items: character.shortFilms, icon: "film.stack")
        addCategoryButton(title: "Video Games", items: character.videoGames, icon: "gamecontroller")
        addCategoryButton(title: "Park Attractions", items: character.parkAttractions, icon: "location")
        addCategoryButton(title: "Allies", items: character.allies, icon: "person.2")
        addCategoryButton(title: "Enemies", items: character.enemies, icon: "person.badge.minus")
    }
    
    // MARK: - Helper Methods

    private func addCategoryButton(title: String, items: [String], icon: String) {
        let button = createCategoryButton(title: title, items: items, icon: icon)
        stackView.addArrangedSubview(button)
    }

    private func createCategoryButton(title: String, items: [String], icon: String) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .secondarySystemGroupedBackground
        button.layer.cornerRadius = 12
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        // Create button content
        let iconImageView = UIImageView(image: UIImage(systemName: icon))
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = .systemBlue
        iconImageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.text = title
        titleLabel.textColor = .label

        let countLabel = UILabel()
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.font = UIFont.systemFont(ofSize: 14)
        countLabel.text = "\(items.count) item\(items.count == 1 ? "" : "s")"
        countLabel.textColor = .secondaryLabel

        let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.tintColor = .systemGray3
        chevronImageView.contentMode = .scaleAspectFit

        button.addSubview(iconImageView)
        button.addSubview(titleLabel)
        button.addSubview(countLabel)
        button.addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: button.topAnchor, constant: 16),

            countLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            countLabel.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -16),

            chevronImageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 12),

            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor, constant: -8),
            countLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor, constant: -8)
        ])

        // Add button action
        button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
        button.tag = getCategoryTag(for: title)

        return button
    }

    private func getCategoryTag(for title: String) -> Int {
        switch title {
        case "Films": return 0
        case "TV Shows": return 1
        case "Short Films": return 2
        case "Video Games": return 3
        case "Park Attractions": return 4
        case "Allies": return 5
        case "Enemies": return 6
        default: return -1
        }
    }

    @objc private func categoryButtonTapped(_ sender: UIButton) {
        let (title, items) = getCategoryData(for: sender.tag)
        presentCategoryDetail(title: title, items: items)
    }

    private func getCategoryData(for tag: Int) -> (String, [String]) {
        switch tag {
        case 0: return ("Films", character.films)
        case 1: return ("TV Shows", character.tvShows)
        case 2: return ("Short Films", character.shortFilms)
        case 3: return ("Video Games", character.videoGames)
        case 4: return ("Park Attractions", character.parkAttractions)
        case 5: return ("Allies", character.allies)
        case 6: return ("Enemies", character.enemies)
        default: return ("Unknown", [])
        }
    }

    private func presentCategoryDetail(title: String, items: [String]) {
        let categoryDetailView = CategoryDetailView(
            categoryTitle: title,
            items: items,
            characterName: character.name
        )

        let hostingController = UIHostingController(rootView: categoryDetailView)
        hostingController.title = title

        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    // MARK: - Image Loading
    
    private func loadImage(from url: URL) {
        imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil,
                  let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self.characterImageView.image = image
                self.characterImageView.tintColor = nil
            }
        }
        
        imageTask?.resume()
    }
}
