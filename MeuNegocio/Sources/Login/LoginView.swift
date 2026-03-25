//
//  LoginView.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 02/08/22.
//

import Foundation
import UIKit
import GoogleSignIn

protocol LoginScreenActionsProtocol: AnyObject {
    func didTapLogin(_ email: String, _ password: String)
    func didTapForgotPassword()
    func didTapRegister()
    func didTapSignInGoogle()
    func didTapSignInApple()
}

class LoginView: UIView {
    
    // MARK: - Properties
    private var isSecureTextEntry: Bool = false
    weak var delegateAction: LoginScreenActionsProtocol?
    var didEditingTextField: (String) -> Void? = { _ in nil }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Code
    private lazy var eyeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.tintColor = .MNColors.grayDarkest
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleEyeButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var iconStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [myBusinessImage, titleLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        return stack
    }()
    
    private lazy var myBusinessImage: UIImageView = {
        let img = UIImageView()
        img.heightAnchor(36)
        img.widthAnchor(36)
        img.image = UIImage(named: Icon.iconApp.rawValue)
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    private lazy var titleLabel: MNLabel = {
        let label = MNLabel(text: "Meu negócio",
                                font: UIFont.boldSystemFont(ofSize: 20),
                                textColor: .darkGray)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var emailTextField: CustomTextField = {
        let textField = CustomTextField(titlePlaceholder: "E-mail cadastrado",
                                        colorPlaceholder: .lightGray,
                                        textColor: .black,
                                        radius: 5,
                                        borderColor: UIColor.darkGray.cgColor,
                                        borderWidth: 0.5,
                                        keyboardType: .emailAddress)
        textField.autocapitalizationType = .none
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var passwordTextField: CustomTextField = {
        let textField = CustomTextField(titlePlaceholder: "Senha",
                                        colorPlaceholder: .lightGray,
                                        textColor: .black,
                                        radius: 5,
                                        borderColor: UIColor.darkGray.cgColor,
                                        borderWidth: 0.5,
                                        isSecureTextEntry: true)
        textField.autocapitalizationType = .none
        textField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)
        return textField
    }()
    
    lazy var loginButton: CustomSubmitButton = {
        let button = CustomSubmitButton(title: "Login",
                                  colorTitle: .darkGray,
                                  radius: 10,
                                  background: .systemGray)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLoginButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var forgotPasswordStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [forgotPasswordLabel, forgotPasswordButton])
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var forgotPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "Esqueceu sua senha? "
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var forgotPasswordButton: CustomSubmitButton = {
        let button = CustomSubmitButton(title: "Clique aqui!",
                                        colorTitle: .darkGray,
                                        alignmentText: .left)
        button.addTarget(self, action: #selector(handleForgotPasswordButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var orLabel: UILabel = {
        let label = UILabel()
        label.text = "Ou"
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var providersStackView: UIStackView = {
       let stack = UIStackView(arrangedSubviews: [containerGoogle, containerApple])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var containerGoogle: TappedView = {
        let view = TappedView()
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 10
        view.heightAnchor(48)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setup(action: weakify {$0.handlerSignInGoogleButton()})
        return view
    }()
    
    private lazy var cardSessionGoogle: CardIconAndTitleView = {
        let view = CardIconAndTitleView(icon: Icon.google.rawValue,
                                   title: "Iniciar sessão com o Google",
                                   titleColor: .black)
        return view
    }()
    
    private lazy var containerApple: TappedView = {
        let view = TappedView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 10
        view.heightAnchor(48)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setup(action: weakify {$0.handlerSignInAppleButton()})
        return view
    }()
    
    private lazy var cardSessionApple: CardIconAndTitleView = {
        let view = CardIconAndTitleView(icon: Icon.apple.rawValue,
                                   title: "Iniciar sessão com a Apple",
                                   titleColor: .white)
        return view
    }()
    
    private lazy var registerStackView: UIStackView = {
        let container = UIStackView(arrangedSubviews: [registerLabel, registerButton])
        container.axis = .horizontal
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private lazy var registerLabel: UILabel = {
        let label = UILabel()
        label.text = "Não tem uma conta? "
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var registerButton: CustomSubmitButton = {
        let button = CustomSubmitButton(title: "Registre-se",
                                        colorTitle: .darkGray)
        button.addTarget(self, action: #selector(handlerRegisterButton), for: .touchUpInside)
        return button
    }()
    
    private func isEnabledButtonLogin(_ isEnabled: Bool) {
        if isEnabled {
            loginButton.backgroundColor = .MNColors.yellow
            loginButton.isEnabled = true
        } else {
            loginButton.backgroundColor = .systemGray
            loginButton.isEnabled = false
        }
    }
    
    func setEmailNewUser(email: String) {
        emailTextField.text = email
    }
    
    // MARK: - Action TextFields
    @objc private func textFieldEditingDidChange() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        let isValidLogin = email.isValidEmail() && password.count >= 7
        isValidLogin ? isEnabledButtonLogin(true) : isEnabledButtonLogin(false)
        didEditingTextField(email)
    }
        
    // MARK: - Action Buttons
    @objc
    private func handleLoginButton() {
        loginButton.loadingIndicator(show: true)
        delegateAction?.didTapLogin(emailTextField.text.orEmpty, passwordTextField.text.orEmpty)
    }
    
    @objc
    private func handleForgotPasswordButton() {
        delegateAction?.didTapForgotPassword()
    }
    
    @objc
    private func handlerSignInGoogleButton() {
        delegateAction?.didTapSignInGoogle()
    }
    
    @objc
    private func handlerSignInAppleButton() {
        delegateAction?.didTapSignInApple()
    }
    
    @objc
    private func handlerRegisterButton() {
        delegateAction?.didTapRegister()
    }

    @objc
    private func handleEyeButton() {
        if isSecureTextEntry {
            isSecureTextEntry = false
            eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
            passwordTextField.isSecureTextEntry = true
        } else {
            isSecureTextEntry = true
            eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            passwordTextField.isSecureTextEntry = false
        }
    }
    
}

extension LoginView: ViewCodeContract {
    func setupHierarchy() {
        addSubview(iconStackView)
        addSubview(emailTextField)
        addSubview(passwordTextField)
        addSubview(eyeButton)
        addSubview(loginButton)
        addSubview(forgotPasswordStackView)
        addSubview(orLabel)
        addSubview(providersStackView)
        containerGoogle.addSubview(cardSessionGoogle)
        containerApple.addSubview(cardSessionApple)
        addSubview(registerStackView)
    }
    
    func setupConstraints() {
        iconStackView
            .topAnchor(in: self, attribute: .top, padding: 80)
            .centerX(in: self)
            .widthAnchor(200)
            .heightAnchor(36)
        
        emailTextField
            .topAnchor(in: iconStackView, attribute: .bottom, padding: 50)
            .leftAnchor(in: self, attribute: .left, padding: 16)
            .rightAnchor(in: self, attribute: .right, padding: 16)
            .heightAnchor(48)
        
        passwordTextField
            .topAnchor(in: emailTextField, attribute: .bottom, padding: 24)
            .leftAnchor(in: self, attribute: .left, padding: 16)
            .rightAnchor(in: self, attribute: .right, padding: 16)
            .heightAnchor(48)
        
        eyeButton
            .topAnchor(in: emailTextField, attribute: .bottom, padding: 24)
            .rightAnchor(in: passwordTextField)
            .widthAnchor(48)
            .heightAnchor(48)
        
        loginButton
            .topAnchor(in: passwordTextField, attribute: .bottom, padding: 17)
            .leftAnchor(in: self, attribute: .left, padding: 16)
            .rightAnchor(in: self, attribute: .right, padding: 16)
            .heightAnchor(48)
        
        forgotPasswordStackView
            .topAnchor(in: loginButton, attribute: .bottom, padding: 14)
            .centerX(in: self)
        
        orLabel
            .topAnchor(in: forgotPasswordStackView, attribute: .bottom, padding: 20)
            .centerX(in: self)
        
        providersStackView
            .topAnchor(in: orLabel, attribute: .bottom, padding: 20)
            .leftAnchor(in: self, attribute: .left, padding: 16)
            .rightAnchor(in: self, attribute: .right, padding: 16)
        
        cardSessionGoogle
            .centerX(in: containerGoogle)
            .centerY(in: containerGoogle)
        
        cardSessionApple
            .centerX(in: containerApple)
            .centerY(in: containerApple)
        
        registerStackView
            .bottomAnchor(in: self, attribute: .bottom, padding: 20)
            .centerX(in: self)
    }
    
    func setupConfiguration() {
        self.backgroundColor = .white
    }
}
