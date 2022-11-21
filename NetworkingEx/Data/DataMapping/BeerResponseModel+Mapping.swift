//
//  BeerResponseModel+Mapping.swift
//  NetworkingEx
//
//  Created by USER on 2022/11/19.
//

import Foundation

struct BeerResponseModel: Decodable {
    
    let id: Int?
    let name: String?
    let tagline: String?
    let first_brewed: String?
    let description: String?
    let image_url: String?
    let abv: Float?
    let ibu: Float?
    let target_fg: Float?
    let target_og: Float?
    let ebc: Float?
    let srm: Float?
    let ph: Float?
    let attenuation_level: Float?
    let volume: Volume?
    let boil_volume: Volume?
    let method: BeerResponseModel.Method?
    let ingredients: Ingredients?
    let food_pairing: [String]?
    let brewers_tips: String?
    let contributed_by: String?
    
    func toDomain() -> BeerModel {
        return .init(id: self.id, name: self.name, tagline: self.tagline, firstBrewed: self.first_brewed, description: self.description, imageURL: self.image_url)
    }
    
}

extension BeerResponseModel {
    
    struct Volume: Decodable {
        let value: Float?
        let unit: String?
    }
    
    struct Malt: Decodable {
        let name: String?
        let amount: Volume?
    }
    
    struct Hops: Decodable {
        let name: String?
        let amount: Volume?
        let add: String?
        let attribute: String?
    }
    
    struct Method: Decodable {
        let mash_temp: [MashTemp]?
        let fermentation: Fermentation?
        let twist: String?
        
        struct MashTemp: Decodable {
            let temp: BeerResponseModel.Volume?
            let duration: Int?
        }
        
        struct Fermentation: Decodable {
            let temp: BeerResponseModel.Volume?
        }
    }
    
    struct Ingredients: Decodable {
        let malt: [Malt]?
        let hops: [Hops]?
        let yeast: String?
    }
    
}
