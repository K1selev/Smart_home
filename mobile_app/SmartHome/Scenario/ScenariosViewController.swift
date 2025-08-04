//
//  ScenariosViewController.swift
//  SmartHome
//
//  Created by Сергей Киселев on 24.06.2025.
//

import UIKit
import SnapKit

final class ScenariosViewController: UIViewController {

    private var scenarios: [SmartScenario] = []
    private var selectedIndices = Set<Int>()
    
    private var infoHeader = UIView()
    private var mainView = UIView()
    
    private var backButton = UIButton()
    private var addButton = UIButton()
    private var titleLabel = UILabel()

    private let tableView = UITableView()
    private let executeButton = UIButton()
    
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

        setupUI()
        loadScenarios()
        loadSelectedIndices()
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
        
        addButton.setImage(UIImage(systemName: "plus"), for: .normal) // Устанавливаем SF Symbol "plus"
        addButton.tintColor = .white // Цвет иконки
        addButton.addTarget(self, action: #selector(addScenario), for: .touchUpInside)

        
        titleLabel.text = "Сценарии"
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        
        infoHeader.addSubview(backButton)
        infoHeader.addSubview(addButton)
        infoHeader.addSubview(titleLabel)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ScenarioCell.self, forCellReuseIdentifier: "ScenarioCell")
        tableView.separatorStyle = .none
        tableView.allowsSelection = true // Для редактирования по нажатию

        executeButton.setTitle("Выполнить выбранные", for: .normal)
        executeButton.backgroundColor = .systemGreen
        executeButton.setTitleColor(.white, for: .normal)
        executeButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        executeButton.layer.cornerRadius = 12
        executeButton.addTarget(self, action: #selector(executeSelected), for: .touchUpInside)

        mainView.addSubview(tableView)
        mainView.addSubview(executeButton)
        
        infoHeader.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(120)
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(10)
        }
        
        addButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
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

        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.left.right.equalToSuperview().inset(16)
            $0.bottom.equalTo(executeButton.snp.top).offset(-10)
        }

        executeButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(16)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.9)
            $0.height.equalTo(50)
        }

//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addScenario))
    }

    private func loadScenarios() {
        if let data = UserDefaults.standard.data(forKey: "scenarios") {
            do {
                let decoded = try JSONDecoder().decode([SmartScenario].self, from: data)
                self.scenarios = decoded
                print("Загружено сценариев: \(decoded.count)")
            } catch {
                print("Ошибка декодирования сценариев: \(error)")
            }
        } else {
            print("Нет сохранённых сценариев.")
        }

        tableView.reloadData()
    }


    private func saveScenarios() {
        if let data = try? JSONEncoder().encode(scenarios) {
            UserDefaults.standard.set(data, forKey: "scenarios")
        }
    }
    
    private func saveSelectedIndices() {
        let array = Array(selectedIndices)
        UserDefaults.standard.set(array, forKey: "selectedScenarioIndices")
    }

    private func loadSelectedIndices() {
        if let array = UserDefaults.standard.array(forKey: "selectedScenarioIndices") as? [Int] {
            selectedIndices = Set(array)
        }
    }

    @objc private func addScenario() {
        let vc = EditScenarioViewController()
        vc.onSave = { [weak self] newScenario in
            self?.scenarios.append(newScenario)
            self?.saveScenarios()
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func executeSelected() {
        let selectedScenarios = selectedIndices
            .filter { $0 < scenarios.count }
            .map { scenarios[$0] }
        
        for scenario in selectedScenarios {
            print("Выполняем сценарий: \(scenario.name)")
        }

        let alert = UIAlertController(title: "Выполнено", message: "Выбранные сценарии выполнены", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)

//        selectedIndices.removeAll()
        tableView.reloadData()
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
}

extension ScenariosViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return scenarios.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = EditScenarioViewController()
        vc.existingScenario = scenarios[indexPath.section]
        vc.onSave = { [weak self] updated in
            self?.scenarios[indexPath.section] = updated
            self?.saveScenarios()
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let spacer = UIView()
        spacer.backgroundColor = .clear
        return spacer
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScenarioCell", for: indexPath) as? ScenarioCell else {
            return UITableViewCell()
        }

        let scenario = scenarios[indexPath.section]
        let isSelected = selectedIndices.contains(indexPath.section)

        cell.configure(with: scenario, selected: isSelected)
        cell.onCheckboxToggle = { [weak self] in
            if isSelected {
                self?.selectedIndices.remove(indexPath.section)
            } else {
                self?.selectedIndices.insert(indexPath.section)
            }
            self?.saveSelectedIndices()
            self?.tableView.reloadSections([indexPath.section], with: .automatic)
        }

        return cell
    }

    // Удаление сценария свайпом
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            scenarios.remove(at: indexPath.section)

            // Корректно пересчитываем выбранные индексы
            selectedIndices = Set(selectedIndices.compactMap {
                $0 > indexPath.section ? $0 - 1 : ($0 == indexPath.section ? nil : $0)
            })

            saveScenarios()
            saveSelectedIndices()
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
        }
    }
}
