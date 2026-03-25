//
//  BarberNavBar.swift
//  MeuNegocio
//
//  Created by Leonardo Portes on 12/02/22.
//

import UIKit

final class ProfileHeaderView: UIView {
    
    // MARK: - Private properties
    private var openProfile: Action?
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Viewcode
    
    lazy var containerStackView: UIStackView = {
        let container = UIStackView()
        let tapProfile = UITapGestureRecognizer(target: self, action: #selector(tappedView))
        container.axis = .horizontal
        container.distribution = .fill
        container.spacing = 8
        container.addGestureRecognizer(tapProfile)
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private lazy var iconView: UIView = {
        let container = UIView()
        container.backgroundColor = .lightText
        container.roundCorners(cornerRadius: 20)
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private lazy var initialLattersLabel: MNLabel = {
        let label = MNLabel(font: UIFont.boldSystemFont(ofSize: 16))
        return label
    }()
    
    private lazy var nameUserLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var iconArrow: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: Icon.arrowDown.rawValue)
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
        
    @objc private func tappedView(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.openProfile?()
        }
    }
    
    func setupLayout(nameUser: String) {
        initialLattersLabel.text = "\(nameUser.prefix(2).uppercased())"
        nameUserLabel.text = "Olá, \(nameUser)"
    }
    
    func setupAction(actionButton: @escaping Action) {
        self.openProfile = actionButton
    }


}

extension ProfileHeaderView: ViewCodeContract {
    func setupHierarchy() {
        addSubview(containerStackView)
        containerStackView.addArrangedSubview(iconView)
        containerStackView.addArrangedSubview(nameUserLabel)
        containerStackView.addArrangedSubview(iconArrow)
        
        iconView.addSubview(initialLattersLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // MARK: - containerStackView
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            containerStackView.heightAnchor.constraint(equalToConstant: 40),

            // MARK: - iconView
            iconView.heightAnchor.constraint(equalToConstant: 40),
            iconView.widthAnchor.constraint(equalToConstant: 40),

            // MARK: - initialLattersLabel (centralizado no iconView)
            initialLattersLabel.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            initialLattersLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),

            // MARK: - iconArrow
            iconArrow.heightAnchor.constraint(equalToConstant: 15),
            iconArrow.widthAnchor.constraint(equalToConstant: 15)
        ])
    }

    
    func setupConfiguration() {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
