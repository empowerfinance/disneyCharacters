//
//  CharacterListViewModel.swift
//  ToDoList
//
//  Created by Dotan Tamir on 17/9/2025.
//

import Foundation
import Combine

protocol CharacterListViewModelDelegate: AnyObject {
    func characterListViewModelDidUpdateCharacters(_ viewModel: CharacterListViewModel)
    func characterListViewModel(_ viewModel: CharacterListViewModel, didChangeLoadingState isLoading: Bool)
    func characterListViewModel(_ viewModel: CharacterListViewModel, didEncounterError error: Error)
}

class CharacterListViewModel {
    
    // MARK: - Properties
    private let networkManager = DisneyNetworkManager()
    var characters: [DisneyCharacter] = []
    private(set) var isLoading = false
    private(set) var currentPage = 1
    private(set) var totalPages = 1
    private(set) var hasMorePages = false
    let title = "Disney Characters"
    let searchPlaceholder = "Search Disney Characters"
    
    // MARK: - Delegate
    var delegate: CharacterListViewModelDelegate?

    // MARK: - Combine
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    
    func loadCharacters() {
        guard !isLoading else { return }

        setLoading(true)
        currentPage = 1

        networkManager.fetchCharacters(page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.setLoading(false)
                    if case .failure(let error) = completion {
                        self?.delegate?.characterListViewModel(self!, didEncounterError: error)
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self = self else { return }
                    self.characters = response.data
                    self.totalPages = response.info.totalPages ?? 1
                    self.hasMorePages = self.currentPage < self.totalPages
                    self.delegate?.characterListViewModelDidUpdateCharacters(self)
                }
            )
            .store(in: &cancellables)
    }
    
    func loadMoreCharacters() {
        guard !isLoading, hasMorePages else { return }
        
        setLoading(true)
        currentPage += 1
        
        networkManager.fetchCharacters(page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.setLoading(false)
                    if case .failure(let error) = completion {
                        self?.currentPage -= 1 // Revert page increment on error
                        self?.delegate?.characterListViewModel(self!, didEncounterError: error)
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self = self else { return }
                    self.characters.append(contentsOf: response.data)
                    self.hasMorePages = self.currentPage < self.totalPages
                    self.delegate?.characterListViewModelDidUpdateCharacters(self)
                }
            )
            
            .store(in: &cancellables)
    }
    
    func searchCharacters(name: String) {
        guard !name.isEmpty else {
            loadCharacters()
            return
        }
        
        setLoading(true)
        
        networkManager.searchCharacters(name: name)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.setLoading(false)
                    if case .failure(let error) = completion {
                        self?.delegate?.characterListViewModel(self!, didEncounterError: error)
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self = self else { return }
                    self.characters = response.data
                    self.hasMorePages = false // Search results don't support pagination
                    self.delegate?.characterListViewModelDidUpdateCharacters(self)
                }
            )
            .store(in: &cancellables)
    }
    
    func character(at index: Int) -> DisneyCharacter? {
        guard index >= 0 && index < characters.count else { return nil }
        return characters[index]
    }
    
    var numberOfCharacters: Int {
        return characters.count
    }

    // MARK: - Private Methods

    private func setLoading(_ loading: Bool) {
        isLoading = loading
        delegate?.characterListViewModel(self, didChangeLoadingState: loading)
    }




}
