//
//  ViewController.swift
//  SmartHome
//
//  Created by Сергей Киселев on 13.05.2025.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    
    var infoHeader = UIView()
    var mainView = UIView()
    private let titleLabel = UILabel()
    private let titleImg = UIImageView()
    let blurView = UIVisualEffectView()
    
    private var collectionView: UICollectionView!
    
    private let items: [(image: String, title: String)] = [
        ("lightbulb", "Lightning"),
        ("lock", "Security"),
        ("house", "Door"),
        ("timer", "AutoWatering")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupBlurView()
    }
    
    func configureUI() {
        
        infoHeader.backgroundColor = .black
        mainView.backgroundColor = .black
        mainView.clipsToBounds = true
        mainView.layer.cornerRadius = 22
        mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        titleLabel.text = "Smart home"
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = .boldSystemFont(ofSize: 30)
        
        titleImg.image = UIImage(named: "smartHome")
//        titleImg.translatesAutoresizingMaskIntoConstraints = false
        titleImg.clipsToBounds = true
//        titleImg.layer.cornerRadius = 14
        
        [infoHeader, mainView].forEach { view.addSubview($0) }
        infoHeader.addSubview(titleImg)
        infoHeader.addSubview(titleLabel)
        
        setupCollectionView()
        makeConstraints()
    }
    
    func setupBlurView() {
        let blurEffect = UIBlurEffect(style: .dark) // Можешь попробовать .dark или .regular
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.5
//        blurView.layer.cornerRadius = 16
//        blurView.clipsToBounds = true
        
        titleImg.addSubview(blurView)
        
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let itemWidth = (UIScreen.main.bounds.width - 16*3) / 2
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(DeviceCell.self, forCellWithReuseIdentifier: "DeviceCell")
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        
        mainView.addSubview(collectionView)
    }
    
    func makeConstraints() {
        infoHeader.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(360)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(infoHeader.snp.top)//.offset(10)
            make.leading.trailing.equalToSuperview()
        }
        
        titleImg.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.equalToSuperview()//.offset(10)
            make.trailing.equalToSuperview()//.offset(-10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        mainView.snp.makeConstraints { make in
            make.top.equalTo(infoHeader.snp.bottom).offset(-30)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeviceCell", for: indexPath) as? DeviceCell else {
            return UICollectionViewCell()
        }
        let item = items[indexPath.row]
        cell.configure(with: item.image, title: item.title)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let selectedItem = items[indexPath.row].title
            var destinationVC: UIViewController?
            
            switch selectedItem {
            case "Lightning":
                destinationVC = LightningViewController()
            case "Security":
                destinationVC = SecurityViewController()
            case "Door":
                destinationVC = DoorViewController()
            case "AutoWatering":
                destinationVC = AutoWateringViewController()
            default:
                break
            }
            
            if let vc = destinationVC {
                navigationController?.pushViewController(vc, animated: true)
            }
        }
}
