//
//  AutoWateringViewController.swift
//  SmartHome
//
//  Created by Сергей Киселев on 13.05.2025.
//

import UIKit
import SnapKit

class AutoWateringViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    struct WateringEvent: Codable {
        let date: Date
    }

    // MARK: - UI Elements

    let infoHeader = UIView()
    let backButton = UIButton()
    let titleLabel = UILabel()

    let mainView = UIView()
    
    let soilMoistureLabel = UILabel()
    let soilMoistureValue = UILabel()

    let waterLevelLabel = UILabel()
    let waterLevelValue = UILabel()

    let scheduledLabel = UILabel()
    let scheduledBadge = UILabel()
    let expandButton = UIButton()

    let scheduleTable = UITableView()
    let datePicker = UIDatePicker()
    let scheduleButton = UIButton()

    let waterNowButton = UIButton()
    let stopwatchButton = UIButton()

    var isExpanded = false

    var scheduledWaterings: [WateringEvent] = [] {
        didSet {
            updateScheduledBadge()
            saveScheduledWaterings()
            scheduleTable.reloadData()
            scheduleTable.isHidden = scheduledWaterings.isEmpty || !isExpanded
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
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureUI()
        loadScheduledWaterings()
    }

    // MARK: - UI Setup

    func configureUI() {
        setupHeader()
        setupMainView()
        makeConstraints()
    }

    func setupHeader() {
        infoHeader.backgroundColor = .black
        view.addSubview(infoHeader)

        backButton.setTitle("< Назад", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        infoHeader.addSubview(backButton)

        titleLabel.text = "Автополив"
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 20)
        infoHeader.addSubview(titleLabel)
    }

    func setupMainView() {
        mainView.backgroundColor = .systemGray6
        mainView.layer.cornerRadius = 22
        mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(mainView)

        // Labels
        soilMoistureLabel.text = "Влажность почвы"
        soilMoistureValue.text = "30"
        waterLevelLabel.text = "Уровень воды"
        waterLevelValue.text = "30"

        [soilMoistureLabel, soilMoistureValue,
         waterLevelLabel, waterLevelValue].forEach {
            $0.font = .systemFont(ofSize: 17)
            mainView.addSubview($0)
        }

        // Запланированный полив
        scheduledLabel.text = "Запланированный полив"
        scheduledLabel.font = .systemFont(ofSize: 17)

        scheduledBadge.text = "0"
        scheduledBadge.textColor = .white
        scheduledBadge.backgroundColor = .red
        scheduledBadge.textAlignment = .center
        scheduledBadge.layer.cornerRadius = 10
        scheduledBadge.clipsToBounds = true
        scheduledBadge.font = .systemFont(ofSize: 14)

        mainView.addSubview(scheduledLabel)
        mainView.addSubview(scheduledBadge)

        expandButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        expandButton.tintColor = .gray
        expandButton.addTarget(self, action: #selector(toggleExpand), for: .touchUpInside)
        mainView.addSubview(expandButton)

        // Table
        scheduleTable.dataSource = self
        scheduleTable.delegate = self
        scheduleTable.isHidden = true
        mainView.addSubview(scheduleTable)

        // DatePicker
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.isHidden = true
        datePicker.minimumDate = Date()
        mainView.addSubview(datePicker)

        // Запланировать
        scheduleButton.setTitle("Запланировать", for: .normal)
        scheduleButton.backgroundColor = .darkGray
        scheduleButton.layer.cornerRadius = 10
        scheduleButton.addTarget(self, action: #selector(addSchedule), for: .touchUpInside)
        scheduleButton.isHidden = true
        mainView.addSubview(scheduleButton)

        // Полить и секундомер
        waterNowButton.setTitle("Полить", for: .normal)
        waterNowButton.backgroundColor = .darkGray
        waterNowButton.layer.cornerRadius = 10
        mainView.addSubview(waterNowButton)

        stopwatchButton.setImage(UIImage(systemName: "clock"), for: .normal)
        stopwatchButton.tintColor = .darkGray
        stopwatchButton.addTarget(self, action: #selector(toggleExpand), for: .touchUpInside)
        mainView.addSubview(stopwatchButton)
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

        soilMoistureLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.equalToSuperview().offset(16)
        }

        soilMoistureValue.snp.makeConstraints { make in
            make.centerY.equalTo(soilMoistureLabel)
            make.trailing.equalToSuperview().inset(16)
        }

        waterLevelLabel.snp.makeConstraints { make in
            make.top.equalTo(soilMoistureLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
        }

        waterLevelValue.snp.makeConstraints { make in
            make.centerY.equalTo(waterLevelLabel)
            make.trailing.equalToSuperview().inset(16)
        }

        scheduledLabel.snp.makeConstraints { make in
            make.top.equalTo(waterLevelLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
        }

        scheduledBadge.snp.makeConstraints { make in
            make.centerY.equalTo(scheduledLabel)
            make.leading.equalTo(scheduledLabel.snp.trailing).offset(8)
            make.width.height.equalTo(20)
        }

        expandButton.snp.makeConstraints { make in
            make.centerY.equalTo(scheduledLabel)
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(24)
        }

        scheduleTable.snp.makeConstraints { make in
            make.top.equalTo(scheduledLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(100)
        }

        datePicker.snp.makeConstraints { make in
            make.top.equalTo(scheduleTable.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        scheduleButton.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }

        waterNowButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(stopwatchButton.snp.leading).offset(-12)
            make.height.equalTo(50)
        }

        stopwatchButton.snp.makeConstraints { make in
            make.centerY.equalTo(waterNowButton)
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(50)
        }
    }

    // MARK: - Actions

    @objc func toggleExpand() {
        isExpanded.toggle()
        datePicker.isHidden = !isExpanded
        scheduleButton.isHidden = !isExpanded
        scheduleTable.isHidden = !isExpanded || scheduledWaterings.isEmpty

        UIView.animate(withDuration: 0.3) {
            self.expandButton.transform = self.isExpanded ? CGAffineTransform(rotationAngle: .pi / 2) : .identity
        }
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc func addSchedule() {
        let newEvent = WateringEvent(date: datePicker.date)
        scheduledWaterings.append(newEvent)
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduledWaterings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM в HH:mm"
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let event = scheduledWaterings[indexPath.row]
        cell.textLabel?.text = "Полить \(dateFormatter.string(from: event.date))"
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            scheduledWaterings.remove(at: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Удалить"
    }

    // MARK: - Storage

    func saveScheduledWaterings() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(scheduledWaterings) {
            UserDefaults.standard.set(encoded, forKey: "ScheduledWaterings")
        }
    }

    func loadScheduledWaterings() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: "ScheduledWaterings"),
           let decoded = try? decoder.decode([WateringEvent].self, from: data) {
            scheduledWaterings = decoded
        }
    }

    func updateScheduledBadge() {
        scheduledBadge.text = "\(scheduledWaterings.count)"
        scheduledBadge.isHidden = scheduledWaterings.isEmpty
    }
}
