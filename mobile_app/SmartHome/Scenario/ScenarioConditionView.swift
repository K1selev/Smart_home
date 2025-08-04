//
//  ScenarioConditionView.swift
//  SmartHome
//
//  Created by Сергей Киселев on 25.06.2025.
//

import UIKit
import SnapKit

class ScenarioConditionView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {

    private let sensorLabel = UILabel()
    private let valueLabel = UILabel()

    private let sensorPicker = UIPickerView()
    private let operatorPicker = UIPickerView()
    private let valueField = UITextField()

    private let sensorTypes = SmartScenario.SensorType.allCases
    private let operators = SmartScenario.ComparisonOperator.allCases

    private var selectedSensor: SmartScenario.SensorType = .gas
    private var selectedOperator: SmartScenario.ComparisonOperator = .greaterThan

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func validate() -> Bool {
        let valid = !(valueField.text?.isEmpty ?? true)
        valueField.layer.borderWidth = valid ? 0 : 1
        valueField.layer.borderColor = valid ? nil : UIColor.red.cgColor
        return valid
    }

    func getCondition() -> SmartScenario.Condition? {
        guard let valueText = valueField.text, let value = Float(valueText) else { return nil }
        return SmartScenario.Condition(type: selectedSensor, comparison: selectedOperator, value: value)
    }

    private func setupUI() {
        sensorLabel.text = "Датчик"
        valueLabel.text = "Значение"

        valueField.borderStyle = .roundedRect
        valueField.keyboardType = .decimalPad

        [sensorPicker, operatorPicker].forEach {
            $0.dataSource = self
            $0.delegate = self
        }

        let hStack = UIStackView(arrangedSubviews: [sensorPicker, operatorPicker])
        hStack.axis = .horizontal
        hStack.distribution = .fillEqually
        hStack.spacing = 10

        let vStack = UIStackView(arrangedSubviews: [sensorLabel, hStack, valueLabel, valueField])
        vStack.axis = .vertical
        vStack.spacing = 0

        addSubview(vStack)
        vStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        sensorPicker.selectRow(0, inComponent: 0, animated: false)
        operatorPicker.selectRow(0, inComponent: 0, animated: false)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerView == sensorPicker ? sensorTypes.count : operators.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerView == sensorPicker ? sensorTypes[row].rawValue : operators[row].rawValue
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == sensorPicker {
            selectedSensor = sensorTypes[row]
        } else {
            selectedOperator = operators[row]
        }
    }
    
    func setCondition(_ condition: SmartScenario.Condition) {
        selectedSensor = condition.type
        selectedOperator = condition.comparison
        valueField.text = String(condition.value)

        sensorPicker.selectRow(SmartScenario.SensorType.allCases.firstIndex(of: selectedSensor) ?? 0, inComponent: 0, animated: false)
        operatorPicker.selectRow(SmartScenario.ComparisonOperator.allCases.firstIndex(of: selectedOperator) ?? 0, inComponent: 0, animated: false)
    }
}
