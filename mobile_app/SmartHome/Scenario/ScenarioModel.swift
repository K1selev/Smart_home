//
//  ScenarioModel.swift
//  SmartHome
//
//  Created by Сергей Киселев on 24.06.2025.
//

struct SmartScenario: Codable {
    var name: String
    var conditions: [Condition]
    var actions: [Action]

    struct Condition: Codable {
        var type: SensorType
        var comparison: ComparisonOperator
        var value: Float
    }

    struct Action: Codable {
        var type: ActionType
    }

    enum SensorType: String, Codable, CaseIterable {
        case gas = "Газ"
        case fire = "Огонь"
        case light = "Освещенность"
        case temperature = "Температура"
        case humidity = "Влажность"
        case door = "Дверь"
    }

    enum ComparisonOperator: String, Codable, CaseIterable {
        case greaterThan = ">"
        case lessThan = "<"
        case equal = "="
    }

    enum ActionType: String, Codable, CaseIterable {
        case openDoor = "Открыть дверь"
        case closeDoor = "Закрыть дверь"
        case turnOnRGB = "Включить RGB"
        case turnOffRGB = "Выключить RGB"
    }
}

extension SmartScenario.ActionType {
    var arduinoCommand: String {
        switch self {
        case .openDoor: return "DOOR_OPEN"
        case .closeDoor: return "DOOR_CLOSE"
        case .turnOnRGB: return "RGB_ON"
        case .turnOffRGB: return "RGB_OFF"
        }
    }
}

extension SmartScenario.SensorType {
    var systemIconName: String {
        switch self {
        case .gas: return "aqi.medium"          // например, значок качества воздуха
        case .fire: return "flame.fill"
        case .light: return "lightbulb.fill"
        case .temperature: return "thermometer"
        case .humidity: return "drop.fill"
        case .door: return "door.left.hand.open"
        }
    }
}
