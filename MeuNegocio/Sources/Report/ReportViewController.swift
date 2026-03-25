//
//  ReportViewController.swift
//  MeuNegocio
//
//  Created by Leonardo Portes on 17/02/22.
//

import Foundation
import UIKit
import PDFKit

final class ReportViewController: CoordinatedViewController {
    private var proceduresObserver: NSObjectProtocol?
    
    // MARK: - Properties
    var procedures: [GetProcedureModel]
    var amountDiscount: String = ReportConsts.noPorcentApplyed
    var pdftable: ConfigurableTable? = nil
    
    // MARK: - Private properties
    private let viewModel: ReportViewModelProtocol
    private lazy var customView = ReportView()
    

    // MARK: - Init
    init(viewModel: ReportViewModelProtocol, coordinator: CoordinatorProtocol, procedures: [GetProcedureModel]) {
        self.procedures = procedures
        self.viewModel = viewModel
        super.init(coordinator: coordinator)
        notifications()
    }
    
    func notifications() {
        proceduresObserver = NotificationCenter.default.addObserver(forName: .didUpdateProceduresForReport, object: nil, queue: .main) { [weak self] notification in
            guard let self = self,
                  let updated = notification.userInfo?["procedures"] as? [GetProcedureModel] else { return }
            self.procedures = updated
            self.fetchProcedures()
        }
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if let observer = proceduresObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        hideKeyboardWhenTappedAround()
        navigationController?.title = "Relátorios"
    }
    
    override func loadView() {
        super.loadView()
        self.view = customView
    }

    // MARK: - Bind methods
    /// Bind all procedures.
    private func fetchProcedures() {
        self.setupReportView(procedures)
    }

    /// Setup for report view.
    private func setupReportView(_ response: [GetProcedureModel]) {

        /// Default Values without porcentage interaction.
        self.setupWeeklyAmount(procedures: response)
        self.setupPaymentTypeAmount(procedures: response)
        self.setupDailyAmount(procedures: response)
        self.setupMonthlyAmount(procedures: response)
        self.shareReportPDF(procedures: response)
        
        /// Values with porcentage interaction in textfield.
        self.customView.didEditingTextField = weakify { weakSelf, txt in
            weakSelf.customView.didApplyDiscount = weakSelf.weakify { weakSelf, hasDiscount in
                guard let percent = txt.text else { return }
                
                weakSelf.shareReportPDF(procedures: response, hasDiscount, percent: percent)
                weakSelf.setupDailyAmount(procedures: response, hasDiscount, percent: percent)
                weakSelf.setupWeeklyAmount(procedures: response, hasDiscount, percent: percent)
                weakSelf.setupMonthlyAmount(procedures: response, hasDiscount, percent: percent)
                weakSelf.setupPaymentTypeAmount(procedures: response, hasDiscount, percent: percent)
            }
        }
    }

    /// Configure amout for daily card.
    private func setupDailyAmount(procedures: [GetProcedureModel], _ hasDiscount: Bool = false, percent: String = .stringEmpty) {
        let today = viewModel.returnCurrentDate
        /// Here we filter the current day's procedures.
        let dailyProcedures = procedures.filter({$0.currentDate == today})
        /// Here we sum all the receipts of the current day.
        let makeTotalDailyAmount = viewModel.makeTotalAmount(dailyProcedures)

        if hasDiscount {
            let percentResult = viewModel.percentageFromString(percent: percent, baseAmount: makeTotalDailyAmount)
            self.customView.setupDailyCard(percentResult, "\(dailyProcedures.count)")
            self.customView.setupDailyTitleIfHasDiscount("\(percent)% do total líquido • \(ReportConsts.today)")
        } else {
            self.customView.setupDailyCard(makeTotalDailyAmount, "\(dailyProcedures.count)")
            self.customView.setupDailyTitleIfHasDiscount("\(ReportConsts.total) • \(ReportConsts.today)")
        }
    }

    /// Configure amout for weekly card.
    private func setupWeeklyAmount(procedures: [GetProcedureModel], _ hasDiscount: Bool = false, percent: String = .stringEmpty) {
        /// Here we filter the procedures from the last 7 days.
        let weeklyProcedures = viewModel.weeklyProceduresLast7Days(procedures: procedures)
        /// Here we add the values ​​of the procedures of the last 7 days.
        let makeTotalWeeklyAmount = viewModel.makeTotalAmount(weeklyProcedures)
       
        if hasDiscount {
            let percentResult = viewModel.percentageFromString(percent: percent, baseAmount: makeTotalWeeklyAmount)
            self.customView.setupWeeklyCard(percentResult, "\(weeklyProcedures.count)")
            self.customView.setupWeeklyTitleIfHasDiscount("\(percent)% do total líquido • \(ReportConsts.last7days)")
        } else {
            self.customView.setupWeeklyCard(makeTotalWeeklyAmount, "\(weeklyProcedures.count)")
            self.customView.setupWeeklyTitleIfHasDiscount("\(ReportConsts.total) • \(ReportConsts.last7days)")
        }
    }

    /// Configure amout for Monthly card.
    private func setupMonthlyAmount(procedures: [GetProcedureModel], _ hasDiscount: Bool = false, percent: String = .stringEmpty) {
        /// Here we filter the procedures from current month.
        let monthlyProcedures = viewModel.monthlyProceduresThisMonth(procedures: procedures)
        /// Here we add the values ​​of the procedures of current month.
        let makeTotalMonthlyAmount = viewModel.makeTotalAmount(monthlyProcedures)
        
        if hasDiscount {
            let percentResult = viewModel.percentageFromString(percent: percent, baseAmount: makeTotalMonthlyAmount)
            self.customView.setupMonthlyCard(percentResult, "\(monthlyProcedures.count)")
            self.customView.setupMonthlyTitleIfHasDiscount("\(percent)% do total líquido • \(ReportConsts.thisMonth)")
        } else {
            self.customView.setupMonthlyCard(makeTotalMonthlyAmount, "\(monthlyProcedures.count)")
            self.customView.setupMonthlyTitleIfHasDiscount("\(ReportConsts.total) • \(ReportConsts.thisMonth)")
        }
    }

    /// Configure amouts to payment type card.
    private func setupPaymentTypeAmount(procedures: [GetProcedureModel], _ hasDiscount: Bool = false, percent: String = .stringEmpty) {
       let items = PaymentTypeAmountCardModel(procedures: procedures, viewModel: viewModel)
        if hasDiscount {
            let debitAmount = viewModel.percentageFromString(percent: percent, baseAmount: items.debit)
            let creditAmount = viewModel.percentageFromString(percent: percent, baseAmount: items.credit)
            let cashAmount = viewModel.percentageFromString(percent: percent, baseAmount: items.cash)
            let pixAmount = viewModel.percentageFromString(percent: percent, baseAmount: items.pix)
            self.customView.setupPaymentTypeAmountCard(debitAmount, creditAmount, cashAmount, pixAmount)
        } else {
            self.customView.setupPaymentTypeAmountCard(items.debit, items.credit, items.cash, items.pix)
        }
    }

    /// Share report pdf document.
    private func shareReportPDF(procedures: [GetProcedureModel], _ hasDiscount: Bool = false, percent: String = .stringEmpty) {
        /// Share daily report.
        let dailyProcedures = self.viewModel.dailyProcedures(procedures: procedures)
        let totalDailyAmount = viewModel.makeTotalAmount(procedures.filter({$0.currentDate == viewModel.returnCurrentDate}))
        let totalPercentDaily = viewModel.percentageFromString(percent: percent, baseAmount: totalDailyAmount)
        self.customView.didTapDownloadDailyHistoric = {
            self.sharePDF(dailyProcedures, PDFModel.dailyTitle, .daily, totalPercentDaily, hasDiscount, percent)
        }
        
        /// Share  weekly report.
        let weeklyProcedures = self.viewModel.weeklyProceduresLast7Days(procedures: procedures)
        let totalWeeklyAmount = viewModel.makeTotalAmount(weeklyProcedures)
        let totalPercentWeeklyAmount = viewModel.percentageFromString(percent: percent, baseAmount: totalWeeklyAmount)
        self.customView.didTapDownloadWeeklyHistoric = {
            self.sharePDF(weeklyProcedures, PDFModel.weeklyTitle, .weekly, totalPercentWeeklyAmount, hasDiscount, percent)
        }
    
        /// Share  monthly report.
        let dateRange = viewModel.dateRangeMonthly
        let monthlyProcedures = self.viewModel.monthlyProceduresThisMonth(procedures: procedures)
        let totalMonthlyAmount = viewModel.makeTotalAmount(monthlyProcedures)
        let totalPercentMonthlyAmount = viewModel.percentageFromString(percent: percent, baseAmount: totalMonthlyAmount)
        self.customView.didTapDownloadMonthlyHistoric = {
            self.sharePDF(monthlyProcedures, dateRange, .monthly, totalPercentMonthlyAmount, hasDiscount, percent)
        }
    }
    
    // MARK: - Aux methods
    private func setupNavigationBar() {
        title = ReportConsts.reports
        navigationController?.navigationBar.topItem?.backButtonTitle = .stringEmpty
        navigationController?.navigationBar.tintColor = .MNColors.darkGray
        navigationController?.navigationBar.barTintColor = .white
    }

    /// Creates the pdf based on the registered procedures and opens the sharer.
    private func createAndSharePDF(titleFilePDF: String) {
        pdftable = ConfigurableTable()
        pdftable?.dataSource = self
        PDFBuilder.shared.createPDF()
        PDFBuilder.shared.savePdf(titleFile: titleFilePDF)
    }

    /// Check if you have any procedure registered.
    private func sharePDF(
        _ procedure: [GetProcedureModel],
        _ titlePDF: String,
        _ type: ReportType,
        _ totalAmount: String = .stringEmpty,
        _ hasDiscount: Bool = false, _ percent: String = .stringEmpty
    ) {
        if procedure.isEmpty {
            self.showAlert(title: MNConstants.ops, messsage: "\(ReportConsts.withOutProcedure) \(type.rawValue) \(ReportConsts.reportGenerate)")
        } else {
            let hasPercentageText = "\(ReportConsts.totalPercent) \(percent)\(ReportConsts.atRange) \(type.rawValue): \(totalAmount)"
            let hasNoPercentageText = ReportConsts.noPorcentApplyed
            self.amountDiscount = hasDiscount ? hasPercentageText : hasNoPercentageText
            self.procedures = procedure
            self.createAndSharePDF(titleFilePDF: titlePDF)
        }
    }
}
