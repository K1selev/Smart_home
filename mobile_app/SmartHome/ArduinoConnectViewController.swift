import UIKit
import SnapKit

class ArduinoConnectionViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let infoHeader = UIView()
    private let titleLabel = UILabel()
    private let titleImageView = UIImageView()
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    private let instructionLabel = UILabel()
    private let statusLabel = UILabel()
    
    private let checkConnectionButton = UIButton(type: .system)
    private let openWiFiSettingsButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - State
    
    private var isCheckingConnection = false {
        didSet {
            DispatchQueue.main.async {
                if self.isCheckingConnection {
                    // Статус "Проверка подключения..."
                    self.statusLabel.text = "Проверка подключения..."
                    self.statusLabel.textColor = .white
                    
                    // Кнопка: скрыть текст и показать лоадер
                    self.checkConnectionButton.setTitle("", for: .normal)
                    self.activityIndicator.startAnimating()
                    self.activityIndicator.isHidden = false
                    self.checkConnectionButton.isEnabled = false
                    self.openWiFiSettingsButton.isEnabled = false
                } else {
                    // Кнопка: вернуть текст и спрятать лоадер
                    self.checkConnectionButton.setTitle("Проверить соединение", for: .normal)
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.checkConnectionButton.isEnabled = true
                    self.openWiFiSettingsButton.isEnabled = true
                }
            }
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Header view
        infoHeader.backgroundColor = .black
        view.addSubview(infoHeader)
        
        // Title Label
        titleLabel.text = "Подключение к Arduino"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textAlignment = .center
        infoHeader.addSubview(titleLabel)
        
        // Title Image
        titleImageView.image = UIImage(systemName: "wifi")?.withRenderingMode(.alwaysTemplate)
        titleImageView.tintColor = .white
        titleImageView.contentMode = .scaleAspectFit
        infoHeader.addSubview(titleImageView)
        
        // Blur effect on image
        blurView.alpha = 0.3
        titleImageView.addSubview(blurView)
        
        // Instruction Label
        instructionLabel.text = "Пожалуйста, подключитесь к Wi-Fi сети\n\"SmartHomeESP8266\" в настройках."
        instructionLabel.textColor = .white
        instructionLabel.font = UIFont.systemFont(ofSize: 18)
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .center
        view.addSubview(instructionLabel)
        
        // Status Label
        statusLabel.text = "Статус подключения: не проверено"
        statusLabel.textColor = .lightGray
        statusLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.lineBreakMode = .byWordWrapping
        view.addSubview(statusLabel)
        
        // Check Connection Button
        checkConnectionButton.setTitle("Проверить соединение", for: .normal)
        checkConnectionButton.setTitleColor(.white, for: .normal)
        checkConnectionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        checkConnectionButton.backgroundColor = UIColor.systemBlue
        checkConnectionButton.layer.cornerRadius = 12
        view.addSubview(checkConnectionButton)
        
        // Activity Indicator
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = true
        checkConnectionButton.addSubview(activityIndicator)
        
        // Open WiFi Settings Button
        openWiFiSettingsButton.setTitle("Открыть настройки Wi-Fi", for: .normal)
        openWiFiSettingsButton.setTitleColor(.white, for: .normal)
        openWiFiSettingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        openWiFiSettingsButton.backgroundColor = UIColor.systemGray
        openWiFiSettingsButton.layer.cornerRadius = 12
        view.addSubview(openWiFiSettingsButton)
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        infoHeader.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(250)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        titleImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(120)
        }
        
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        instructionLabel.snp.makeConstraints { make in
            make.top.equalTo(infoHeader.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(30)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(instructionLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(30)
        }
        
        checkConnectionButton.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(50)
            make.height.equalTo(50)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        openWiFiSettingsButton.snp.makeConstraints { make in
            make.top.equalTo(checkConnectionButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(50)
            make.height.equalTo(44)
        }
    }
    
    // MARK: - Actions
    
    private func setupActions() {
        checkConnectionButton.addTarget(self, action: #selector(checkConnectionButtonTapped), for: .touchUpInside)
        openWiFiSettingsButton.addTarget(self, action: #selector(openWiFiSettingsTapped), for: .touchUpInside)
    }
    
    @objc private func checkConnectionButtonTapped() {
        guard !isCheckingConnection else { return }
        isCheckingConnection = true
        
        let urlString = "\(Constants.baseURL)/ping"
        guard let url = URL(string: urlString) else {
            updateStatus(connected: false, message: "Некорректный URL")
            isCheckingConnection = false
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isCheckingConnection = false
                
                if let _ = data, error == nil {
                    self?.updateStatus(connected: true, message: "Подключено")
                    if let _ = data {
                        UserDefaults.standard.set("ip", forKey: "arduinoIP")
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self?.goToMainScreen()
                    }
                } else {
                    self?.updateStatus(connected: false, message: "Не подключено.\nПроверьте Wi-Fi соединение.")
                }
            }
        }
        task.resume()
    }
    
    @objc private func openWiFiSettingsTapped() {
        if let url = URL(string: "App-Prefs:root=WIFI"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            let alert = UIAlertController(title: "Ошибка", message: "Не удалось открыть настройки Wi-Fi.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            present(alert, animated: true)
        }
    }
    
    private func updateStatus(connected: Bool, message: String) {
        statusLabel.text = message
        statusLabel.textColor = connected ? UIColor.systemGreen : UIColor.systemRed
        checkConnectionButton.backgroundColor = connected ? UIColor.systemGreen : UIColor.systemBlue
    }
    
    private func goToMainScreen() {
           let mainVC = MainViewController()
           if let nav = navigationController {
               nav.popViewController(animated: true)//pushViewController(mainVC, animated: true)
           } else {
               let navVC = UINavigationController(rootViewController: MainViewController())
               navVC.modalPresentationStyle = .fullScreen
               present(navVC, animated: true)
//               mainVC.modalPresentationStyle = .fullScreen
//               present(mainVC, animated: true)
           }
       }
}
