//
//  BeerDAO.swift
//  NetworkingEx
//
//  Created by USER on 2022/11/20.
//

import Foundation

final class BeerDAO: BeerRepository {
    
    private let network: NetworkProvider<PunkAPI>
    
    init(network: NetworkProvider<PunkAPI>) {
        self.network = network
    }
    
    func fetchBeer() async throws -> [BeerModel] {
        let result = await self.network.request(.error409, using: [BeerResponseModel].self)
        switch result {
        case .success(let success):
            return success.map { $0.toDomain() }
        case .failure(let failure):
            throw failure
        }
    }
    
    func fetchBeer2(_ completionHandler: @escaping ([BeerModel]) -> Void ) throws {
//        self.network.request(.beer(id: 10), using: [BeerResponseModel].self, completionHandler: { result in
//            switch result {
//            case .success(let success):
//                completionHandler(success.map { $0.toDomain() })
//            case .failure(let failure):
//                throw failure
//            }
//        })
    }
    
}
