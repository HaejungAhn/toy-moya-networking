//
//  Toast.swift
//  NetworkingEx
//
//  Created by USER on 2022/11/21.
//

import UIKit

import SnapKit

protocol ToastProtocol: ErrorDisplayCommand {
    func show()
    func hide()
}

extension ToastProtocol {
    
    func display() {
        self.show()
    }
    
}

struct ToastBuildParam {
    let style: ToastStyle
    let displayLocation: ToastDisplayLocation
    let message: String
    var iconImage: UIImage? = nil
}

enum ToastStyle {
    case message
    case messageWithIcon
}

enum ToastDisplayLocation {
    case top
    case bottom
}

final class MessageToast: UIView {
    
    private let messageLabel = UILabel()
    private let buildParam: ToastBuildParam
    private let keyWindow = UIApplication.shared
                            .connectedScenes
                            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                            .first { $0.isKeyWindow }
    
    init(param: ToastBuildParam) {
        self.buildParam = param
        
        let point = CGPoint(x: 20, y: 80)
        let size = CGSize(width: 200, height: 50)
        super.init(frame: CGRect(origin: point, size: size))
        
        self.backgroundColor = .black
        self.layer.cornerRadius = 10
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        guard let keyWindow else { return }
        self.frame.size.width = keyWindow.frame.width - 40
    }
    
    private func setupViews() {
        self.addSubview(messageLabel)
        self.messageLabel.text = self.buildParam.message
        self.messageLabel.font = .boldSystemFont(ofSize: 15)
        self.messageLabel.textColor = .white
        self.messageLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
    }
    
}

extension MessageToast: ToastProtocol {
    func show() {
        //  UIWindow 최상단에 붙여주고 애니메이션 적용
        let win = UIApplication.shared.connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }
        
        self.frame.origin.y = .zero
        win?.rootViewController?.view.addSubview(self)
        
        UIView.animate(withDuration: 1, animations: {
            self.frame.origin.y = 100
        }, completion: { _ in
            UIView.animate(withDuration: 1, delay: 1, animations: {
                self.frame.origin.y = 80
                self.alpha = .zero
                
            }, completion: { _ in
                win?.rootViewController?.view.willRemoveSubview(self)
            })
        })
    }
    
    
    
    func hide() {
        
    }
}
