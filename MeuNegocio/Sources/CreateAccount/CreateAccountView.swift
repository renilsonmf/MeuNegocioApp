//
//  CreateAccountView.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 15/08/22.
//

import UIKit

class CreateAccountView: UIView {
    
    private var isSecureTextEntry: Bool = false
    var createAccount: ((String, String) -> Void)?
    var closedView: Action?
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   private lazy var scrollView: UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var gripView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.layer.cornerRadius = 2.0
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
   private lazy var eyeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.tintColor = .MNColors.darkGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleEyeButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: MNLabel = {
        let label = MNLabel(text: "Criar Conta",
                                font: UIFont.boldSystemFont(ofSize: 20),
                                textColor: .darkGray)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    
    private lazy var subTitleLabel: MNLabel = {
        let label = MNLabel(text: "Informe um e-mail válido e uma senha com \n no minimo 7 digitos para criar a sua conta.",
                                font: UIFont.systemFont(ofSize: 16),
                                textColor: .darkGray)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var emailTextField: CustomTextField = {
        let textField = CustomTextField(titlePlaceholder: "E-mail",
                                        colorPlaceholder: .lightGray,
                                        textColor: .MNColors.darkGray,
                                        radius: 5,
                                        borderColor: UIColor.systemGray.cgColor,
                                        borderWidth: 0.5,
                                        keyboardType: .emailAddress)
        textField.addTarget(self, action: #selector(handleTextFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()
    
    lazy var passwordTextField: CustomTextField = {
        let textField = CustomTextField(titlePlaceholder: "Senha",
                                        colorPlaceholder: .lightGray,
                                        textColor: .MNColors.darkGray,
                                        radius: 5,
                                        borderColor: UIColor.systemGray.cgColor,
                                        borderWidth: 0.5,
                                        isSecureTextEntry: true)
        textField.textContentType = .oneTimeCode
        textField.addTarget(self, action: #selector(handleTextFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()
    
    lazy var createAccountButton: CustomSubmitButton = {
        let button = CustomSubmitButton(title: "Criar conta",
                                        colorTitle: .darkGray,
                                        radius: 10,
                                        background: .systemGray)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleCreateAccountButton), for: .touchUpInside)
        return button
    }()
    
    func isEnabledButtonCreateAccount(_ isEnabled: Bool) {
        if isEnabled {
            createAccountButton.backgroundColor = .MNColors.yellow
            createAccountButton.isEnabled = true
        }else {
            createAccountButton.backgroundColor = .systemGray
            createAccountButton.isEnabled = false
        }
    }
    
    // MARK: - Action TextFields
    @objc
    func handleTextFieldDidChange(_ textField: UITextField) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        if email.isValidEmail() && password.count >= 7 {
            isEnabledButtonCreateAccount(true)
        }else {
            isEnabledButtonCreateAccount(false)
        }
    }
    
    // MARK: - Action Buttons
    @objc
    func handleCreateAccountButton() {
        createAccountButton.loadingIndicator(show: true)
        createAccount?(emailTextField.text.orEmpty, passwordTextField.text.orEmpty)
    }
    
    @objc
    func handleEyeButton() {
        if isSecureTextEntry {
            isSecureTextEntry = false
            eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
            passwordTextField.isSecureTextEntry = true
        }else {
            isSecureTextEntry = true
            eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            passwordTextField.isSecureTextEntry = false
        }
    }
    
}

extension CreateAccountView: ViewCodeContract {
    func setupHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(gripView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(emailTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(createAccountButton)
        contentView.addSubview(eyeButton)
    }
    
    func setupConstraints() {

        scrollView
            .topAnchor(in: self)
            .leftAnchor(in: self)
            .rightAnchor(in: self)
            .bottomAnchor(in: self, layoutOption: .useSafeArea)
        
        contentView
            .pin(toEdgesOf: scrollView)
        contentView
            .widthAnchor(in: scrollView, 1)
            .heightAnchor(in: scrollView, 1, withLayoutPriorityValue: 250)
        
        gripView
            .topAnchor(in: self, attribute: .top, padding: 11)
            .centerX(in: self)
            .widthAnchor(32)
            .heightAnchor(4)
        
        titleLabel
            .topAnchor(in: gripView, attribute: .bottom, padding: 44)
            .centerX(in: self)
        
        subTitleLabel
            .topAnchor(in: titleLabel, attribute: .bottom, padding: 16)
            .centerX(in: self)
        
        emailTextField
            .topAnchor(in: subTitleLabel, attribute: .bottom, padding: 32)
            .leftAnchor(in: contentView, attribute: .left, padding: 16)
            .rightAnchor(in: contentView, attribute: .right, padding: 16)
            .heightAnchor(48)
        
        passwordTextField
            .topAnchor(in: emailTextField, attribute: .bottom, padding: 24)
            .leftAnchor(in: contentView, attribute: .left, padding: 16)
            .rightAnchor(in: contentView, attribute: .right, padding: 16)
            .heightAnchor(48)
        
        eyeButton
            .topAnchor(in: emailTextField, attribute: .bottom, padding: 24)
            .rightAnchor(in: passwordTextField)
            .widthAnchor(48)
            .heightAnchor(48)
        
        createAccountButton
            .topAnchor(in: passwordTextField, attribute: .bottom, padding: 48)
            .leftAnchor(in: contentView, attribute: .left, padding: 16)
            .rightAnchor(in: contentView, attribute: .right, padding: 16)
            .heightAnchor(48)
        
    }
    
    func setupConfiguration() {
        backgroundColor = .white
    }
    
}
