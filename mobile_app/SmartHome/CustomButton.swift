//
//  CustomButton.swift
//  SmartHome
//
//  Created by Сергей Киселев on 14.05.2025.
//

import UIKit

class RoundedButton: UIButton {
    
    init(title: String) {
        super.init(frame: .zero)
        setup(title: title)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup(title: "Кнопка")
    }
    
    private func setup(title: String) {
        setTitle(title, for: .normal)
        backgroundColor = .darkGray
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        layer.cornerRadius = 16
        clipsToBounds = true
    }
}
