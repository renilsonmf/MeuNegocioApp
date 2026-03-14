//
//  HomeViewController.swift
//  MeuNegocio
//
//  Created by Leonardo Portes on 07/02/22.
//

import UIKit

final class HomeViewController: CoordinatedViewController {
    
    // MARK: - Properties
    private let viewModel: HomeViewModelProtocol
    private var procedures: [GetProcedureModel] = []
    private var userData: UserModel? = nil

    // MARK: - View
    private lazy var customView = HomeView(
        navigateToReport: weakify { $0.viewModel.navigateToReport(procedures: $0.procedures)},
        alertAction: weakify { $0.showAlert()},
        navigateToProfile: weakify { $0.viewModel.navigateToProfile($0.userData) },
        navigateToAddProcedure: weakify { $0.viewModel.navigateToAddProcedure() },
        navigateToHelp: weakify { $0.viewModel.navigateToHelp() },
        openProcedureDetails: weakify { $0.viewModel.openProcedureDetails($1) },
        didPullRefresh: weakify { $0.didPullToRefresh() },
        didSelectIndexClosure: weakify { $0.didSelectFilter($1) },
        didSelectDateClosure: weakify { $0.didSelectFilterDatePicker($1) }
    )

    // MARK: - Init
    init(viewModel: HomeViewModelProtocol, coordinator: CoordinatorProtocol){
        self.viewModel = viewModel
        super.init(coordinator: coordinator)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = customView
        bindProperties()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        bindProperties()
        self.customView.currentIndexFilter = .all
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func bindProperties() {
        viewModel.input.loadHome()
        viewModel.output.procedures.bind() { [weak self] result in
            self?.customView.procedures = result.reversed()
            self?.procedures = result.reversed()
            self?.customView.totalReceiptCard.setupCardValues(
                totalValues: self?.viewModel.input.makeTotalAmounts(result),
                procedureValue: "\(result.count)")
            self?.customView.totalReceiptCard.loadingIndicatorView(show: false)
        }
        
        viewModel.output.userData.bind { [weak self] user in
            self?.userData = user
            self?.customView.userName = user?.name ?? ""
        }
        
        reloadData()
    }

    private func didPullToRefresh() {
        bindProperties()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.customView.tableview.refreshControl?.endRefreshing()
            self.customView.currentIndexFilter = .all
            self.reloadData()
        }
    }

    private func reloadData() {
        self.customView.tableview.reloadData()
    }
    
    private func filteredProcedures(
            procedures: [GetProcedureModel],
            lastDays: Int = 0,
            isMonthly: Bool = false
    ) -> [GetProcedureModel] {
        let lastDaysDates = isMonthly ? Date.getDatesOfCurrentMonth() : Date.getDates(forLastNDays: lastDays)
        return procedures.filter({ lastDaysDates.contains($0.currentDate) })
    }
    
    func todayProcedures(procedures: [GetProcedureModel]) -> [GetProcedureModel] {
        let procedures = procedures.filter({$0.currentDate == returnCurrentDate})
        return procedures
    }

    var returnCurrentDate: String = {
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        let dateString = df.string(from: date)
        return dateString
    }()

    private func didSelectFilter(_ type: ButtonFilterType) {
        switch type {
        case .all:
            TrackEvent.track(event: .homeFilterAll)
            self.customView.procedures = procedures
        case .today:
            TrackEvent.track(event: .homeFilterToday)
            self.customView.procedures = todayProcedures(procedures: procedures)
        case .sevenDays:
            TrackEvent.track(event: .homeFilterSevenDays)
            self.customView.procedures = filteredProcedures(procedures: procedures, lastDays: 7)
        case .thirtyDays:
            TrackEvent.track(event: .homeFilterThisMonth)
            self.customView.procedures = filteredProcedures(procedures: procedures, isMonthly: true)
        case .custom: print("custom")
        }
    }

    private func openRateApp() {
        let value = MNUserDefaults.get(boolForKey: MNKeys.rateApp) ?? false
        if value.not && procedures.count > 0 {
            self.viewModel.navigateToRateApp()
        }
    }

    private func didSelectFilterDatePicker(_ date: String) {
        let proceduresFiltered = procedures.filter { $0.currentDate == date }
        self.customView.procedures = proceduresFiltered
        self.customView.tableview.reloadData()
    }
}
