//
//  ScenarioActionView.swift
//  SmartHome
//
//  Created by Сергей Киселев on 25.06.2025.
//

import UIKit
import SnapKit

class ScenarioActionView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {

    private let actionPicker = UIPickerView()
    private let actionLabel = UILabel()

    private let actions = SmartScenario.ActionType.allCases
    private var selectedAction: SmartScenario.ActionType = .turnOnRGB

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func validate() -> Bool {
        // нет обязательных полей, всегда валидно
        return true
    }

    func getAction() -> SmartScenario.Action? {
        return SmartScenario.Action(type: selectedAction)
    }

    private func setupUI() {
        actionLabel.text = "Действие"
        actionLabel.font = .systemFont(ofSize: 16, weight: .medium)

        actionPicker.dataSource = self
        actionPicker.delegate = self
        actionPicker.selectRow(0, inComponent: 0, animated: false)

        let vStack = UIStackView(arrangedSubviews: [actionLabel, actionPicker])
        vStack.axis = .vertical
        vStack.spacing = 8

        addSubview(vStack)
        vStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        actions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        actions[row].rawValue
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedAction = actions[row]
    }
    
    func setAction(_ action: SmartScenario.Action) {
        selectedAction = action.type
        actionPicker.selectRow(SmartScenario.ActionType.allCases.firstIndex(of: selectedAction) ?? 0, inComponent: 0, animated: false)
    }

}
