//
//  CommonError.swift
//  NetworkingEx
//
//  Created by USER on 2022/11/19.
//

import Foundation

struct APIErrorResponseModel: Decodable {
    let code: String
    let msg: String?
}

enum CommonError: Error {
    
    case unauthorized       /// 401
    case forbidden          /// 403
    case notFound           /// 404
    case notAllowedMethod   /// 405
    case api(error: APIErrorResponseModel?) /// 위 상태 코드를 제외한 나머지
    case networkConnectionLost
    case cannotConnectToHost
    case moyaEndpointMappingError
    case instanceReleased
    case requestEncodableMappingError
    case responseMappingError(type: MappingType)
    case unknown
    
    enum MappingType: String {
        case image
        case json
        case string
        case object
    }
    
}

extension CommonError {
    
    var isNetworkError: Bool {
        switch self {
        case .networkConnectionLost,
             .cannotConnectToHost:
            return true
        default:
            return false
        }
    }
    
}
