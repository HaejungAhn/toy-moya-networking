//
//  NetworkProvider.swift
//  NetworkingEx
//
//  Created by USER on 2022/11/19.
//

import Combine
import Foundation

import Moya

final class NetworkProvider<API: TargetTypeTestable>: MoyaProvider<API> {
    
    init(session: Moya.Session = MoyaProvider<API>.defaultAlamofireSession(), plugins: [PluginType] = []) {
        session.sessionConfiguration.timeoutIntervalForRequest = 10
        super.init(session: session, plugins: plugins)
    }
    
    init(useSample: Bool) {
        let sampleEndpointClosure = { (target: API) -> Endpoint in
            return target.endpoint
        }
        super.init(endpointClosure: sampleEndpointClosure,
                   stubClosure: MoyaProvider.immediatelyStub,
                   plugins: [])
    }
    
    /*
     NetworkProvider를 사용하는 클라이언트단 코드에서 async, await을 사용하게끔 만들고 싶다.
     방법 1. Combine Future를 사용한다. -> async/await 사용하기 위해서는 value를 써야하는데 이게 iOS 15 이상부터 지원됨. ㅠㅠ
     방법 2. withCheckedContinuation을 사용한다.
     둘다 만들어보고 차이점을 비교해보도록 하겠다. -> 코드는 사실 그게 그거임. Future를 리턴해주느냐, Result 타입을 리턴해주느냐.
     */
    func request<T: Decodable>(_ target: API, using: T.Type) async -> Result<T, CommonError> {
        return await withCheckedContinuation { [weak self] continuation in
            guard let self else { return continuation.resume(returning: .failure(.instanceReleased)) }
            
            self.request(target) { completion in
                switch completion {
                case .success(let response):
                    do {
                        let result = try response.filterSuccessfulStatusCodes().map(T.self)
                        return continuation.resume(returning: .success(result))
                    } catch {
                        let commonError = self.convertCommonError(using: error)
                        return continuation.resume(returning: .failure(commonError))
                    }
                case .failure(let moyaError):
                    let commonError = self.convertCommonError(using: moyaError)
                    return continuation.resume(returning: .failure(commonError))
                }
            }
        }
    }
    
//    func request<T: Decodable>(_ target: API, using: T.Type, completionHandler: @escaping (Result<T, Error>) -> Void) {
//        self.request(target) { completion in
//            switch completion {
//            case .success(let response):
//                do {
//                    let result = try response.filterSuccessfulStatusCodes().map(T.self)
//                    completionHandler(Result.success(result))
//                } catch {
//                    completionHandler(Result.failure(error))
//                }
//            case .failure(let error):
//                print(error)
//                completionHandler(Result.failure(error))
//            }
//        }
//    }
//
    private func convertCommonError(using error: Error) -> CommonError {
        guard let moyaError = error as? MoyaError else {
            printLog(error)
            return .unknown
        }
        
        switch moyaError {
        case .imageMapping:  return .responseMappingError(type: .image)
        case .jsonMapping:   return .responseMappingError(type: .json)
        case .stringMapping: return .responseMappingError(type: .string)
            
        case .objectMapping(let error, let response):
            printLog(response.request?.debugDescription as Any)
            printLog(error)
            return .responseMappingError(type: .object)
            
        case .encodableMapping(let error):
            printLog(error)
            return .requestEncodableMappingError
            
        case .statusCode(let response):
            let code = response.statusCode
            switch code {
            case 401: return .unauthorized
            case 403: return .forbidden
            case 404: return .notFound
            case 405: return .notAllowedMethod
            default :
                let errorInfo = try? response.map(APIErrorResponseModel.self)
                return .api(error: errorInfo)
            }
            
        case .underlying(let error, _):
            guard let afError = error.asAFError else {
                printLog(error)
                return .unknown
            }
            
            guard let urlError = afError.underlyingError as? URLError else {
                printLog(error)
                return .unknown
            }
            
            switch urlError.code {
            case .timedOut,
                 .cannotConnectToHost: /// host name은 존재하지만, host가 다운되거나 특정 port로 connection을 받지 못할 때 해당 에러 발생할 수 있음.
                return .cannotConnectToHost
            case .networkConnectionLost,  /// 통신 진행 도중 네트워크 연결 lost
                 .notConnectedToInternet: /// 클라이언트 인터넷 연결 X
                return .networkConnectionLost
            default:
                printLog(urlError)
                return .unknown
            }
            
        case .requestMapping(let string): /// Moya의 Endpoint를 URLRequest로 매핑 실패
            printLog(string)
            return .moyaEndpointMappingError
            
        case .parameterEncoding(let error):  /// Moya의 Endpoint가 URLRequest에 사용될 parameter 인코딩 실패
            printLog(error)
            return .moyaEndpointMappingError
        }
    }
    
    private func printLog(_ format: Any, _ args: CVarArg..., lineNumber: Int = #line, function: String = #function) {
        #if DEV
        let format = "[NetworkProvider:\(lineNumber)] \(function) > " + format
        NSLog("%@", "\(format) \(args)")
        #endif
    }

}

