//
//  StubAPI.swift
//  NetworkingEx
//
//  Created by USER on 2022/11/21.
//

import Foundation

import Moya

enum StubAPI {
    case statusCode409
    case cannotConnectToServer
    case notConnectedToInternet
}

extension StubAPI: TargetType {
    
    var baseURL: URL { URL(string: "https://indiz.kr")! }
    
    var path: String { return "/stubAPIs" }
    
    var method: Moya.Method { return .get }
    
    var sampleData: Data {
        guard case .statusCode409 = self else { return Data.empty }
        let dataString = "{\"code\": \"ALREADY_EXIST_PHONE_NUMBER\", \"msg\": \"이미 가입된 휴대폰 번호 입니다.\"}".utf8
        return Data(dataString)
    }
    
    var task: Moya.Task { return .requestPlain }
    
    var headers: [String : String]? { return nil }
    
}

extension StubAPI {
    
    var endpoint: Moya.Endpoint {
        let sampleResponseClosure: Moya.Endpoint.SampleResponseClosure
        
        switch self {
        case .statusCode409:            /// 서버 통신 후 status code 409
            sampleResponseClosure = { .networkResponse(409, self.sampleData) }
        case .notConnectedToInternet:   /// 클라 인터넷 연결 X
            sampleResponseClosure = { .networkError(NSError(domain: URLError.errorDomain, code: URLError.notConnectedToInternet.rawValue)) }
        case .cannotConnectToServer:    /// 서버연결 실패
            sampleResponseClosure = { .networkError(NSError(domain: URLError.errorDomain, code: URLError.cannotConnectToHost.rawValue)) }
        }
        
        return Endpoint(url: "https://indiz.kr",
                        sampleResponseClosure: sampleResponseClosure,
                        method: .get,
                        task: .requestPlain,
                        httpHeaderFields: nil)
    }
    
}
