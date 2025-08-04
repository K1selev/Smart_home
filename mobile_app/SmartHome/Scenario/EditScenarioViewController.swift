//
//  EditScenarioViewController.swift
//  SmartHome
//
//  Created by Сергей Киселев on 24.06.2025.
//


import UIKit
import SnapKit

class EditScenarioViewController: UIViewController {
    
    var existingScenario: SmartScenario?
    var onSave: ((SmartScenario) -> Void)?
    
    private var infoHeader = UIView()
    private var mainView = UIView()
    
    private var backButton = UIButton()
    private var titleLabel = UILabel()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let nameField = UITextField()
    private let ifLabel = UILabel()
    private let thenLabel = UILabel()
    private let saveButton = UIButton()

    private let stackIf = UIStackView()
    private let stackThen = UIStackView()

    private let addIfButton = UIButton(type: .system)
    private let addThenButton = UIButton(type: .system)

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
//        title = existingScenario == nil ? "Новый сценарий" : "Редактировать сценарий"
        view.backgroundColor = .black
        hideKeyboardWhenTappedAround()
        setupUI()
        fillExisting()
    }

    private func setupUI() {
        
        infoHeader.backgroundColor = .black
        mainView.backgroundColor = .white
        mainView.layer.cornerRadius = 22
        mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        mainView.clipsToBounds = true
        
        view.addSubview(infoHeader)
        view.addSubview(mainView)
        
        backButton.setTitle("< Назад", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        titleLabel.text = existingScenario == nil ? "Новый сценарий" : "Редактировать"
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        
        infoHeader.addSubview(backButton)
        infoHeader.addSubview(titleLabel)
        
        scrollView.alwaysBounceVertical = true
        stackIf.axis = .vertical
        stackIf.spacing = 12
        stackThen.axis = .vertical
        stackThen.spacing = 12

        nameField.placeholder = "Название сценария"
        nameField.borderStyle = .roundedRect

        ifLabel.text = "ЕСЛИ"
        ifLabel.font = .boldSystemFont(ofSize: 18)

        thenLabel.text = "ТО"
        thenLabel.font = .boldSystemFont(ofSize: 18)

        [addIfButton, addThenButton].forEach {
            $0.setTitle("+ Добавить", for: .normal)
            $0.setTitleColor(.systemBlue, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        }

        addIfButton.addTarget(self, action: #selector(addCondition), for: .touchUpInside)
        addThenButton.addTarget(self, action: #selector(addAction), for: .touchUpInside)

        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.backgroundColor = .systemGreen
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 12
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        mainView.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [nameField, ifLabel, stackIf, addIfButton, thenLabel, stackThen, addThenButton, saveButton].forEach {
            contentView.addSubview($0)
        }

        layoutUI()
        addCondition()
        addAction()
    }

    private func layoutUI() {
        
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

        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        nameField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.right.equalToSuperview().inset(20)
        }

        ifLabel.snp.makeConstraints {
            $0.top.equalTo(nameField.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }

        stackIf.snp.makeConstraints {
            $0.top.equalTo(ifLabel.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(20)
        }

        addIfButton.snp.makeConstraints {
            $0.top.equalTo(stackIf.snp.bottom).offset(10)
            $0.left.equalToSuperview().inset(20)
        }

        thenLabel.snp.makeConstraints {
            $0.top.equalTo(addIfButton.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }

        stackThen.snp.makeConstraints {
            $0.top.equalTo(thenLabel.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(20)
        }

        addThenButton.snp.makeConstraints {
            $0.top.equalTo(stackThen.snp.bottom).offset(10)
            $0.left.equalToSuperview().inset(20)
        }

        saveButton.snp.makeConstraints {
            $0.top.equalTo(addThenButton.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(30)
            $0.width.equalToSuperview().multipliedBy(0.8)
            $0.height.equalTo(50)
        }
    }

    @objc private func addCondition() {
        let view = ScenarioConditionView()
        stackIf.addArrangedSubview(view)
    }

    @objc private func addAction() {
        let view = ScenarioActionView()
        stackThen.addArrangedSubview(view)
    }

    @objc private func saveTapped() {
        var errors = false

        if nameField.text?.isEmpty ?? true {
            nameField.layer.borderColor = UIColor.red.cgColor
            nameField.layer.borderWidth = 1
            errors = true
        } else {
            nameField.layer.borderWidth = 0
        }

        var conditions: [SmartScenario.Condition] = []
        var actions: [SmartScenario.Action] = []

        for case let conditionView as ScenarioConditionView in stackIf.arrangedSubviews {
            if let condition = conditionView.getCondition() {
                conditions.append(condition)
            } else {
                errors = true
            }
        }

        for case let actionView as ScenarioActionView in stackThen.arrangedSubviews {
            if let action = actionView.getAction() {
                actions.append(action)
            } else {
                errors = true
            }
        }

        if errors || conditions.isEmpty || actions.isEmpty {
            let alert = UIAlertController(
                title: "Ошибка",
                message: "Пожалуйста, заполните все поля корректно",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Ок", style: .default))
            present(alert, animated: true)
            return
        }

        let scenario = SmartScenario(
            name: nameField.text ?? "Без имени",
            conditions: conditions,
            actions: actions
        )

        print("Сохраняем сценарий: \(scenario.name), условий: \(conditions.count), действий: \(actions.count)")

        onSave?(scenario)
        navigationController?.popViewController(animated: true)
    }

    
    private func fillExisting() {
        guard let scenario = existingScenario else { return }

        nameField.text = scenario.name

        // Очистим текущие поля
        stackIf.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stackThen.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Вставим существующие условия
        for condition in scenario.conditions {
            let view = ScenarioConditionView()
            view.setCondition(condition)
            stackIf.addArrangedSubview(view)
        }

        // Вставим действия
        for action in scenario.actions {
            let view = ScenarioActionView()
            view.setAction(action)
            stackThen.addArrangedSubview(view)
        }
    }
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
