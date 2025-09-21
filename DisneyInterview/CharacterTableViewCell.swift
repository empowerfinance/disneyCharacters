//
//  CharacterTableViewCell.swift
//  ToDoList
//
//  Created by Dotan Tamir on 17/9/2025.
//

import UIKit

class CharacterTableViewCell: UITableViewCell {
    
    static let identifier = "CharacterTableViewCell"
    
    // MARK: - UI Components
    private let characterImageView = UIImageView()
    private let nameLabel = UILabel()
    private let categoryLabel = UILabel()
    private let appearancesLabel = UILabel()
    private let stackView = UIStackView()
    
    // MARK: - Properties
    private var imageTask: URLSessionDataTask?
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // Configure image view
        characterImageView.translatesAutoresizingMaskIntoConstraints = false
        characterImageView.contentMode = .scaleAspectFill
        characterImageView.clipsToBounds = true
        characterImageView.layer.cornerRadius = 8
        characterImageView.backgroundColor = .systemGray5
        
        // Configure labels
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 1
        
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.font = UIFont.systemFont(ofSize: 14)
        categoryLabel.textColor = .secondaryLabel
        categoryLabel.numberOfLines = 1
        
        appearancesLabel.translatesAutoresizingMaskIntoConstraints = false
        appearancesLabel.font = UIFont.systemFont(ofSize: 12)
        appearancesLabel.textColor = .tertiaryLabel
        appearancesLabel.numberOfLines = 1
        
        // Configure stack view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.distribution = .fill
        
        // Add labels to stack view
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(categoryLabel)
        stackView.addArrangedSubview(appearancesLabel)
        
        // Add subviews
        contentView.addSubview(characterImageView)
        contentView.addSubview(stackView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            characterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            characterImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            characterImageView.widthAnchor.constraint(equalToConstant: 60),
            characterImageView.heightAnchor.constraint(equalToConstant: 60),
            
            stackView.leadingAnchor.constraint(equalTo: characterImageView.trailingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        // Add disclosure indicator
        accessoryType = .disclosureIndicator
    }
    
    // MARK: - Configuration
    
    func configure(with character: DisneyCharacter) {
        nameLabel.text = character.name
        categoryLabel.text = character.primaryCategory
        appearancesLabel.text = "\(character.totalAppearances) appearances"
        
        // Cancel previous image loading task
        imageTask?.cancel()
        
        // Reset image
        characterImageView.image = UIImage(systemName: "person.circle.fill")
        characterImageView.tintColor = .systemGray3
        
        // Load character image if available
        if let imageUrlString = character.imageUrl, let imageUrl = URL(string: imageUrlString) {
            loadImage(from: imageUrl)
        }
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
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageTask?.cancel()
        imageTask = nil
        
        characterImageView.image = UIImage(systemName: "person.circle.fill")
        characterImageView.tintColor = .systemGray3
        nameLabel.text = nil
        categoryLabel.text = nil
        appearancesLabel.text = nil
    }
}
