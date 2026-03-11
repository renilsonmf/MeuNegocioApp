//
//  ProfileView.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 23/08/22.
//

import UIKit
import FirebaseAuth

class ProfileView: UIView {
    
    // MARK: - Action Properties
    var logout: Action?
    var deleteAccount: Action?
    
    // MARK: - Properties
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    var user: UserModel? {
        didSet {
            guard let user = user else { return }
            nameUserLabel.text = user.name
            firstNameLabel.text = "\(user.name.prefix(2).uppercased())"
            companyLabel.text = "Empresa: \(user.barbershop)"
            cityLabel.text = "Cidade: \(user.city + "/" + user.state)"
            emailLabel.text = "Email: \(user.email)"
        }
    }
    
    // MARK: - Init

    init(
        didTapLogout: @escaping Action,
        didTapdeleteAccount: @escaping Action
    ) {
        self.logout = didTapLogout
        self.deleteAccount = didTapdeleteAccount
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewCode
    
    private lazy var gripView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.layer.cornerRadius = 2.0
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var iconView: UIView = {
        let container = UIView()
        container.backgroundColor = .MNColors.lightBrown
        container.roundCorners(cornerRadius: 30)
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private lazy var firstNameLabel: MNLabel = {
        let label = MNLabel(font: UIFont.boldSystemFont(ofSize: 16))
        return label
    }()
    
    private lazy var nameUserLabel: MNLabel = {
        let label = MNLabel(font: UIFont.boldSystemFont(ofSize: 16))
        return label
    }()
    
    lazy var InfoStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [companyLabel, cityLabel, emailLabel])
        stack.backgroundColor = .MNColors.lightGray
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fillEqually
        stack.spacing = 6
        stack.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.roundCorners(cornerRadius: 10)
        stack.addShadow(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.25), size: CGSize(width: 0, height: 3), opacity: 0.5, radius: 4)
        stack.clipsToBounds = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var companyLabel: MNLabel = {
        let label = MNLabel(
            font: UIFont.boldSystemFont(ofSize: 16),
            textColor: .MNColors.grayDescription)
        return label
    }()
    
    lazy var cityLabel: MNLabel = {
        let label = MNLabel(
            font: UIFont.boldSystemFont(ofSize: 16),
            textColor: .MNColors.grayDescription)
        return label
    }()
    
    private lazy var emailLabel: MNLabel = {
        let label = MNLabel(
            font: UIFont.boldSystemFont(ofSize: 16),
            textColor: .MNColors.grayDescription)
        return label
    }()
    
    private lazy var logoutAccountView: CardIconAndTitleView = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleLogout))
        let view = CardIconAndTitleView(
            icon: Icon.logoutAccount.rawValue,
            title: "Sair do aplicativo",
            titleColor: .MNColors.grayDarkest,
            isHiddenArrow: false,
            heightIcon: 18,
            spacing: 16)
        view.addTopBorder()
        view.addBottomBorder()
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private lazy var deleteAccountView: CardIconAndTitleView = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDeleteAccount))
        let view = CardIconAndTitleView(
            icon: Icon.deleteAccount.rawValue,
            title: "Encerrar conta",
            titleColor: .MNColors.grayDarkest,
            isHiddenArrow: false,
            heightIcon: 18,
            spacing: 16)
        view.addTopBorder()
        view.addBottomBorder()
        view.addGestureRecognizer(tap)
        return view
    }()
    
    
    private lazy var versionLabel: MNLabel = {
        let label = MNLabel(font: .boldSystemFont(ofSize: 14))
        if let version = appVersion {
            label.text = "Versão \(version)"
        }
        return label
    }()
    
    // MARK: - Action Buttons
    @objc
    func handleLogout() {
        self.logout?()
    }
    
    @objc
    func handleDeleteAccount() {
        self.deleteAccount?()
    }
}

extension ProfileView: ViewCodeContract {
    func setupHierarchy() {
        addSubview(gripView)
        addSubview(iconView)
        iconView.addSubview(firstNameLabel)
        addSubview(nameUserLabel)
        addSubview(InfoStackView)
        addSubview(deleteAccountView)
        addSubview(logoutAccountView)
        addSubview(versionLabel)
    }
    
    func setupConstraints() {
        
        gripView
            .topAnchor(in: self, attribute: .top, padding: 11)
            .centerX(in: self)
            .widthAnchor(32)
            .heightAnchor(4)
        
        iconView
            .topAnchor(in: gripView, padding: 44)
            .leftAnchor(in: self, padding: 16)
            .heightAnchor(60)
            .widthAnchor(60)
        
        firstNameLabel
            .centerX(in: iconView)
            .centerY(in: iconView)
        
        nameUserLabel
            .leftAnchor(in: iconView, attribute: .right, padding: 12)
            .centerY(in: iconView)

        InfoStackView
            .topAnchor(in: iconView, attribute: .bottom, padding: 40)
            .leftAnchor(in: self, attribute: .left, padding: 14)
            .rightAnchor(in: self, attribute: .right, padding: 14)
        
        logoutAccountView
            .topAnchor(in: InfoStackView, attribute: .bottom, padding: 46)
            .leftAnchor(in: self, attribute: .left, padding: 16)
            .rightAnchor(in: self, attribute: .right, padding: 16)
            .heightAnchor(56)
        
        deleteAccountView
            .topAnchor(in: logoutAccountView, attribute: .bottom)
            .leftAnchor(in: self, attribute: .left, padding: 16)
            .rightAnchor(in: self, attribute: .right, padding: 16)
            .heightAnchor(56)
        
        versionLabel
            .bottomAnchor(in: self, attribute: .bottom, padding: 10)
            .centerX(in: self)

    }
    
    func setupConfiguration() {
        backgroundColor = .white
    }
    
}
