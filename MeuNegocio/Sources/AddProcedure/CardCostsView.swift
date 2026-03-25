//
//  CardCostsView.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 28/12/22.
//

import Foundation
import UIKit

class CardCostsView: UIView {
    
    var valueTextField: (String) -> Void?
    
    init(valueTextField: @escaping (String) -> Void) {
        self.valueTextField = valueTextField
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var containerHorizontal: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var container: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .MNColors.grayDescription
        label.text = "Adicionar custo ao serviço"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var customTextField: CustomTextField = {
        let textField = CustomTextField(
            titlePlaceholder: "R$",
            colorPlaceholder: .MNColors.grayDescription,
            textColor: .MNColors.grayDescription,
            keyboardType: .numberPad,
            showBaseLine: true
        )
        textField.heightAnchor(30)
        textField.widthAnchor(110)
        textField.isHidden = true
        textField.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
    
    lazy var customSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.setOn(false, animated: false)
        toggle.onTintColor = .MNColors.yellow
        toggle.addTarget(self, action: #selector(self.switchStateDidChange(_:)), for: .valueChanged)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    // MARK: - Actions
    @objc
    func switchStateDidChange(_ sender: UISwitch) {
        customTextField.isHidden = !sender.isOn
    }
    
    @objc
    private func myTextFieldDidChange(_ textField: UITextField) {
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
            valueTextField(amountString)
        }
    }
}
extension CardCostsView: ViewCodeContract {
    func setupHierarchy() {
        addSubview(containerStack)
        containerStack.addArrangedSubview(containerHorizontal)
        containerStack.addArrangedSubview(customTextField)
        
        containerHorizontal.addArrangedSubview(titleLabel)
        containerHorizontal.addArrangedSubview(customSwitch)
        
    }
    
    func setupConstraints() {
    
        containerStack
            .topAnchor(in: self)
            .leftAnchor(in: self)
            .rightAnchor(in: self)
            .bottomAnchor(in: self)
        
        titleLabel
            .heightAnchor(30)

    }
}
