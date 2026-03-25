//
//  ReportCardView.swift
//  MeuNegocio
//
//  Created by Leonardo Portes on 28/09/22.
//

import UIKit

final class ReportCardView: CardView, ViewCodeContract {
    
    private var didTapReportDownload: Action?

    // MARK: - View code
    private lazy var titleLabel = MNLabel(
        font: UIFont.boldSystemFont(ofSize: 16)
    ) .. {
        $0.accessibilityTraits = .header
    }
    
    private lazy var totalAmountTitleLabel = MNLabel(
        font: UIFont.boldSystemFont(ofSize: 14),
        textColor: .MNColors.grayDescription
    ) .. {
        $0.accessibilityTraits = .none
    }
    
    private lazy var totalAmountValueLabel = MNLabel()
    
    private lazy var proceduresTitleLabel = MNLabel(
        text: "Atendimentos",
        font: UIFont.boldSystemFont(ofSize: 14),
        textColor: .MNColors.grayDescription
    ) .. {
        $0.textAlignment = .right
        $0.accessibilityTraits = .none
    }

    private lazy var totalProceduresValueLabel = MNLabel()

    // MARK: - Download View
    private lazy var reportDownloadView = TappedView() .. {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.roundCorners(cornerRadius: 10, typeCorners: [.bottomLeft, .bottomRight])
        $0.setup(action: weakify { $0.didTapReportDownload?() })
    }

    private lazy var reportDownloadTitleLabel = MNLabel(
        font: UIFont.boldSystemFont(ofSize: 14)
    ) .. {
        $0.accessibilityTraits = .button
    }

    private lazy var reportDownloadIcon = UIImageView() .. {
        $0.image = UIImage(named: Icon.download.rawValue)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - Init
    init(didTapReportDownload: @escaping Action = { () } ) {
        super.init()
        self.didTapReportDownload = didTapReportDownload
        self.layer.masksToBounds = false
        setupView()
    }
    
    func setup(
        title: String = "Histórico",
        totalAmountTitle: String = "Total",
        totalAmountValue: String = "R$ 00,00",
        totalProceduresValue: String = "0",
        reportDownloadTitle: String = "Baixar relatório"
    ) {
        titleLabel.text = title
        totalAmountTitleLabel.text = totalAmountTitle
        totalAmountValueLabel.text = totalAmountValue
        totalProceduresValueLabel.text = totalProceduresValue
        reportDownloadTitleLabel.text = reportDownloadTitle
    }
    
    func setupTitleIfHasDiscount(totalAmountTitle: String) {
        totalAmountTitleLabel.text = totalAmountTitle
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup methods
    func setupHierarchy() {
        /// Left labels
        addSubview(titleLabel)
        addSubview(totalAmountTitleLabel)
        addSubview(totalAmountValueLabel)

        /// Right labels
        addSubview(proceduresTitleLabel)
        addSubview(totalProceduresValueLabel)

        /// Download white view
        addSubview(reportDownloadView)
        reportDownloadView.addSubview(reportDownloadTitleLabel)
        reportDownloadView.addSubview(reportDownloadIcon)
    }
    
    func setupConstraints() {
        /// Left labels
        titleLabel
            .topAnchor(in: self, padding: 15)
            .leftAnchor(in: self, padding: 15)
            .widthAnchor(170)
            .heightAnchor(20)
        
        totalAmountTitleLabel
            .topAnchor(in: titleLabel, attribute: .bottom, padding: 10)
            .leftAnchor(in: self, padding: 15)
            .heightAnchor(20)
        
        totalAmountValueLabel
            .topAnchor(in: totalAmountTitleLabel, attribute: .bottom)
            .leftAnchor(in: self, padding: 15)
            .widthAnchor(180)
            .heightAnchor(20)
        
        /// Right labels
        proceduresTitleLabel
            .centerY(in: totalAmountTitleLabel)
            .rightAnchor(in: self, padding: 15)
            .heightAnchor(20)
        totalProceduresValueLabel
            .topAnchor(in: proceduresTitleLabel, attribute: .bottom)
            .rightAnchor(in: self, padding: 15)
            .heightAnchor(20)
        
        /// Download white view
        reportDownloadView
            .heightAnchor(45)
            .leftAnchor(in: self)
            .rightAnchor(in: self)
            .bottomAnchor(in: self)
        
        reportDownloadTitleLabel
            .centerY(in: reportDownloadView)
            .leftAnchor(in: reportDownloadView, padding: 15)
            .widthAnchor(170)
            .heightAnchor(20)
        
        reportDownloadIcon
            .centerY(in: reportDownloadView)
            .rightAnchor(in: reportDownloadView, padding: 15)
            .widthAnchor(20)
            .heightAnchor(20)
    }

    func setupConfiguration() {
        self.accessibilityElements = [
            titleLabel,
            totalAmountTitleLabel,
            totalAmountValueLabel,
            proceduresTitleLabel,
            totalProceduresValueLabel,
            reportDownloadTitleLabel
        ]
    }

}
