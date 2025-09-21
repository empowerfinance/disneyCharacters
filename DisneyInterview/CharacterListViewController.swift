//
//  CharacterListViewController.swift
//  ToDoList
//
//  Created by Dotan Tamir on 17/9/2025.
//

import UIKit

class CharacterListViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let searchController = UISearchController(searchResultsController: nil)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let refreshControl = UIRefreshControl()
    
    private let viewModel = CharacterListViewModel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()

        // Set delegate
        viewModel.delegate = self

        // Load initial data
        viewModel.loadCharacters()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = viewModel.title
        
        // Setup search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = viewModel.searchPlaceholder
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Setup table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CharacterTableViewCell.self, forCellReuseIdentifier: CharacterTableViewCell.identifier)
        tableView.rowHeight = 80
        tableView.refreshControl = refreshControl
        
        // Setup refresh control
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        // Setup activity indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        
        // Add subviews
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func refreshData() {
        if searchController.isActive && !searchController.searchBar.text!.isEmpty {
            viewModel.searchCharacters(name: searchController.searchBar.text!)
        } else {
            viewModel.loadCharacters()
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateEmptyStateIfNeeded() {
        if viewModel.numberOfCharacters == 0 {
            let emptyLabel = UILabel()
            emptyLabel.text = "No characters found"
            emptyLabel.textAlignment = .center
            emptyLabel.textColor = .gray
            emptyLabel.font = UIFont.systemFont(ofSize: 18)
            tableView.backgroundView = emptyLabel
        } else {
            tableView.backgroundView = nil
        }
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CharacterListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCharacters
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CharacterTableViewCell.identifier, for: indexPath) as! CharacterTableViewCell
        
        if let character = viewModel.character(at: indexPath.row) {
            cell.configure(with: character)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CharacterListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let character = viewModel.character(at: indexPath.row) {
            let detailVC = CharacterDetailViewController(character: character)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Load more data when approaching the end
        if indexPath.row == viewModel.numberOfCharacters - 5 && viewModel.hasMorePages && !viewModel.isLoading {
            viewModel.loadMoreCharacters()
        }
    }
}

// MARK: - UISearchResultsUpdating
extension CharacterListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        // Debounce search to avoid too many API calls
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: nil)
        perform(#selector(performSearch), with: searchText, afterDelay: 0.5)
    }
    
    @objc private func performSearch(_ searchText: String) {
        if searchText.isEmpty {
            viewModel.loadCharacters()
        } else {
            viewModel.searchCharacters(name: searchText)
        }
    }
}

// MARK: - CharacterListViewModelDelegate

extension CharacterListViewController: CharacterListViewModelDelegate {

    func characterListViewModelDidUpdateCharacters(_ viewModel: CharacterListViewModel) {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            self.updateEmptyStateIfNeeded()
    }

    func characterListViewModel(_ viewModel: CharacterListViewModel, didChangeLoadingState isLoading: Bool) {
        DispatchQueue.main.async { [weak self] in
            if isLoading && viewModel.numberOfCharacters == 0 {
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
            }
        }
    }

    func characterListViewModel(_ viewModel: CharacterListViewModel, didEncounterError error: Error) {
            self.refreshControl.endRefreshing()
            self.showErrorAlert(error: error)
    }
}
