//
//  BeerViewModel.swift
//  NetworkingEx
//
//  Created by USER on 2022/11/20.
//

import Combine
import Foundation

final class BeerViewModel {
    
    private let network: NetworkProvider<PunkAPI>
    private let usecase: BeerUseCaseProtocol
    
    private let beerListSubject = CurrentValueSubject<[BeerListViewModel], Error>([])
    
    var beerListPublisher: AnyPublisher<[BeerListViewModel], Error> {
        return self.beerListSubject.eraseToAnyPublisher()
    }
    
    var beerList: [BeerListViewModel] {
        return self.beerListSubject.value
    }
    
    init(network: NetworkProvider<PunkAPI>, usecase: BeerUseCaseProtocol) {
        self.network = network
        self.usecase = usecase
    }
    
    func fetchBeerList() async throws {
        do {
            let result = try await self.usecase.execute()
            self.beerListSubject.send(result)
        } catch {
            // 만약 API 에러라면? -> error를 CommonError로 컨버팅 시켜야함.
            // 여기서 error 핸들링을 하던가 아니면 이걸 VC까지 전달한 후 VC에서 컨버팅, 핸들링 하면 될 것 같음.
            // 아니면 여기서 error를 throw하지 말고 한번 핸들링 한 다음 publisher를 통해 어떻게 처리할지를 전달
            //     -> 전달할 때 ErrorDisplay 프로토콜에서 처리할 수 있도록 parameter를 만들어주는게 필요할 듯.
            // api error, 인터넷 연결 에러, 서버 응답 불가 에러 등.
            throw error
        }
    }
    
    
}
