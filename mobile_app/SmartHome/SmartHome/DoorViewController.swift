//
//  DoorViewController.swift
//  SmartHome
//
//  Created by Сергей Киселев on 13.05.2025.
//


//import UIKit
//import SnapKit
//
//class DoorViewController: UIViewController {
//    
//    var infoHeader = UIView()
//    var mainView = UIView()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureUI()
//    }
//    
//    func configureUI() {
//        
//        infoHeader.backgroundColor = .black//UIColor(named: "black")
//        
//        mainView.backgroundColor = .systemGray2
//        mainView.clipsToBounds = true
//        mainView.layer.cornerRadius = 22
//        mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        
//        [infoHeader,
//         mainView].forEach {
//            view.addSubview($0)
//        }
//        makeConstraints()
//    }
//    
//    func makeConstraints() {
//        
//        infoHeader.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide)
//            make.leading.equalToSuperview()
//            make.trailing.equalToSuperview()
//            make.height.equalTo(150)
//        }
//        
//        mainView.snp.makeConstraints { make in
//            make.top.equalTo(infoHeader.snp.bottom).offset(-30)
//            make.centerX.equalToSuperview()
//            make.leading.equalToSuperview()
//            make.trailing.equalToSuperview()
//            make.bottom.equalToSuperview()
//        }
//    }
//}
//

import UIKit
import SnapKit

struct DoorEvent: Codable {
    let state: String
    let timestamp: Date
}

class DoorViewController: UIViewController {
    
    private var infoHeader = UIView()
    private var mainView = UIView()
    
    private var backButton = UIButton()
    private var titleLabel = UILabel()
    
    private var stateLabel = UILabel()
    private var currentStateLabel = UILabel()
    
//    private var sensitivityLabel = UILabel()
//    private var sensitivityStepper = UIStepper()
//    private var sensitivityValueLabel = UILabel()
    
    private var historyLabel = UILabel()
    private var tableView = UITableView()
    
    private var actionButton = UIButton()
    
    private var doorEvents: [DoorEvent] = []
    
    private var currentState: String = "Закрыта" {
        didSet {
            currentStateLabel.text = currentState
            updateActionButtonTitle()
            saveEvent(state: currentState)
            tableView.reloadData()
        }
    }
    
    private var sensitivity: Int = 5 {
        didSet {
//            sensitivityValueLabel.text = "\(sensitivity)"
        }
    }
    
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
        loadEvents()
        configureUI()
        configureActions()
    }

    private func configureUI() {
        infoHeader.backgroundColor = .black
        mainView.backgroundColor = .white
        mainView.layer.cornerRadius = 22
        mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        mainView.clipsToBounds = true
        
        view.addSubview(infoHeader)
        view.addSubview(mainView)
        
        backButton.setTitle("< Назад", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        
        titleLabel.text = "Открытие двери"
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        
        infoHeader.addSubview(backButton)
        infoHeader.addSubview(titleLabel)
        
        // Labels and controls
        stateLabel.text = "Текущее состояние:"
        stateLabel.textColor = .darkGray
        
        currentStateLabel.text = currentState
        currentStateLabel.font = .systemFont(ofSize: 16)
        
//        sensitivityLabel.text = "Настройка чувствительности:"
//        sensitivityLabel.textColor = .darkGray
//        
//        sensitivityStepper.minimumValue = 1
//        sensitivityStepper.maximumValue = 10
//        sensitivityStepper.stepValue = 1
//        sensitivityStepper.value = Double(sensitivity)
//        sensitivityValueLabel.text = "\(sensitivity)"
        
        historyLabel.text = "История открытий"
        historyLabel.font = .boldSystemFont(ofSize: 16)
        
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.separatorStyle = .singleLine
        
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        actionButton.backgroundColor = UIColor.darkGray
        actionButton.layer.cornerRadius = 16
        
        updateActionButtonTitle()
        
        [stateLabel, currentStateLabel, historyLabel, tableView, actionButton].forEach {
            mainView.addSubview($0)
        }
        
        makeConstraints()
    }

    private func configureActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
//        sensitivityStepper.addTarget(self, action: #selector(sensitivityChanged), for: .valueChanged)
        actionButton.addTarget(self, action: #selector(toggleDoorState), for: .touchUpInside)
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func sensitivityChanged(_ sender: UIStepper) {
        sensitivity = Int(sender.value)
    }

    @objc private func toggleDoorState() {
        currentState = currentState == "Открыта" ? "Закрыта" : "Открыта"
    }

    private func updateActionButtonTitle() {
        let title = currentState == "Открыта" ? "Закрыть" : "Открыть"
        actionButton.setTitle(title, for: .normal)
    }

    private func makeConstraints() {
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

        stateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.leading.equalToSuperview().offset(16)
        }

        currentStateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(stateLabel)
            make.leading.equalTo(stateLabel.snp.trailing).offset(8)
        }

//        sensitivityLabel.snp.makeConstraints { make in
//            make.top.equalTo(stateLabel.snp.bottom).offset(24)
//            make.leading.equalToSuperview().offset(16)
//        }
//
//        sensitivityStepper.snp.makeConstraints { make in
//            make.centerY.equalTo(sensitivityLabel)
//            make.leading.equalTo(sensitivityLabel.snp.trailing).offset(16)
//        }
//
//        sensitivityValueLabel.snp.makeConstraints { make in
//            make.centerY.equalTo(sensitivityLabel)
//            make.leading.equalTo(sensitivityStepper.snp.trailing).offset(12)
//        }

        historyLabel.snp.makeConstraints { make in
            make.top.equalTo(stateLabel.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(16)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(historyLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(actionButton.snp.top).offset(-16)
        }

        actionButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(30)
            make.height.equalTo(50)
        }
    }

    // MARK: - Persistence

//    private func saveEvent(state: String) {
//        let newEvent = DoorEvent(state: state, timestamp: Date())
//        doorEvents.insert(newEvent, at: 0)
//        if let data = try? JSONEncoder().encode(doorEvents) {
//            UserDefaults.standard.set(data, forKey: "doorEvents")
//        }
//    }
    
    private func saveEvent(state: String) {
        let newEvent = DoorEvent(state: state, timestamp: Date())
        doorEvents.insert(newEvent, at: 0)
        
        // Оставляем только последние 10 событий
        if doorEvents.count > 10 {
            doorEvents = Array(doorEvents.prefix(10))
        }
        
        if let data = try? JSONEncoder().encode(doorEvents) {
            UserDefaults.standard.set(data, forKey: "doorEvents")
        }
    }

//    private func loadEvents() {
//        if let data = UserDefaults.standard.data(forKey: "doorEvents"),
//           let savedEvents = try? JSONDecoder().decode([DoorEvent].self, from: data) {
//            doorEvents = savedEvents
//        }
//    }
    
    private func loadEvents() {
        if let data = UserDefaults.standard.data(forKey: "doorEvents"),
           let savedEvents = try? JSONDecoder().decode([DoorEvent].self, from: data) {
            // Загружаем только последние 10 событий
            doorEvents = Array(savedEvents.prefix(10))
        }
    }
}

extension DoorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doorEvents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = doorEvents[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        cell.textLabel?.text = "\(event.state)\t\t\t\t\(formatter.string(from: event.timestamp))"
        return cell
    }
}
