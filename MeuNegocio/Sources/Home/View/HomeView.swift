//
//  HomeView.swift
//  MeuNegocio
//
//  Created by Leonardo Portes on 07/02/22.
//

import UIKit

final class HomeView: UIView, ViewCodeContract {
    
    // MARK: - Actions properties
    private var openReport: Action?
    private var openAlertAction: Action?
    private var openProfile: Action?
    private var openAddProcedure: Action?
    private var openHelp: Action?
    private var openProcedureDetails: (GetProcedureModel) -> Void?
    private var didPullRefresh: Action?
    private var didSelectedFilter: (ButtonFilterType) -> Void?

    // MARK: - Properties
    var procedures: [GetProcedureModel] = [] {
        didSet {
            tableview.reloadData()
            tableview.loadingIndicatorView(show: false)
        }
    }

    var currentIndexFilter: ButtonFilterType = .all {
        didSet {
            filterView.currentIndexFilter = currentIndexFilter
        }
    }
    
    var userName: String = .stringEmpty {
        didSet {
            profileHeaderView.setupLayout(nameUser: userName )
        }
    }
    
    // MARK: - Init
    init(
        navigateToReport: @escaping Action,
        alertAction: @escaping Action,
        navigateToProfile: @escaping Action,
        navigateToAddProcedure: @escaping Action,
        navigateToHelp: @escaping Action,
        openProcedureDetails: @escaping (GetProcedureModel) -> Void?,
        didPullRefresh: @escaping Action,
        didSelectedFilter: @escaping (ButtonFilterType) -> Void?
    ) {
        self.openReport = navigateToReport
        self.openAlertAction = alertAction
        self.openProfile = navigateToProfile
        self.openAddProcedure = navigateToAddProcedure
        self.openHelp = navigateToHelp
        self.openProcedureDetails = openProcedureDetails
        self.didPullRefresh = didPullRefresh
        self.didSelectedFilter = didSelectedFilter
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Header
    private lazy var profileHeaderView: ProfileHeaderView = {
        let view = ProfileHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .MNColors.yellow
        view.setupAction(actionButton: weakify { $0.openProfile?()})
        return view
    }()
    
    // MARK: - Section Cards
    private lazy var sectionCardsView: UIStackView = {
        let stack = UIStackView()
        stack.backgroundColor = .MNColors.lightGray
        stack.axis = .vertical
        stack.spacing = 16
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var totalReceiptCard = TotalReceiptCardView() .. {
        $0.loadingIndicatorView(show: true)
    }
    
    lazy var filterView = FilterSegmentedControl(
        didSelectedFilter: weakify { $0.didSelectedFilter($1) }
    )
    
    // MARK: - Main
    private lazy var mainBaseView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var tableview: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(ProcedureTableViewCell.self, forCellReuseIdentifier: ProcedureTableViewCell.identifier)
        table.register(ErrorTableViewCell.self, forCellReuseIdentifier: ErrorTableViewCell.identifier)
        table.refreshControl = UIRefreshControl()
        table.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        table.separatorStyle = .none
        table.backgroundColor = .white
        table.loadingIndicatorView()
        return table
    }()
    
    // MARK: - Actions Cards
    @objc private func pullToRefresh() {
        self.didPullRefresh?()
    }
    
    @objc func didTapCardReport(_ sender: UITapGestureRecognizer) {
        openReport?()
    }
    
    @objc func didTapCardInfo(_ sender: UITapGestureRecognizer) {
        openHelp?()
    }
    
    @objc func didTapCardMore(_ sender: UITapGestureRecognizer) {
        openAddProcedure?()
    }

    // MARK: - Viewcode methods
    func setupHierarchy() {
        addSubview(profileHeaderView)
        addSubview(sectionCardsView)
        addSubview(mainBaseView)
        
        sectionCardsView.addArrangedSubview(totalReceiptCard)
        sectionCardsView.addArrangedSubview(filterView)
        
        mainBaseView.addSubview(tableview)
    }
    
    func setupConstraints() {
        
        NSLayoutConstraint.activate([
            // MARK: - Header
            profileHeaderView.topAnchor.constraint(equalTo: topAnchor),
            profileHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            profileHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            profileHeaderView.heightAnchor.constraint(equalToConstant: 120),

            // MARK: - Section Cards
            sectionCardsView.topAnchor.constraint(equalTo: profileHeaderView.bottomAnchor),
            sectionCardsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sectionCardsView.trailingAnchor.constraint(equalTo: trailingAnchor),

            // MARK: - Main Base View
            mainBaseView.topAnchor.constraint(equalTo: sectionCardsView.bottomAnchor),
            mainBaseView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainBaseView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainBaseView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // MARK: - TableView
            tableview.topAnchor.constraint(equalTo: mainBaseView.topAnchor),
            tableview.leadingAnchor.constraint(equalTo: mainBaseView.leadingAnchor),
            tableview.trailingAnchor.constraint(equalTo: mainBaseView.trailingAnchor),
            tableview.bottomAnchor.constraint(equalTo: mainBaseView.bottomAnchor)
        ])
    }

    
    func setupConfiguration() {
        self.backgroundColor = .MNColors.lightGray
        self.tableview.delegate = self
        self.tableview.dataSource = self
    }
    
}

// MARK: - Extension UITableView Delegate and DataSource
extension HomeView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if procedures.isEmpty { return 1 }
        return procedures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if procedures.isEmpty{
            let cellEmpty = tableview.dequeueReusableCell(withIdentifier: ErrorTableViewCell.identifier, for: indexPath) as? ErrorTableViewCell
            cellEmpty?.isUserInteractionEnabled = false
            return cellEmpty ?? UITableViewCell()
        } else {
            let cell = tableview.dequeueReusableCell(withIdentifier: ProcedureTableViewCell.identifier, for: indexPath) as? ProcedureTableViewCell
            let procedure = procedures[indexPath.row]
            let amounts = Current.shared.formatterAmounts(amounts: procedures)
            let amount = amounts[indexPath.row]
            
            cell?.setupCustomCell(
                title: procedure.nameClient,
                procedure: procedure.typeProcedure,
                price: "\(amount)",
                paymentMethod: "\(procedure.currentDate) • \(procedure.formPayment.rawValue)"
            )
            cell?.setPaymentIcon(method: procedure.formPayment)
            return cell ?? UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let procedure = procedures[indexPath.row]
        self.openProcedureDetails(procedure)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Atendimentos"
    }
}
