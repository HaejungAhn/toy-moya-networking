//
//  BeerUseCase.swift
//  NetworkingEx
//
//  Created by USER on 2022/11/20.
//

import Foundation

protocol BeerUseCaseProtocol {
    func execute() async throws -> [BeerListViewModel]
}

final class BeerUseCase: BeerUseCaseProtocol {
    
    private let beerRepository: BeerRepository
    
    init(beerRepository: BeerRepository) {
        self.beerRepository = beerRepository
    }
    
    func execute() async throws -> [BeerListViewModel] {
        do {
            return try await self.beerRepository.fetchBeer().map { $0.toViewModel() }
        } catch {
            throw error
        }
    }
    
}
