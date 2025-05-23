//
//  SecurityViewController.swift
//  SmartHome
//
//  Created by Сергей Киселев on 13.05.2025.
//
import UIKit
import SnapKit

struct SensorData: Decodable {
    let light: Int         // 0–1023
    let temperature: Float // °C
    let humidity: Float    // %
    let gas: Int           // 0–1023
    let fire: Int          // 0–1023
}

class SecurityViewController: UIViewController {
    
    var infoHeader = UIView()
    var mainView = UIView()
    
    private let backButton = UIButton()
    private let titleLabel = UILabel()
    
    private let lightingLabel = UILabel()
    private let lightingValueLabel = UILabel()
    
    private let humidityLabel = UILabel()
    private let humidityValueLabel = UILabel()
    
    private let temperatureLabel = UILabel()
    private let temperatureValueLabel = UILabel()
    
    private let gasLabel = UILabel()
    private let gasValueLabel = UILabel()
    
    private let fireLabel = UILabel()
    private let fireValueLabel = UILabel()
    
    private let refreshButton = UIButton()
    private let refreshLoader = UIActivityIndicatorView(style: .medium)

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureUI()
        setupActions()
        loadSensorData()
    }

    func configureUI() {
        infoHeader.backgroundColor = .black
        
        backButton.setTitle("< Назад", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        
        titleLabel.text = "Безопасность"
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        
        mainView.backgroundColor = .white
        mainView.clipsToBounds = true
        mainView.layer.cornerRadius = 22
        mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        [lightingLabel, humidityLabel, temperatureLabel, gasLabel, fireLabel].forEach {
            $0.font = .systemFont(ofSize: 16)
            $0.textColor = .darkGray
        }

        [lightingValueLabel, humidityValueLabel, temperatureValueLabel, gasValueLabel, fireValueLabel].forEach {
            $0.font = .systemFont(ofSize: 16)
            $0.textColor = .darkGray
            $0.textAlignment = .right
        }

        lightingLabel.text = "Освещенность"
        humidityLabel.text = "Влажность"
        temperatureLabel.text = "Температура"
        gasLabel.text = "Датчик газа"
        fireLabel.text = "Датчик огня"
        
        refreshButton.setTitle("Обновить", for: .normal)
        refreshButton.setTitleColor(.white, for: .normal)
        refreshButton.backgroundColor = .darkGray
        refreshButton.layer.cornerRadius = 8
        refreshButton.clipsToBounds = true
        
        refreshLoader.hidesWhenStopped = true
        refreshLoader.color = .white
        refreshButton.addSubview(refreshLoader)
        refreshLoader.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        [infoHeader, mainView].forEach { view.addSubview($0) }
        infoHeader.addSubview(backButton)
        infoHeader.addSubview(titleLabel)
        
        [lightingLabel, lightingValueLabel, humidityLabel, humidityValueLabel,
         temperatureLabel, temperatureValueLabel, gasLabel, gasValueLabel,
         fireLabel, fireValueLabel, refreshButton].forEach { mainView.addSubview($0) }

        makeConstraints()
    }

    func makeConstraints() {
        infoHeader.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(120)
        }
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(10)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton)
        }
        
        mainView.snp.makeConstraints { make in
            make.top.equalTo(infoHeader.snp.bottom).offset(-30)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        let labels = [
            (lightingLabel, lightingValueLabel),
            (humidityLabel, humidityValueLabel),
            (temperatureLabel, temperatureValueLabel),
            (gasLabel, gasValueLabel),
            (fireLabel, fireValueLabel)
        ]
        
        for (index, pair) in labels.enumerated() {
            pair.0.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(30 + index * 40)
                make.leading.equalToSuperview().offset(20)
            }
            pair.1.snp.makeConstraints { make in
                make.centerY.equalTo(pair.0)
                make.trailing.equalToSuperview().offset(-20)
            }
        }
        
        refreshButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
            make.height.equalTo(50)
        }
    }

    func setupActions() {
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        refreshButton.addTarget(self, action: #selector(loadSensorData), for: .touchUpInside)
    }

    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }

//    @objc func loadSensorData() {
//        startLoading()
//        
//        let url = URL(string: "http://192.168.5.47/sensors")!
//        URLSession.shared.dataTask(with: url) { data, resp, err in
//            DispatchQueue.main.async {
//                self.stopLoading()
//                guard let data = data,
//                      let sensor = try? JSONDecoder().decode(SensorData.self, from: data) else {
//                    self.showLoadError()
//                    return
//                }
//                self.lightingValueLabel.text    = "\(sensor.light)"
//                self.temperatureValueLabel.text = String(format: "%.1f° C", sensor.temperature)
//                self.humidityValueLabel.text    = String(format: "%.1f %%", sensor.humidity)
//                self.gasValueLabel.text         = "\(sensor.gas)"
//                self.fireValueLabel.text        = "\(sensor.fire)"
//            }
//        }.resume()
//    }
    
    @objc func loadSensorData() {
        startLoading()
        fetchSensorDataWithRetry(attempt: 1, maxAttempts: 3)
    }

    private func fetchSensorDataWithRetry(attempt: Int, maxAttempts: Int) {
        let url = URL(string: "http://192.168.5.47/sensors")!
        
        URLSession.shared.dataTask(with: url) { data, resp, err in
            DispatchQueue.main.async {
                if let data = data, let sensor = try? JSONDecoder().decode(SensorData.self, from: data) {
                    self.updateSensorLabels(with: sensor)
                    self.stopLoading()
                } else if attempt < maxAttempts {
                    // Повтор через 1 секунду
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.fetchSensorDataWithRetry(attempt: attempt + 1, maxAttempts: maxAttempts)
                    }
                } else {
                    self.stopLoading()
                    self.showLoadError()
                }
            }
        }.resume()
    }

    private func updateSensorLabels(with sensor: SensorData) {
        lightingValueLabel.text    = "\(sensor.light)"
        temperatureValueLabel.text = String(format: "%.1f° C", sensor.temperature)
        humidityValueLabel.text    = String(format: "%.1f %%", sensor.humidity)
        gasValueLabel.text         = "\(sensor.gas)"
        fireValueLabel.text        = "\(sensor.fire)"
    }

    
    private func showLoadError() {
        let a = UIAlertController(title: "Ошибка", message: "Не удалось получить данные", preferredStyle: .alert)
        a.addAction(.init(title: "OK", style: .default))
        present(a, animated: true)
    }

    
    private func startLoading() {
        refreshButton.setTitle("", for: .normal)
        refreshLoader.startAnimating()
        refreshButton.isEnabled = false
    }
    
    private func stopLoading() {
        refreshLoader.stopAnimating()
        refreshButton.setTitle("Обновить", for: .normal)
        refreshButton.isEnabled = true
    }
}
