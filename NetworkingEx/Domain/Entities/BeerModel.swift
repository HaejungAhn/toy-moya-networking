//
//  BeerModel.swift
//  NetworkingEx
//
//  Created by USER on 2022/11/20.
//

import Foundation

struct BeerModel {
    
    let id: Int?
    let name: String?
    let tagline: String?
    let firstBrewed: String?
    let description: String?
    let imageURL: String?
    
    func toViewModel() -> BeerListViewModel {
        return BeerListViewModel(id: self.id, name: self.name, imageURL: self.imageURL)
    }
    
}


struct BeerListViewModel {
    
    let id: Int?
    let name: String?
    let imageURL: String?
    
}
