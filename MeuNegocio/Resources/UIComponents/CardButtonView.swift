//
//  CardButtonView.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 26/09/22.
//

import UIKit

class CardButtonView: UIView {

    init(icon: String, title: String) {
        super.init(frame: .zero)
        self.layer.cornerRadius = 10
        iconView.image = UIImage(named: icon)
        titleLabel.text = title
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var container: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    lazy var containerView: UIView = {
        let container = UIView()
        container.backgroundColor = .MNColors.yellow
        container.roundCorners(cornerRadius: 42, all: true)
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private lazy var iconView: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.image = UIImage(named: "ic_help")
        return img
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
}

extension CardButtonView: ViewCodeContract {
    func setupHierarchy() {
        addSubview(container)
        container.addSubview(containerView)
        container.addSubview(titleLabel)
        
        containerView.addSubview(iconView)
    }
    
    func setupConstraints() {
        
        container
            .topAnchor(in: self)
            .leftAnchor(in: self)
            .rightAnchor(in: self)
            .bottomAnchor(in: self)
        
        containerView
            .topAnchor(in: container, attribute: .top)
            .centerX(in: container)
            .heightAnchor(85)
            .widthAnchor(85)
        
        iconView
            .centerX(in: containerView)
            .centerY(in: containerView)
            .heightAnchor(28)
            .widthAnchor(28)
        
        titleLabel
            .topAnchor(in: containerView, attribute: .bottom, padding: 10)
            .centerX(in: containerView)
            .bottomAnchor(in: container, attribute: .bottom)
    }
    
    func setupConfiguration() {
        self.widthAnchor(85)
    }
    
}

