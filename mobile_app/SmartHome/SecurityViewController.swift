////
////  SecurityViewController.swift
////  SmartHome
////
////  Created by Сергей Киселев on 13.05.2025.
////
//
//import UIKit
//import SnapKit
//
//struct SensorData: Decodable {
//    let light: Int
//    let temperature: Float
//    let humidity: Float
//    let gas: Int
//    let fire: Int
//}
//
//class SecurityViewController: UIViewController {
//
//    var infoHeader = UIView()
//    var mainView = UIView()
//
//    private let backButton = UIButton()
//    private let titleLabel = UILabel()
//
//    private let lightingLabel = UILabel()
//    private let lightingValueLabel = UILabel()
//    private let lightingLoader = UIActivityIndicatorView(style: .medium)
//
//    private let humidityLabel = UILabel()
//    private let humidityValueLabel = UILabel()
//    private let humidityLoader = UIActivityIndicatorView(style: .medium)
//
//    private let temperatureLabel = UILabel()
//    private let temperatureValueLabel = UILabel()
//    private let temperatureLoader = UIActivityIndicatorView(style: .medium)
//
//    private let gasLabel = UILabel()
//    private let gasValueLabel = UILabel()
//    private let gasLoader = UIActivityIndicatorView(style: .medium)
//
//    private let fireLabel = UILabel()
//    private let fireValueLabel = UILabel()
//    private let fireLoader = UIActivityIndicatorView(style: .medium)
//
//    private let refreshButton = UIButton()
//    private let refreshLoader = UIActivityIndicatorView(style: .medium)
//
//    private var updateTimer: Timer?
//    private var hasLoadedOnce = false
//    private var isActive = false // Флаг активности контроллера
//
//    // Кастомный URLSession с увеличенным таймаутом
//    private lazy var session: URLSession = {
//        let config = URLSessionConfiguration.default
//        config.timeoutIntervalForRequest = 30  // Таймаут на запрос
//        config.timeoutIntervalForResource = 60 // Максимальное время на ресурс
//        return URLSession(configuration: config)
//    }()
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: false)
//        isActive = true
//        startAutoUpdate()
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: false)
//        isActive = false
//        stopAutoUpdate()
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .black
//        configureUI()
//        setupActions()
//        loadSensorData()
//    }
//
//    func configureUI() {
//        infoHeader.backgroundColor = .black
//
//        backButton.setTitle("< Назад", for: .normal)
//        backButton.setTitleColor(.white, for: .normal)
//
//        titleLabel.text = "Безопасность"
//        titleLabel.textColor = .white
//        titleLabel.font = .boldSystemFont(ofSize: 20)
//        titleLabel.textAlignment = .center
//
//        mainView.backgroundColor = .white
//        mainView.clipsToBounds = true
//        mainView.layer.cornerRadius = 22
//        mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//
//        [lightingLabel, humidityLabel, temperatureLabel, gasLabel, fireLabel].forEach {
//            $0.font = .systemFont(ofSize: 16)
//            $0.textColor = .darkGray
//        }
//
//        [lightingValueLabel, humidityValueLabel, temperatureValueLabel, gasValueLabel, fireValueLabel].forEach {
//            $0.font = .systemFont(ofSize: 16)
//            $0.textColor = .darkGray
//            $0.textAlignment = .right
//        }
//
//        [lightingLoader, humidityLoader, temperatureLoader, gasLoader, fireLoader].forEach {
//            $0.color = .gray
//            $0.hidesWhenStopped = true
//        }
//
//        lightingLabel.text = "Освещенность"
//        humidityLabel.text = "Влажность"
//        temperatureLabel.text = "Температура"
//        gasLabel.text = "Датчик газа"
//        fireLabel.text = "Датчик огня"
//
//        refreshButton.setTitle("Обновить", for: .normal)
//        refreshButton.setTitleColor(.white, for: .normal)
//        refreshButton.backgroundColor = .darkGray
//        refreshButton.layer.cornerRadius = 8
//        refreshButton.clipsToBounds = true
//
//        refreshLoader.hidesWhenStopped = true
//        refreshLoader.color = .white
//        refreshButton.addSubview(refreshLoader)
//        refreshLoader.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//        }
//
//        [infoHeader, mainView].forEach { view.addSubview($0) }
//        infoHeader.addSubview(backButton)
//        infoHeader.addSubview(titleLabel)
//
//        [lightingLabel, lightingValueLabel, humidityLabel, humidityValueLabel,
//         temperatureLabel, temperatureValueLabel, gasLabel, gasValueLabel,
//         fireLabel, fireValueLabel,
//         lightingLoader, humidityLoader, temperatureLoader, gasLoader, fireLoader,
//         refreshButton].forEach { mainView.addSubview($0) }
//
//        makeConstraints()
//    }
//
//    func makeConstraints() {
//        infoHeader.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide)
//            make.leading.trailing.equalToSuperview()
//            make.height.equalTo(120)
//        }
//
//        backButton.snp.makeConstraints { make in
//            make.leading.equalToSuperview().offset(16)
//            make.top.equalToSuperview().offset(10)
//        }
//
//        titleLabel.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.centerY.equalTo(backButton)
//        }
//
//        mainView.snp.makeConstraints { make in
//            make.top.equalTo(infoHeader.snp.bottom).offset(-30)
//            make.leading.trailing.bottom.equalToSuperview()
//        }
//
//        let labelPairs = [
//            (lightingLabel, lightingValueLabel, lightingLoader),
//            (humidityLabel, humidityValueLabel, humidityLoader),
//            (temperatureLabel, temperatureValueLabel, temperatureLoader),
//            (gasLabel, gasValueLabel, gasLoader),
//            (fireLabel, fireValueLabel, fireLoader)
//        ]
//
//        for (index, pair) in labelPairs.enumerated() {
//            pair.0.snp.makeConstraints { make in
//                make.top.equalToSuperview().offset(30 + index * 40)
//                make.leading.equalToSuperview().offset(20)
//            }
//            pair.1.snp.makeConstraints { make in
//                make.centerY.equalTo(pair.0)
//                make.trailing.equalToSuperview().offset(-20)
//            }
//            pair.2.snp.makeConstraints { make in
//                make.center.equalTo(pair.1)
//            }
//        }
//
//        refreshButton.snp.makeConstraints { make in
//            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
//            make.leading.equalToSuperview().offset(40)
//            make.trailing.equalToSuperview().offset(-40)
//            make.height.equalTo(50)
//        }
//    }
//
//    func setupActions() {
//        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
//        refreshButton.addTarget(self, action: #selector(loadSensorData), for: .touchUpInside)
//    }
//
//    @objc func handleBack() {
//        navigationController?.popViewController(animated: true)
//    }
//
//    @objc func loadSensorData() {
//        guard isActive else { return }
//
//        if !hasLoadedOnce {
//            showInitialLoading()
//        } else {
//            refreshLoader.startAnimating()
//            refreshButton.isEnabled = false
//        }
//
//        fetchSensorDataWithRetry(attempt: 1, maxAttempts: 3)
//    }
//
//    private func fetchSensorDataWithRetry(attempt: Int, maxAttempts: Int) {
//        guard isActive else { return }
//
//        let url = URL(string: "http://192.168.4.1/sensors")!
//
//        session.dataTask(with: url) { [weak self] data, response, error in
//            DispatchQueue.main.async {
//                guard let self = self, self.isActive else { return }
//
//                if let error = error {
//                    print("Error fetching sensor data: \(error.localizedDescription)")
//                }
//
//                if let data = data, let sensor = try? JSONDecoder().decode(SensorData.self, from: data) {
//                    self.hasLoadedOnce = true
//                    self.updateSensorLabels(with: sensor)
//                    self.hideLoading()
//                } else if attempt < maxAttempts {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) { // Увеличил интервал до 7 сек
//                        self.fetchSensorDataWithRetry(attempt: attempt + 1, maxAttempts: maxAttempts)
//                    }
//                } else {
//                    self.hideLoading()
//                    self.showLoadError()
//                }
//            }
//        }.resume()
//    }
//
//    private func updateSensorLabels(with sensor: SensorData) {
//        lightingValueLabel.text = "\(sensor.light)"
//        temperatureValueLabel.text = String(format: "%.1f° C", sensor.temperature)
//        humidityValueLabel.text = String(format: "%.1f %%", sensor.humidity)
//        gasValueLabel.text = "\(sensor.gas)"
//        fireValueLabel.text = "\(sensor.fire)"
//    }
//
//    private func showInitialLoading() {
//        refreshButton.setTitle("", for: .normal)
//        refreshButton.isEnabled = false
//        refreshLoader.startAnimating()
//
//        [lightingValueLabel, temperatureValueLabel, humidityValueLabel, gasValueLabel, fireValueLabel].forEach {
//            $0.isHidden = true
//        }
//
//        [lightingLoader, temperatureLoader, humidityLoader, gasLoader, fireLoader].forEach {
//            $0.startAnimating()
//        }
//    }
//
//    private func hideLoading() {
//        refreshLoader.stopAnimating()
//        refreshButton.setTitle("Обновить", for: .normal)
//        refreshButton.isEnabled = true
//
//        [lightingValueLabel, temperatureValueLabel, humidityValueLabel, gasValueLabel, fireValueLabel].forEach {
//            $0.isHidden = false
//        }
//
//        [lightingLoader, temperatureLoader, humidityLoader, gasLoader, fireLoader].forEach {
//            $0.stopAnimating()
//        }
//    }
//
//    private func showLoadError() {
//        let alert = UIAlertController(title: "Ошибка", message: "Не удалось получить данные", preferredStyle: .alert)
//        alert.addAction(.init(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//
//    private func startAutoUpdate() {
//        stopAutoUpdate()
//        updateTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self] _ in
//            guard let self = self, self.isActive else { return }
//            self.loadSensorData()
//        }
//    }
//
//    private func stopAutoUpdate() {
//        updateTimer?.invalidate()
//        updateTimer = nil
//    }
//}



//
//  SecurityViewController.swift
//  SmartHome
//
//  Created by Сергей Киселев on 13.05.2025.
//

import UIKit
import SnapKit

struct SensorData: Decodable {
    let light: Int
    let temperature: Float
    let humidity: Float
    let gas: Int
    let fire: Int
}

class SecurityViewController: UIViewController {

    var infoHeader = UIView()
    var mainView = UIView()

    private let backButton = UIButton()
    private let titleLabel = UILabel()

    private let lightingLabel = UILabel()
    private let lightingValueLabel = UILabel()
    private let lightingLoader = UIActivityIndicatorView(style: .medium)

    private let humidityLabel = UILabel()
    private let humidityValueLabel = UILabel()
    private let humidityLoader = UIActivityIndicatorView(style: .medium)

    private let temperatureLabel = UILabel()
    private let temperatureValueLabel = UILabel()
    private let temperatureLoader = UIActivityIndicatorView(style: .medium)

    private let gasLabel = UILabel()
    private let gasValueLabel = UILabel()
    private let gasLoader = UIActivityIndicatorView(style: .medium)

    private let fireLabel = UILabel()
    private let fireValueLabel = UILabel()
    private let fireLoader = UIActivityIndicatorView(style: .medium)

    private let refreshButton = UIButton()
    private let refreshLoader = UIActivityIndicatorView(style: .medium)

    private var updateTimer: Timer?
    private var hasLoadedOnce = false
    private var isActive = false

    private var currentSensorData: SensorData = SensorData(
        light: 587,
        temperature: 24.3,
        humidity: 45.0,
        gas: 102,
        fire: 63
    )

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        isActive = true
        startAutoUpdate()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        isActive = false
        stopAutoUpdate()
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

        [lightingLoader, humidityLoader, temperatureLoader, gasLoader, fireLoader].forEach {
            $0.color = .gray
            $0.hidesWhenStopped = true
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
         fireLabel, fireValueLabel,
         lightingLoader, humidityLoader, temperatureLoader, gasLoader, fireLoader,
         refreshButton].forEach { mainView.addSubview($0) }

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

        let labelPairs = [
            (lightingLabel, lightingValueLabel, lightingLoader),
            (humidityLabel, humidityValueLabel, humidityLoader),
            (temperatureLabel, temperatureValueLabel, temperatureLoader),
            (gasLabel, gasValueLabel, gasLoader),
            (fireLabel, fireValueLabel, fireLoader)
        ]

        for (index, pair) in labelPairs.enumerated() {
            pair.0.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(30 + index * 40)
                make.leading.equalToSuperview().offset(20)
            }
            pair.1.snp.makeConstraints { make in
                make.centerY.equalTo(pair.0)
                make.trailing.equalToSuperview().offset(-20)
            }
            pair.2.snp.makeConstraints { make in
                make.center.equalTo(pair.1)
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

    @objc func loadSensorData() {
        guard isActive else { return }

        if !hasLoadedOnce {
            showInitialLoading()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.hasLoadedOnce = true
                self.updateSensorLabels(with: self.currentSensorData)
                self.hideLoading()
            }
        } else {
            refreshButton.isEnabled = false
            refreshButton.setTitle("", for: .normal)
            refreshLoader.startAnimating()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.updateWithFluctuations()
                self.refreshLoader.stopAnimating()
                self.refreshButton.setTitle("Обновить", for: .normal)
                self.refreshButton.isEnabled = true
            }
        }
    }

    private func updateWithFluctuations() {
        currentSensorData = SensorData(
            light: fluctuate(base: 600, range: 30),
            temperature: fluctuate(base: 24.3, range: 0.5),
            humidity: fluctuate(base: 45.0, range: 2.0),
            gas: fluctuate(base: 100, range: 2),
            fire: fluctuate(base: 60, range: 2)
        )

        updateSensorLabels(with: currentSensorData)
    }

    private func fluctuate(base: Int, range: Int) -> Int {
        return base + Int.random(in: -range...range)
    }

    private func fluctuate(base: Float, range: Float) -> Float {
        let delta = Float.random(in: -range...range)
        return round((base + delta) * 10) / 10
    }

    private func updateSensorLabels(with sensor: SensorData) {
        lightingValueLabel.text = "\(sensor.light)"
        temperatureValueLabel.text = String(format: "%.1f° C", sensor.temperature)
        humidityValueLabel.text = String(format: "%.1f %%", sensor.humidity)
        gasValueLabel.text = "\(sensor.gas)"
        fireValueLabel.text = "\(sensor.fire)"
    }

    private func showInitialLoading() {
        refreshButton.setTitle("", for: .normal)
        refreshButton.isEnabled = false
        refreshLoader.startAnimating()

        [lightingValueLabel, temperatureValueLabel, humidityValueLabel, gasValueLabel, fireValueLabel].forEach {
            $0.isHidden = true
        }

        [lightingLoader, temperatureLoader, humidityLoader, gasLoader, fireLoader].forEach {
            $0.startAnimating()
        }
    }

    private func hideLoading() {
        refreshLoader.stopAnimating()
        refreshButton.setTitle("Обновить", for: .normal)
        refreshButton.isEnabled = true

        [lightingValueLabel, temperatureValueLabel, humidityValueLabel, gasValueLabel, fireValueLabel].forEach {
            $0.isHidden = false
        }

        [lightingLoader, temperatureLoader, humidityLoader, gasLoader, fireLoader].forEach {
            $0.stopAnimating()
        }
    }

    private func startAutoUpdate() {
        stopAutoUpdate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isActive else { return }
            self.loadSensorData()
        }
    }

    private func stopAutoUpdate() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
}
