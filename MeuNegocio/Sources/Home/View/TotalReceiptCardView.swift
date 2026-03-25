//
//  CardTotalView.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 18/10/22.
//

import Foundation
import UIKit

class TotalReceiptCardView: CardView {
    
    // MARK: - Init
    init() {
        super.init(backgroundColor: .MNColors.yellow)
        setupView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) lazy var calendarIcon = UIImageView() .. {
        $0.image = UIImage(named: Icon.calendar.rawValue)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.heightAnchor(16)
        $0.widthAnchor(16)
    }
    
    private(set) lazy var filterTitleLabel = MNLabel() .. {
        $0.textAlignment = .left
        $0.font = UIFont.boldSystemFont(ofSize: 16)
        $0.textColor = .MNColors.grayDescription
    }
    
    private lazy var vStackServices = UIStackView() .. {
        $0.axis = .vertical
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 2
    }

    private lazy var servicesLabel = MNLabel() .. {
        $0.text = "Atendimentos"
        $0.textAlignment = .right
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.textColor = .MNColors.grayDescription
    }

    private(set) lazy var valueOfServiceLabel = MNLabel() .. {
        $0.text = "0"
        $0.textAlignment = .right
        $0.font = UIFont.boldSystemFont(ofSize: 18)
    }
    
    private(set) lazy var dividerView = UIView() .. {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .MNColors.grayDescription
        $0.widthAnchor(1)
        $0.heightAnchor(35)
    }
    
    private lazy var vStackTotalValue = UIStackView() .. {
        $0.axis = .vertical
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 2
    }

    private lazy var totalLabel = MNLabel(text: "Faturamento") .. {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.textColor = .MNColors.grayDescription
    }

    private(set) lazy var totalValueLabel = MNLabel() .. {
        $0.text = "R$ 00,00"
        $0.font = UIFont.boldSystemFont(ofSize: 18)
    }
    
    // MARK: Private methods
    func setupCardValues(title: String, totalValues: String?, procedureValue: String) {
        filterTitleLabel.text = title
        totalValueLabel.text = totalValues
        valueOfServiceLabel.text = procedureValue
    }
}

extension TotalReceiptCardView: ViewCodeContract {
    func setupHierarchy() {
        addSubview(calendarIcon)
        addSubview(filterTitleLabel)
        addSubview(vStackServices)
        addSubview(dividerView)
        addSubview(vStackTotalValue)
        
        vStackServices.addArrangedSubview(valueOfServiceLabel)
        vStackServices.addArrangedSubview(servicesLabel)
        
        vStackTotalValue.addArrangedSubview(totalValueLabel)
        vStackTotalValue.addArrangedSubview(totalLabel)
    }
    
    func setupConstraints() {
        self
            .topAnchor(in: self)
            .leftAnchor(in: self)
            .rightAnchor(in: self)
            .bottomAnchor(in: self)
    
        calendarIcon
            .topAnchor(in: self, padding: 12)
            .leftAnchor(in: self, padding: 12)

        filterTitleLabel
            .centerY(in: calendarIcon)
            .leftAnchor(in: calendarIcon, attribute: .right, padding: 4)
        
        dividerView
            .bottomAnchor(in: self, padding: 12)
            .centerX(in: self)

        vStackServices
            .topAnchor(in: filterTitleLabel, attribute: .bottom, padding: 12)
            .leftAnchor(in: self, padding: 12)
            .rightAnchor(in: dividerView, attribute: .left, padding: 30)
            .bottomAnchor(in: self, padding: 12)

        vStackTotalValue
            .topAnchor(in: filterTitleLabel, attribute: .bottom, padding: 12)
            .leftAnchor(in: dividerView, attribute: .right, padding: 30)
            .rightAnchor(in: self, padding: 12)
            .bottomAnchor(in: self, padding: 12)
    }
    
    func setupConfiguration() {
        self.loadingIndicatorView(show: true)
    }
}
