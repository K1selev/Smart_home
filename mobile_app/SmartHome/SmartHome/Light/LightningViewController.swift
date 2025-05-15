//
//  LightningViewController.swift
//  SmartHome
//
//  Created by Сергей Киселев on 13.05.2025.
//

import UIKit
import SnapKit

class LightningViewController: UIViewController {
    
    private let infoHeader = UIView()
    private let backButton = UIButton()
    private let titleLabel = UILabel()
    private let mainView = UIView()
    
    private let lightSwitch = UISwitch()
    private let lightButton = UIButton()
    private let lightLabel = UILabel()
    
    private let colorLabel = UILabel()
    private let colorWheelView = ColorWheelView()
    private let selectedLightButton = UIButton()
    
    private let brightnessLabel = UILabel()
    private let brightnessSlider = UISlider()
    
    private let saveButton = RoundedButton(title: "Сохранить")
    
    private var isLightOn = false
    private var selectedColor: UIColor = .systemYellow
    private var brightnessValue: Float = 1.0
    
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
        updateLightButtonAppearance()
        configureUI()
    }
    
    private func configureUI() {
        infoHeader.backgroundColor = .black
        mainView.backgroundColor = .white
        mainView.layer.cornerRadius = 22
        mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        mainView.clipsToBounds = true
        
        
        backButton.setTitle("< Назад", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        titleLabel.text = "Освещение"
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        lightLabel.text = "Свет"
        lightSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        colorLabel.text = "Выберите цвет"
        
        selectedLightButton.setImage(UIImage(systemName: "lightbulb"), for: .normal)
        selectedLightButton.tintColor = .gray
        selectedLightButton.contentMode = .scaleAspectFit
        selectedLightButton.clipsToBounds = true
        selectedLightButton.addTarget(self, action: #selector(toggleSwitchState), for: .touchUpInside)
        
        
        brightnessLabel.text = "Яркость"
        brightnessSlider.value = brightnessValue
        brightnessSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)

        colorWheelView.onColorSelected = { color in
            self.selectedColor = color
            self.selectedLightButton.tintColor = color
            let imageName = self.isLightOn ? "lightbulb.fill" : "lightbulb"
            self.selectedLightButton.setImage(UIImage(systemName: imageName), for: .normal)
        }
        
        saveButton.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        
        view.addSubview(infoHeader)
        infoHeader.addSubview(backButton)
        infoHeader.addSubview(titleLabel)
        
        view.addSubview(mainView)
        [lightLabel, lightSwitch, colorLabel, colorWheelView,
         selectedLightButton, brightnessLabel, brightnessSlider, saveButton].forEach {
            mainView.addSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
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
        
        lightLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        lightSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(lightLabel)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        colorLabel.snp.makeConstraints { make in
            make.top.equalTo(lightLabel.snp.bottom).offset(24)
            make.leading.equalTo(lightLabel)
        }
        
        colorWheelView.snp.makeConstraints { make in
            make.top.equalTo(colorLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(300)
        }
        
        selectedLightButton.snp.makeConstraints { make in
            make.centerY.equalTo(colorWheelView.snp.centerY)//.offset(12)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        brightnessLabel.snp.makeConstraints { make in
            make.top.equalTo(colorWheelView.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(20)
        }
        
        brightnessSlider.snp.makeConstraints { make in
            make.centerY.equalTo(brightnessLabel)
            make.leading.equalTo(brightnessLabel.snp.trailing).offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        saveButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }
    }
    
    @objc private func toggleSwitchState() {
        lightSwitch.setOn(!lightSwitch.isOn, animated: true)
        lightSwitch.sendActions(for: .valueChanged)
    }
    
    private func updateLightButtonAppearance() {
        colorWheelView.onColorSelected = { color in
            self.selectedColor = color
            self.selectedLightButton.tintColor = color
            let imageName = self.isLightOn ? "lightbulb.fill" : "lightbulb"
            self.selectedLightButton.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }
    
    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        isLightOn = sender.isOn
        self.selectedLightButton.tintColor = selectedColor
        let imageName = self.isLightOn ? "lightbulb.fill" : "lightbulb"
        self.selectedLightButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc private func sliderChanged(_ sender: UISlider) {
        brightnessValue = sender.value
    }
    
    @objc private func handleSave() {
        var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            selectedColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        
        print("Свет: \(isLightOn ? "включен" : "выключен")")
        print("Цвет: \(selectedColor.accessibilityName)")
        print(String(format: "Цвет: R: %.0f, G: %.0f, B: %.0f", red * 255, green * 255, blue * 255))
        print("Яркость: \(brightnessValue)")
    }
}
