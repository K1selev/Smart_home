//
//  MainViewController.swift
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
    private let buttonCreate = UIButton()
    
    private let hiddenLEDOnButton = UIButton()
    private let hiddenLEDOffButton = UIButton()
    
    private var collectionView: UICollectionView!
    private var scenarioTimer: Timer?
    private var arduinoCheckTimer: Timer?
    
    private let fullBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let noConnectionBanner = UIView()
    private let noConnectionLabel = UILabel()
    
    private let items: [(image: String, title: String)] = [
        ("lightbulb", "Lightning"),
        ("lock", "Security"),
        ("house", "Door"),
//        ("timer", "AutoWatering")
        ("plus", "Scripts")
    ]
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.string(forKey: "arduinoIP") == nil {
            let connectVC = ArduinoConnectionViewController()
            connectVC.modalPresentationStyle = .fullScreen
            present(connectVC, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupNoConnectionUI()
        setupCollectionView()
        makeConstraints()
        startScenarioMonitoring()
//        startArduinoMonitoring()
    }

    deinit {
        scenarioTimer?.invalidate()
        arduinoCheckTimer?.invalidate()
    }

    func configureUI() {
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        guard let circleImage = UIImage(systemName: "circle.fill")?.withConfiguration(config).withTintColor(.black, renderingMode: .alwaysOriginal),
              let plusImage = UIImage(systemName: "plus")?.withConfiguration(config).withTintColor(.white, renderingMode: .alwaysOriginal) else { return }

        UIGraphicsBeginImageContextWithOptions(circleImage.size, false, 0)
        let rect = CGRect(origin: .zero, size: circleImage.size)
        circleImage.draw(in: rect)
        let plusScale: CGFloat = 0.6
        let plusSize = CGSize(width: rect.width * plusScale, height: rect.height * plusScale)
        let plusOrigin = CGPoint(x: (rect.width - plusSize.width) / 2, y: (rect.height - plusSize.height) / 2)
        let plusRect = CGRect(origin: plusOrigin, size: plusSize)
        plusImage.draw(in: plusRect)
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        buttonCreate.setImage(combinedImage, for: .normal)
        buttonCreate.addTarget(self, action: #selector(createAction), for: .touchUpInside)

        infoHeader.backgroundColor = .black
        mainView.backgroundColor = .black
        mainView.layer.cornerRadius = 22
        mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        titleLabel.text = "Smart home"
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = .boldSystemFont(ofSize: 30)

        titleImg.image = UIImage(named: "smartHome")
        titleImg.clipsToBounds = true
        
        hiddenLEDOnButton.backgroundColor = .black
        hiddenLEDOnButton.alpha = 0.1
        hiddenLEDOnButton.addTarget(self, action: #selector(sendLEDOn), for: .touchUpInside)
        infoHeader.addSubview(hiddenLEDOnButton)

        hiddenLEDOffButton.backgroundColor = .black
        hiddenLEDOffButton.alpha = 0.1
        hiddenLEDOffButton.addTarget(self, action: #selector(sendLEDOff), for: .touchUpInside)
        infoHeader.addSubview(hiddenLEDOffButton)

        [infoHeader, mainView].forEach { view.addSubview($0) }
        infoHeader.addSubview(titleImg)
        infoHeader.addSubview(titleLabel)
        view.addSubview(buttonCreate)
    }

    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let itemWidth = (UIScreen.main.bounds.width - 16 * 3) / 2
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
            make.top.equalTo(infoHeader.snp.top)
            make.leading.trailing.equalToSuperview()
        }

        titleImg.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.trailing.equalToSuperview()
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

        buttonCreate.snp.makeConstraints { make in
            make.centerY.equalTo(mainView.snp.top)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(70)
        }
        hiddenLEDOnButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(5)
            make.leading.equalToSuperview().offset(5)
            make.width.height.equalTo(40)
        }

        hiddenLEDOffButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(5)
            make.trailing.equalToSuperview().offset(-5)
            make.width.height.equalTo(40)
        }
    }

    func setupNoConnectionUI() {
        fullBlurView.alpha = 0
        view.addSubview(fullBlurView)
        fullBlurView.snp.makeConstraints { $0.edges.equalToSuperview() }

        noConnectionBanner.backgroundColor = UIColor.red.withAlphaComponent(0.9)
        noConnectionBanner.layer.cornerRadius = 12
        noConnectionBanner.clipsToBounds = true

        noConnectionLabel.text = "Нет подключения"
        noConnectionLabel.textColor = .white
        noConnectionLabel.font = .boldSystemFont(ofSize: 18)
        noConnectionLabel.textAlignment = .center

        noConnectionBanner.addSubview(noConnectionLabel)
        view.addSubview(noConnectionBanner)

        noConnectionLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }

        noConnectionBanner.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(40)
        }

        noConnectionBanner.isHidden = true
    }

    func showConnectionLostUI() {
        guard noConnectionBanner.isHidden else { return }
        noConnectionBanner.alpha = 0
        fullBlurView.alpha = 0
        noConnectionBanner.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.noConnectionBanner.alpha = 1
            self.fullBlurView.alpha = 1
        }
        disableUserInteraction()
    }

    func hideConnectionLostUI() {
        guard !noConnectionBanner.isHidden else { return }
        UIView.animate(withDuration: 0.3, animations: {
            self.noConnectionBanner.alpha = 0
            self.fullBlurView.alpha = 0
        }) { _ in
            self.noConnectionBanner.isHidden = true
        }
        enableUserInteraction()
    }

    func disableUserInteraction() {
        view.subviews.forEach { $0.isUserInteractionEnabled = false }
        noConnectionBanner.isUserInteractionEnabled = true
    }

    func enableUserInteraction() {
        view.subviews.forEach { $0.isUserInteractionEnabled = true }
    }

    func startArduinoMonitoring() {
        arduinoCheckTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.checkArduinoConnection()
        }
    }

    func checkArduinoConnection() {
        guard let url = URL(string: "\(Constants.baseURL)/ping") else {
            showConnectionLostUI()
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 15.0

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if error != nil || (response as? HTTPURLResponse)?.statusCode != 200 {
                    self.showConnectionLostUI()
                } else {
                    self.hideConnectionLostUI()
                }
            }
        }.resume()
    }

    func startScenarioMonitoring() {
        scenarioTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.checkAndExecuteScenarios()
        }
    }

    func checkAndExecuteScenarios() {
        guard let url = URL(string: "\(Constants.baseURL)/sensors") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let sensor = try? JSONDecoder().decode(SensorData.self, from: data),
                  let savedData = UserDefaults.standard.data(forKey: "scenarios"),
                  let scenarios = try? JSONDecoder().decode([SmartScenario].self, from: savedData) else {
                return
            }

            for scenario in scenarios {
                let allConditionsMet = scenario.conditions.allSatisfy { condition in
                    let sensorValue = self.fetchSensorValue(sensor: sensor, for: condition.type)
                    return self.evaluateCondition(sensorValue: sensorValue, condition: condition)
                }

                if allConditionsMet {
                    for action in scenario.actions {
                        self.sendActionToArduino(action: action)
                    }
                }
            }
        }.resume()
    }

    func fetchSensorValue(sensor: SensorData, for type: SmartScenario.SensorType) -> Float {
        switch type {
        case .gas: return Float(sensor.gas)
        case .fire: return Float(sensor.fire)
        case .temperature: return sensor.temperature
        case .humidity: return sensor.humidity
        case .door: return 0
        case .light: return Float(sensor.light)
        }
    }

    func evaluateCondition(sensorValue: Float, condition: SmartScenario.Condition) -> Bool {
        switch condition.comparison {
        case .greaterThan: return sensorValue > condition.value
        case .lessThan: return sensorValue < condition.value
        case .equal: return sensorValue == condition.value
        }
    }

    func sendActionToArduino(action: SmartScenario.Action) {
        guard let ip = UserDefaults.standard.string(forKey: "arduinoIP") else { return }

        var command = ""
        switch action.type {
        case .openDoor: command = "open"
        case .closeDoor: command = "close"
        case .turnOnRGB: command = "on"
        case .turnOffRGB: command = "off"
        }

        guard let url = URL(string: "\(Constants.baseURL)/cmd?act=\(command)") else { return }
        URLSession.shared.dataTask(with: url).resume()
    }

    // MARK: - Navigation

    @objc func createAction() {
        let vc = ScenariosViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - CollectionView

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
        case "Lightning": destinationVC = LightningViewController()
        case "Security": destinationVC = SecurityViewController()
        case "Door": destinationVC = DoorViewController()
        case "Scripts": destinationVC = ScenariosViewController()
        default: break
        }

        if let vc = destinationVC {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func sendLEDOn() {
        sendManualCommand("on")
        sendManualCommand("on")
    }

    @objc private func sendLEDOff() {
        sendManualCommand("off")
        sendManualCommand("off")
    }
    
    private func sendManualCommand(_ command: String) {
        guard let url = URL(string: "\(Constants.baseURL)/cmd?act=\(command)") else { return }

        URLSession.shared.dataTask(with: url).resume()
    }
}
