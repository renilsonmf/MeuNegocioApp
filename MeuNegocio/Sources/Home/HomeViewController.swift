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
        didSelectedFilter: weakify { $0.didSelectFilter($1) },
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
        customView.currentIndexFilter = .all
        bindProperties()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Bind
    
    private func bindProperties() {
        
        viewModel.input.loadHome()
        
        viewModel.output.procedures.bind() { [weak self] result in
            guard let self else { return }
            
            self.procedures = result.reversed()
            
            self.updateCardResume(with: self.procedures, title: "Faturamento total")
            
            self.customView.totalReceiptCard.loadingIndicatorView(show: false)
        }
        
        viewModel.output.userData.bind { [weak self] user in
            self?.userData = user
            self?.customView.userName = user?.name ?? ""
        }
    }
    
    // MARK: - UI Update
    
    private func updateCardResume(with procedures: [GetProcedureModel], title: String) {
        
        customView.procedures = procedures
        
        customView.totalReceiptCard.setupCardValues(
            title: title,
            totalValues: viewModel.input.makeTotalAmounts(procedures),
            procedureValue: "\(procedures.count)"
        )
        
        reloadData()
    }
    
    // MARK: - Actions
    
    private func didPullToRefresh() {
        
        bindProperties()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.customView.tableview.refreshControl?.endRefreshing()
            self.customView.currentIndexFilter = .all
            self.reloadData()
        }
    }
    
    private func reloadData() {
        customView.tableview.reloadData()
    }
    
    // MARK: - Filter Logic
    
    private func didSelectFilter(_ type: ButtonFilterType) {
        TrackEvent.track(event: type.trackEvent)
        
        let filtered = getFilteredProcedures(by: type)
        
        updateCardResume(
            with: filtered,
            title: type.resumeCardTitle
        )
    }
    
    private func getFilteredProcedures(by filter: ButtonFilterType) -> [GetProcedureModel] {
        
        switch filter {
        case .all:
            return procedures
        case .today:
            return procedures.filter { $0.currentDate == returnCurrentDate }
        case .sevenDays:
            let dates = Date.getDates(forLastNDays: 7)
            return procedures.filter { dates.contains($0.currentDate) }
        case .thirtyDays:
            let dates = Date.getDatesOfCurrentMonth()
            return procedures.filter { dates.contains($0.currentDate) }
        case .custom(let start):
            return procedures.filter { $0.currentDate == start?.toString() }
        }
    }
    
    // MARK: - Helpers
    
    private func openRateApp() {
        let value = MNUserDefaults.get(boolForKey: MNKeys.rateApp) ?? false
        
        if value.not && procedures.count > 0 {
            viewModel.navigateToRateApp()
        }
    }
    
    private var returnCurrentDate: String {
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        return df.string(from: date)
    }
}

extension ButtonFilterType {
    
    var trackEvent: MNEvent {
        switch self {
        case .all:
            return .homeFilterAll
        case .today:
            return .homeFilterToday
        case .sevenDays:
            return .homeFilterSevenDays
        case .thirtyDays:
            return .homeFilterThisMonth
        case .custom:
            return .homeFilterCustom
        }
    }
}
