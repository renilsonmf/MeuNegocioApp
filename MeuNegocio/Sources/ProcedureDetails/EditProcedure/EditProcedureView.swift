//
//  EditProcedureView.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 17/01/23.
//

import Foundation
import UIKit

protocol EditProcedureDelegate: AnyObject {
    func alertForTextField(message: String)
    func isSomeEmptyField(message: String)
    func saveProcedure(procedures: GetProcedureModel)
}

class EditProcedureView: MNView {
        
    private let paymentMethods: [PaymentMethodType] = [.pix, .cash, .credit, .debit, .other]
    private var procedures: GetProcedureModel?
    weak var delegate: EditProcedureDelegate?
    
    override init() {
        super.init()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setValues(procedure: GetProcedureModel?) {
        procedures = procedure
        guard let procedure = procedure else { return }
        
        let amountTotal = Double(procedure.value) ?? 0.0
        let amountCosts = Double(procedure.costs ?? .stringEmpty)
        
        nameTextField.text = procedure.nameClient
        typeJobTextField.text = procedure.typeProcedure
        paymentTextField.text = procedure.formPayment.rawValue
        valueTextField.text = amountTotal.plata.string(currency: .br)
        costsTextField.text = amountCosts?.plata.string(currency: .br)
    }
    
    private lazy var gripView = UIView() .. {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .lightGray
        $0.roundCorners(cornerRadius: 2)
    }
    
    private lazy var titleLabel: MNLabel = {
        let label = MNLabel(text: "Preencha com novos valores \n os campos que devem ser editados.",
                            font: UIFont.systemFont(ofSize: 16),
                            textColor: .darkGray)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var pickerView = UIPickerView() .. {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .MNColors.yellowDark
        $0.selectRow(2, inComponent: 0, animated: true)
    }

    lazy var editingStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var nameTextField: CustomTextField = {
        let textField = CustomTextField(
            titlePlaceholder: "Nome do cliente",
            colorPlaceholder: .lightGray,
            textColor: .MNColors.darkGray,
            radius: 5,
            borderColor: UIColor.systemGray.cgColor,
            borderWidth: 0.5,
            keyboardType: .default
        )
        textField.delegate = self
        textField.heightAnchor(48)
        return textField
    }()
    
    private lazy var typeJobTextField: CustomTextField = {
        let textField = CustomTextField(
            titlePlaceholder: "Tipo de procedimento",
            colorPlaceholder: .lightGray,
            textColor: .MNColors.darkGray,
            radius: 5,
            borderColor: UIColor.systemGray.cgColor,
            borderWidth: 0.5,
            keyboardType: .default
        )
        textField.delegate = self
        textField.heightAnchor(48)
        return textField
    }()
    
    private lazy var paymentTextField: CustomTextField = {
        let textField = CustomTextField(
            titlePlaceholder: "Forma de pagamento",
            colorPlaceholder: .lightGray,
            textColor: .MNColors.darkGray,
            radius: 5,
            borderColor: UIColor.systemGray.cgColor,
            borderWidth: 0.5,
            keyboardType: .default
        )
        textField.heightAnchor(48)
        textField.delegate = self
        textField.inputView = pickerView
        return textField
    }()
    
    private lazy var valueTextField: CustomTextField = {
        let textField = CustomTextField(
            titlePlaceholder: "R$",
            colorPlaceholder: .lightGray,
            textColor: .MNColors.darkGray,
            radius: 5,
            borderColor: UIColor.systemGray.cgColor,
            borderWidth: 0.5,
            keyboardType: .numberPad
        )
        textField.heightAnchor(48)
        textField.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
        textField.delegate = self
        return textField
    }()
    
    private lazy var costsTextField: CustomTextField = {
        let textField = CustomTextField(
            titlePlaceholder: "Custo",
            colorPlaceholder: .lightGray,
            textColor: .MNColors.darkGray,
            radius: 5,
            borderColor: UIColor.systemGray.cgColor,
            borderWidth: 0.5,
            keyboardType: .numberPad
        )
        textField.heightAnchor(48)
        textField.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
        textField.delegate = self
        return textField
    }()
    
    lazy var saveButton: CustomSubmitButton = {
        let button = CustomSubmitButton(
            title: "Salvar",
            colorTitle: .MNColors.darkGray,
            radius: 10,
            background: .MNColors.yellow
        )
        button.heightAnchor(48)
        button.addTarget(self, action: #selector(handleAddButton), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Methods
    @objc
    private func myTextFieldDidChange(_ textField: UITextField) {
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
    }
    
    @objc
    private func handleAddButton() {
        self.saveButton.loadingIndicator(show: true)
        guard let procedures = procedures else { return }
        
        let amountValue = valueTextField.text?
            .replacingOccurrences(of: "R$", with: "")
            .dropFirst()
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: " ", with: ".")
        
        let amountCosts = costsTextField.text?
            .replacingOccurrences(of: "R$", with: "")
            .dropFirst()
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: " ", with: ".")
        
        let model = GetProcedureModel(_id: procedures._id,
                                      nameClient: nameTextField.text.orEmpty,
                                      typeProcedure: typeJobTextField.text.orEmpty,
                                      formPayment: PaymentMethodType(rawValue: paymentTextField.text.orEmpty) ?? .cash,
                                      value: amountValue.orEmpty,
                                      currentDate: procedures.currentDate,
                                      email: procedures.email,
                                      costs: amountCosts,
                                      valueLiquid: procedures.valueLiquid)
        
        if isSomeEmptyField() {
            delegate?.isSomeEmptyField(message: "Preencha todos os campos.")
        } else if checkValueCosts(){
            delegate?.alertForTextField(message: "O custo não pode ser maior que o valor do procedimento")
        } else {
            delegate?.saveProcedure(procedures: model)
        }

    }
    
    private func checkValueCosts() -> Bool {
        let amountCosts = costsTextField.text.orEmpty
            .replacingOccurrences(of: "R$", with: "")
            .dropFirst()
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: " ", with: ".")
        
        let amountValue = valueTextField.text.orEmpty
            .replacingOccurrences(of: "R$", with: "")
            .dropFirst()
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: " ", with: ".")
        
        let doubleCosts = Double(amountCosts) ?? 0.0
        let doubleValue = Double(amountValue) ?? 0.0
        
        if doubleCosts > doubleValue {
            return true
        } else {
            return false
        }
    }
    
    private func isSomeEmptyField() -> Bool {
        var result: Bool = false
        let name = nameTextField.text.orEmpty
        let typeJob = typeJobTextField.text.orEmpty
        let payment = paymentTextField.text.orEmpty
        let value = valueTextField.text.orEmpty
        
        let someAreEmpty = name.isEmpty || typeJob.isEmpty || payment.isEmpty || value.isEmpty

        result = someAreEmpty ? true : false

        return result
    }
}

extension EditProcedureView: ViewCodeContract {
    func setupHierarchy() {
        addSubview(gripView)
        addSubview(editingStack)
        editingStack.addArrangedSubview(titleLabel)
        editingStack.addArrangedSubview(nameTextField)
        editingStack.addArrangedSubview(typeJobTextField)
        editingStack.addArrangedSubview(paymentTextField)
        editingStack.addArrangedSubview(valueTextField)
        editingStack.addArrangedSubview(costsTextField)
        editingStack.addArrangedSubview(saveButton)
    }

    func setupConstraints() {
        gripView
            .topAnchor(in: self, padding: 10)
            .centerX(in: self)
            .heightAnchor(4)
            .widthAnchor(34)
        
        editingStack
            .topAnchor(in: gripView, padding: 40)
            .leftAnchor(in: self, padding: 16)
            .rightAnchor(in: self, padding: 16)
    }
    
    func setupConfiguration() {
        backgroundColor = .white
    }
}

// MARK: - UITextFieldDelegate & UITextFieldDataSource

extension EditProcedureView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var maxLength: Int = 18
        let currentString = (textField.text.orEmpty) as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)

        if textField == valueTextField {
            maxLength = 13
        }

        if textField == typeJobTextField {
            maxLength = 60
        }

        if textField == costsTextField {
            maxLength = 13
        }
        return newString.count <= maxLength
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
}

// MARK: - UIPickerViewDelegate & UIPickerViewDataSource
extension EditProcedureView: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return paymentMethods.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return paymentMethods[row].rawValue
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        paymentTextField.text = paymentMethods[row].rawValue
        paymentTextField.resignFirstResponder()
    }
}

