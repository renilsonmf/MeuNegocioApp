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
    var pendingFilter: ButtonFilterType? = nil
    private var currentFilter: ButtonFilterType = .all
    
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
        setupBindings()
    }
    
    override func loadView() {
        super.loadView()
        self.view = customView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        // Aplica pendingFilter ou reseta para .all
        currentFilter = pendingFilter ?? .all
        pendingFilter = nil
        customView.currentIndexFilter = currentFilter
        let filtered = getFilteredProcedures(by: currentFilter)
        let title = currentFilter == .all ? "Faturamento total" : currentFilter.resumeCardTitle
        updateCardResume(with: filtered, title: title)
        viewModel.input.loadHome()
    }

    // MARK: - Bind

    private func setupBindings() {
        viewModel.output.procedures.bind() { [weak self] result in
            guard let self else { return }
            
            self.procedures = result
            NotificationCenter.default.post(name: .didUpdateProceduresForReport, object: nil, userInfo: ["procedures": self.procedures])
            
            // Sempre aplica o filtro atual ao receber novos dados
            let filtered = self.getFilteredProcedures(by: self.currentFilter)
            let title = self.currentFilter == .all ? "Faturamento total" : self.currentFilter.resumeCardTitle
            self.updateCardResume(with: filtered, title: title)
            self.customView.totalReceiptCard.loadingIndicatorView(show: false)
            self.openRateApp()
        }
        
        viewModel.output.userData.bind { [weak self] user in
            self?.userData = user
            self?.customView.userName = user?.name ?? ""
        }
    }

    private func bindProperties() {
        viewModel.input.loadHome()
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
        currentFilter = type
        let filtered = getFilteredProcedures(by: type)
        updateCardResume(with: filtered, title: type.resumeCardTitle)
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
        
        if value.not && procedures.count > 5 {
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
