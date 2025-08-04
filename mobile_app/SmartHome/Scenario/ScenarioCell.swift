//
//  ScenarioCell.swift
//  SmartHome
//
//  Created by Сергей Киселев on 24.06.2025.
//
//
//import UIKit
//
//class ScenarioCell: UITableViewCell {
//
//    private let nameLabel = UILabel()
//    private let checkbox = UIButton(type: .system)
//
//    var onCheckboxToggle: (() -> Void)?
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupUI()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupUI() {
//        backgroundColor = .secondarySystemBackground
//        layer.cornerRadius = 12
//        clipsToBounds = true
//
//        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
//        nameLabel.numberOfLines = 2
//
//        checkbox.tintColor = .systemBlue
//        checkbox.setImage(UIImage(systemName: "circle"), for: .normal)
//        checkbox.addTarget(self, action: #selector(toggleCheckbox), for: .touchUpInside)
//
//        contentView.addSubview(nameLabel)
//        contentView.addSubview(checkbox)
//
//        nameLabel.snp.makeConstraints {
//            $0.left.equalToSuperview().inset(16)
//            $0.centerY.equalToSuperview()
//            $0.right.equalTo(checkbox.snp.left).offset(-10)
//        }
//
//        checkbox.snp.makeConstraints {
//            $0.centerY.equalToSuperview()
//            $0.right.equalToSuperview().inset(16)
//            $0.width.height.equalTo(30)
//        }
//    }
//
//    func configure(with scenario: SmartScenario, selected: Bool) {
//        nameLabel.text = scenario.name
//        let imageName = selected ? "checkmark.circle.fill" : "circle"
//        checkbox.setImage(UIImage(systemName: imageName), for: .normal)
//        checkbox.tintColor = selected ? .systemGreen : .systemGray3
//    }
//
//    @objc private func toggleCheckbox() {
//        onCheckboxToggle?()
//    }
//}



import UIKit

class ScenarioCell: UITableViewCell {

    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let sensorIconStack = UIStackView()
    private let checkbox = UIButton(type: .system)

    var onCheckboxToggle: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 12
        clipsToBounds = true

        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        nameLabel.numberOfLines = 1

        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = .gray
        descriptionLabel.numberOfLines = 2

        sensorIconStack.axis = .horizontal
        sensorIconStack.spacing = 6
        sensorIconStack.distribution = .fillEqually
        sensorIconStack.alignment = .center

        checkbox.tintColor = .systemBlue
        checkbox.setImage(UIImage(systemName: "circle"), for: .normal)
        checkbox.addTarget(self, action: #selector(toggleCheckbox), for: .touchUpInside)

        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(sensorIconStack)
        contentView.addSubview(checkbox)

        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.left.equalToSuperview().inset(16)
            $0.right.equalTo(checkbox.snp.left).offset(-10)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.left.right.equalTo(nameLabel)
        }

        sensorIconStack.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(6)
            $0.left.equalTo(nameLabel)
            $0.bottom.equalToSuperview().inset(10)
            $0.height.equalTo(20)
        }

        checkbox.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(16)
            $0.width.height.equalTo(30)
        }
    }

    func configure(with scenario: SmartScenario, selected: Bool) {
        nameLabel.text = scenario.name
        descriptionLabel.text = scenarioSummary(scenario)

        let imageName = selected ? "checkmark.circle.fill" : "circle"
        checkbox.setImage(UIImage(systemName: imageName), for: .normal)
        checkbox.tintColor = selected ? .systemGreen : .systemGray3

        setupSensorIcons(for: scenario)
    }

    private func scenarioSummary(_ scenario: SmartScenario) -> String {
        let conditions = scenario.conditions.map {
            "\($0.type.rawValue) \($0.comparison.rawValue) \($0.value)"
        }.joined(separator: ", ")

        let actions = scenario.actions.map {
            $0.type.rawValue
        }.joined(separator: ", ")

        return "\(conditions) → \(actions)"
    }

    private func setupSensorIcons(for scenario: SmartScenario) {
        sensorIconStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let uniqueSensors = Set(scenario.conditions.map { $0.type })

        for sensor in uniqueSensors {
            let icon = UIImageView(image: UIImage(systemName: sensor.systemIconName))
            icon.tintColor = .label
            icon.contentMode = .scaleAspectFit
            sensorIconStack.addArrangedSubview(icon)
        }
    }
    @objc private func toggleCheckbox() {
        onCheckboxToggle?()
    }
}
