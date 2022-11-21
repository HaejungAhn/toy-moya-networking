//
//  BeerTVCell.swift
//  NetworkingEx
//
//  Created by USER on 2022/11/20.
//

import UIKit

import Kingfisher
import SnapKit
import Then

class BeerTVCell: UITableViewCell {

    private let beerImageView = UIImageView()
    private let nameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    func configure(imageURL: String, name: String) {
        self.beerImageView.kf.setImage(with: URL(string: imageURL)!)
        self.nameLabel.text = name
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.contentView.do {
            $0.addSubview(self.beerImageView)
            $0.addSubview(self.nameLabel)
        }

        self.beerImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.clipsToBounds = true
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        self.beerImageView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.width.height.equalTo(60)
        }
        
        self.nameLabel.snp.makeConstraints {
            $0.leading.equalTo(self.beerImageView.snp.trailing).offset(10)
            $0.centerY.trailing.equalToSuperview()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
}
