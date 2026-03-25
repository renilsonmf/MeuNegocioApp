//
//  ReportView.swift
//  MeuNegocio
//
//  Created by Leonardo Portes on 17/02/22.
//

import UIKit

final class ReportView: UIView {
    
    // MARK: - Action properties
    var didApplyDiscount: ((Bool) -> Void)?
    var didTapDownloadDailyHistoric: Action?
    var didTapDownloadWeeklyHistoric: Action?
    var didTapDownloadMonthlyHistoric: Action?
    var didEditingTextField: (UITextField) -> Void? = { _ in nil }
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Viewcode
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        return scrollView
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.MNColors.lightGray
        return view
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var baseView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// Apply discount
    private lazy var applydiscountCardView = CardView()
    private lazy var applydiscountTitleLabel = MNLabel(
        text: ReportConsts.applyPercent,
        font: UIFont.boldSystemFont(ofSize: 16)
    )
    
    private lazy var applyDiscountStatusView = UIView() .. {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.roundCorners(cornerRadius: 5)
        $0.backgroundColor = .MNColors.grayDescription
    }
    
    private lazy var discountPercentageTextField = CustomTextField(showBaseLine: true) .. {
        $0.textAlignment = .center
        $0.keyboardType = .decimalPad
        $0.placeholder = ReportConsts.placeholderApplyPercent
        $0.delegate = self
        $0.addTarget(self, action: #selector(didInputTextfield), for: .editingChanged)
    }
    
    @objc
    func didInputTextfield(sender: UITextField) {
        self.didEditingTextField(sender)
    }

    /// Historic cards
    private lazy var dailyHistoricCard = ReportCardView(
        didTapReportDownload: weakify { $0.didTapDownloadDailyHistoric?() })

    private lazy var weeklyHistoricCard = ReportCardView(
        didTapReportDownload: weakify { $0.didTapDownloadWeeklyHistoric?() })

    private lazy var monthlyHistoricCard = ReportCardView(
        didTapReportDownload: weakify { $0.didTapDownloadMonthlyHistoric?() })
    
    private lazy var paymentTypeAmountTitle = MNLabel(
        text: ReportConsts.paymentMethods,
        font: UIFont.boldSystemFont(ofSize: 16)
    )
    
    func setupWeeklyTitleIfHasDiscount(_ weeklyTotalAmountTitle: String) {
        weeklyHistoricCard.setupTitleIfHasDiscount(totalAmountTitle: weeklyTotalAmountTitle)
    }
    
    func setupDailyTitleIfHasDiscount(_ dailyTotalAmountTitle: String) {
        dailyHistoricCard.setupTitleIfHasDiscount(totalAmountTitle: dailyTotalAmountTitle)
    }

    func setupMonthlyTitleIfHasDiscount(_ monthlyTotalAmountTitle: String) {
        monthlyHistoricCard.setupTitleIfHasDiscount(totalAmountTitle: monthlyTotalAmountTitle)
    }
    
    /// Payment methods amount
    private lazy var paymentTypeAmountCard = PaymentTypeAmountCardView()
    
    // MARK: - Bind methods
    func setupDailyCard(_ totalAmountValue: String, _ totalProceduresValue: String) {
        dailyHistoricCard.setup(
            title: ReportConsts.dailyHistoric,
            totalAmountTitle: ReportConsts.dailyTotal,
            totalAmountValue: "\(totalAmountValue)",
            totalProceduresValue: totalProceduresValue,
            reportDownloadTitle: ReportConsts.dailyReportDownload
        )
    }

    func setupWeeklyCard(_ totalAmountValue: String, _ totalProceduresValue: String) {
        weeklyHistoricCard.setup(
            title: ReportConsts.weeklyHistoric,
            totalAmountTitle: ReportConsts.weeklyTotal,
            totalAmountValue: "\(totalAmountValue)",
            totalProceduresValue: totalProceduresValue,
            reportDownloadTitle: ReportConsts.weeklyReportDownload
        )
    }

    func setupMonthlyCard(_ totalAmountValue: String, _ totalProceduresValue: String) {
        monthlyHistoricCard.setup(
            title: ReportConsts.monthlyHistoric,
            totalAmountTitle: ReportConsts.monthlyTotal,
            totalAmountValue: "\(totalAmountValue)",
            totalProceduresValue: totalProceduresValue,
            reportDownloadTitle: ReportConsts.monthlyReportDownload
        )
    }

    func setupPaymentTypeAmountCard(
        _ debitAmount: String = "R$00,00",
        _ creditAmount: String = "R$00,00",
        _ cashAmount: String = "R$00,00",
        _ pixAmount: String = "R$00,00"
    ) {
        paymentTypeAmountCard.setup(
            debitAmount: debitAmount,
            creditAmount: creditAmount,
            cashAmount: cashAmount,
            pixAmount: pixAmount
        )
    }
    
}

// MARK: - View code contract
extension ReportView: ViewCodeContract {
    
    // MARK: - Viewcode methods
    func setupHierarchy() {
        self.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(dailyHistoricCard)
        containerView.addSubview(weeklyHistoricCard)
        containerView.addSubview(applydiscountCardView)
        containerView.addSubview(monthlyHistoricCard)
        applydiscountCardView.addSubview(applydiscountTitleLabel)
        applydiscountCardView.addSubview(applyDiscountStatusView)
        applydiscountCardView.addSubview(discountPercentageTextField)
        
        containerView.addSubview(paymentTypeAmountTitle)
        containerView.addSubview(paymentTypeAmountCard)
    }
    
    func setupConstraints() {
        
        scrollView
            .topAnchor(in: self)
            .leftAnchor(in: self)
            .rightAnchor(in: self)
            .bottomAnchor(in: self, layoutOption: .useMargins)
        
        containerView
            .pin(toEdgesOf: scrollView)
        containerView
            .widthAnchor(in: scrollView, 1)
            .heightAnchor(in: scrollView, 1, withLayoutPriorityValue: 250)

        /// Apply discount constraints
        applydiscountCardView
            .topAnchor(in: containerView, padding: 16)
            .leftAnchor(in: containerView, padding: 15)
            .rightAnchor(in: containerView, padding: 15)
            .heightAnchor(50)

        applydiscountTitleLabel
            .centerY(in: applydiscountCardView)
            .heightAnchor(20)
            .leftAnchor(in: applydiscountCardView, padding: 15)
        
        applyDiscountStatusView
            .centerY(in: applydiscountCardView)
            .rightAnchor(in: applydiscountCardView, padding: 15)
            .heightAnchor(10)
            .widthAnchor(10)
        
        discountPercentageTextField
            .centerY(in: applydiscountCardView)
            .leftAnchor(in: applydiscountTitleLabel, attribute: .right, padding: 10)
            .heightAnchor(20)
            .widthAnchor(72)
        
        /// Historic cards constraints
        dailyHistoricCard
            .topAnchor(in: applydiscountCardView, attribute: .bottom, padding: 20)
            .leftAnchor(in: containerView, padding: 15)
            .rightAnchor(in: containerView, padding: 15)
            .heightAnchor(145)
        
        weeklyHistoricCard
            .topAnchor(in: dailyHistoricCard, attribute: .bottom, padding: 20)
            .leftAnchor(in: containerView, padding: 15)
            .rightAnchor(in: containerView, padding: 15)
            .heightAnchor(145)
    
        monthlyHistoricCard
            .topAnchor(in: weeklyHistoricCard, attribute: .bottom, padding: 20)
            .leftAnchor(in: containerView, padding: 15)
            .rightAnchor(in: containerView, padding: 15)
            .heightAnchor(145)
        
        paymentTypeAmountTitle
            .topAnchor(in: monthlyHistoricCard, attribute: .bottom, padding: 20)
            .leftAnchor(in: containerView, padding: 18)
            .heightAnchor(20)
        
        paymentTypeAmountCard
            .topAnchor(in: paymentTypeAmountTitle, attribute: .bottom, padding: 6)
            .leftAnchor(in: containerView, padding: 15)
            .rightAnchor(in: containerView, padding: 15)
            .heightAnchor(170)
            .bottomAnchor(in: containerView, padding: 30)

    }
    
    func setupConfiguration() {
        self.backgroundColor = UIColor.MNColors.lightGray
    }

}

extension ReportView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string.isEmpty.not else { return true }
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string) as String
        if let num = Double(newText), num >= -1 && num <= 100 { return true } else { return false }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        didApplyDiscount?(textField.hasText)
        applyDiscountStatusView.backgroundColor = textField.hasText ? .MNColors.greenMedium : .MNColors.grayDescription
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = .stringEmpty
        didTapDownloadWeeklyHistoric = { self.endEditing(true) }
        didTapDownloadDailyHistoric = { self.endEditing(true) }
        didTapDownloadMonthlyHistoric = { self.endEditing(true) }
    }

}
