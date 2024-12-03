//
//  AddressInputView.swift
//  MyMapsApp
//
//  Created by samh on 03/12/2024.
//

import UIKit

class AddressInputView: UIView, UITextFieldDelegate {
    
    let startAddressField: UITextField = {
        let field = UITextField()
        field.placeholder = "Starting Address"
        field.borderStyle = .roundedRect
        return field
    }()
    
    let endAddressField: UITextField = {
        let field = UITextField()
        field.placeholder = "Destination Address"
        field.borderStyle = .roundedRect
        return field
    }()
    
    let routeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show Route", for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(named: "AccentColor")
        button.layer.cornerRadius = 7.0
        button.layer.masksToBounds = true
        button.heightAnchor.constraint(equalToConstant: 37).isActive = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        let stackView = UIStackView(arrangedSubviews: [startAddressField, endAddressField, routeButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        startAddressField.delegate = self
        endAddressField.delegate = self
    }
    
}
