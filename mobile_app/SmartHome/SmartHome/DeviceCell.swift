//
//  DeviceCell.swift
//  SmartHome
//
//  Created by Сергей Киселев on 13.05.2025.
//

import UIKit

class DeviceCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        contentView.clipsToBounds = false
        
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.tintColor = .gray
        
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textAlignment = .center
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-10)
//            make.leading.equalToSuperview().offset(10)
//            make.trailing.equalToSuperview().offset(-10)
            make.height.width.equalTo(60)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
//            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    func configure(with imageName: String, title: String) {
        imageView.image = UIImage(systemName: imageName)
        titleLabel.text = title
    }
}
