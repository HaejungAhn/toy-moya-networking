//
//  PunkAPI.swift
//  NetworkingEx
//
//  Created by USER on 2022/11/19.
//

import Foundation

import Moya

protocol TargetTypeTestable: TargetType {
    var endpoint: Moya.Endpoint { get }
}

enum PunkAPI {
    case beerList(page: Int)
    case beer(id: Int)
    case randomBeer
    #if DEBUG
    case error409
    case cannotConnectToServer
    case notConnectedToInternet
    #endif
}

extension PunkAPI: TargetTypeTestable {
    
    var baseURL: URL { URL(string: "https://api.punkapi.com/v2")! }
    
    var path: String {
        switch self {
        case .beerList(let page):
            return "/beers?page=\(page)"
        case .beer(let id):
            return "/beers/\(id)"
        case .randomBeer:
            return "/beers/random"
        default: return ""
        }
    }
    
    var sampleData: Data {
        guard case .error409 = self else { return Data.empty }
        let dataString = "{\"code\": \"ALREADY_EXIST_PHONE_NUMBER\", \"msg\": \"이미 가입된 휴대폰 번호 입니다.\"}".utf8
        return Data(dataString)
    }
    
    var method: Moya.Method { return .get }
    
    var task: Moya.Task {
        switch self {
        case .beerList(let page): return .requestParameters(parameters: ["page": page], encoding: URLEncoding.queryString)
        default: return .requestPlain
        }
    }
    
    var headers: [String : String]? { return nil }
    
}

#if DEBUG
extension PunkAPI {
    
    var endpoint: Moya.Endpoint {
        let sampleResponseClosure: Moya.Endpoint.SampleResponseClosure
        
        switch self {
        case .error409:            /// 서버 통신 후 status code 409
            sampleResponseClosure = { .networkResponse(409, self.sampleData) }
        case .notConnectedToInternet:   /// 클라 인터넷 연결 X
            sampleResponseClosure = { .networkError(NSError(domain: URLError.errorDomain, code: URLError.notConnectedToInternet.rawValue)) }
        case .cannotConnectToServer:    /// 서버연결 실패
            sampleResponseClosure = { .networkError(NSError(domain: URLError.errorDomain, code: URLError.cannotConnectToHost.rawValue)) }
        default:
            sampleResponseClosure = { .networkResponse(200, .empty) }
        }
        
        return Endpoint(url: "https://api.punkapi.com/v2",
                        sampleResponseClosure: sampleResponseClosure,
                        method: .get,
                        task: .requestPlain,
                        httpHeaderFields: nil)
    }
    
}

#endif
