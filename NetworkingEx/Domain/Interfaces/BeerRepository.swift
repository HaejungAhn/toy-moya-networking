//
//  BeerRepository.swift
//  NetworkingEx
//
//  Created by USER on 2022/11/20.
//

import Foundation

protocol BeerRepository {
    
    func fetchBeer() async throws -> [BeerModel]
    
}
