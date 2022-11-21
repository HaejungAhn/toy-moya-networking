//
//  ViewController.swift
//  NetworkingEx
//
//  Created by USER on 2022/11/19.
//

import Combine
import UIKit

import Then
import Moya

class ViewController: UIViewController {

    private let tableView = UITableView()
    private let cellName = "BeerTVCell"
    private var cancellables = Set<AnyCancellable>()
    
    let endpointClosure = { (target: StubAPI) -> Moya.Endpoint in
        return target.endpoint
    }
    lazy var provider = MoyaProvider<StubAPI>(endpointClosure: endpointClosure, stubClosure: MoyaProvider.immediatelyStub)
    
    private let viewModel = BeerViewModel(network: NetworkProvider<PunkAPI>(), usecase: BeerUseCase(beerRepository: BeerDAO(network: NetworkProvider<PunkAPI>(useSample: true))))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.setupSubscriptions()
        self.fetchBeerList()
    }
    
    private func fetchBeerList() {
        _Concurrency.Task {
            do {
                try await self.viewModel.fetchBeerList()
            } catch {
                guard let error = error as? CommonError else { return }
                guard case let .api(errorInfo) = error, let message = errorInfo?.msg else { return }
                
                let buildParam = ToastBuildParam(style: .message, displayLocation: .top, message: message)
                ErrorDisplayInvoker.shared.perform(command: MessageToast(param: buildParam))
            }
        }
    }

    private func setupTableView() {
        self.view.addSubview(self.tableView)
        self.tableView.do {
            $0.backgroundColor = .lightGray
            $0.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                $0.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                $0.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
                $0.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
                $0.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
            ])
            
            $0.delegate = self
            $0.dataSource = self
            
            $0.register(BeerTVCell.self, forCellReuseIdentifier: self.cellName)
        }
    }
    
    private func setupSubscriptions() {
        self.viewModel.beerListPublisher
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { result in
                    guard case let .failure(err) = result else { return }
                    print(err)
                },
                receiveValue: { [weak self] _ in
                    
                    self?.tableView.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.beerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellName, for: indexPath) as? BeerTVCell else {
            return UITableViewCell()
        }
        
        let data = self.viewModel.beerList[indexPath.row]
        cell.configure(imageURL: data.imageURL!, name: data.name!)
        
        return cell
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

