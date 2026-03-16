//
//  FilterSegmentedControl.swift
//  MeuNegocio
//
//  Created by Leonardo Portes on 14/10/22.
//

import UIKit

enum ButtonFilterType: Equatable {
    case all
    case today
    case sevenDays
    case thirtyDays
    case custom(start: Date?)
    
    var titleFilter: String {
        switch self {
        case .all: return "Todos"
        case .today: return "Hoje"
        case .sevenDays: return "7 dias"
        case .thirtyDays: return "Este mês"
        case .custom: return "Personalizado"
        }
    }
    
    var resumeCardTitle: String {
        switch self {
        case .all: return "Total faturado"
        case .today: return "Hoje você faturou"
        case .sevenDays: return "Últimos 7 dias você faturou"
        case .thirtyDays: return "Este mês você faturou"
        case .custom(let start): return start?.toString(format: "dd MMM") ?? "Data selecionada"
        }
    }
}

final class FilterSegmentedControl: UIView, ViewCodeContract {

    private var didSelectedFilter: (ButtonFilterType) -> Void
//    private var didSelectDateClosure: (ButtonFilterType, String) -> Void
    
    private var buttonFilterMap: [UIButton: ButtonFilterType] = [:]
    
    var segmentedControlButtons: [UIButton] = []
    
    let all = SegmentedControlButton(title: ButtonFilterType.all.titleFilter)
    let today = SegmentedControlButton(title: ButtonFilterType.today.titleFilter)
    let sevenDays = SegmentedControlButton(title: ButtonFilterType.sevenDays.titleFilter)
    let thirtyDays = SegmentedControlButton(title: ButtonFilterType.thirtyDays.titleFilter)
    let custom = SegmentedControlButton(title: ButtonFilterType.custom(start: nil).titleFilter)

    var currentIndexFilter: ButtonFilterType = .all {
        didSet {
            if case .all = currentIndexFilter {
                handleSegmentedControlButtons()
                all.backgroundColor = .MNColors.lightBrown
            }
        }
    }
    
    // MARK: - Init
    init(didSelectedFilter: @escaping (ButtonFilterType) -> Void) {
        self.didSelectedFilter = didSelectedFilter
        
        self.segmentedControlButtons = [all, today, sevenDays, thirtyDays, custom]
        
        super.init(frame: .zero)
        
        buttonFilterMap = [
            all: .all,
            today: .today,
            sevenDays: .sevenDays,
            thirtyDays: .thirtyDays
        ]
        
        translatesAutoresizingMaskIntoConstraints = false
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Views
    
    private lazy var container: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: segmentedControlButtons)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentSize = CGSize(width: .zero, height: 30)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private lazy var datePicker: UIDatePicker = {
        let date = UIDatePicker()
        date.datePickerMode = .date
        date.locale = Locale(identifier: "pt-BR")
        date.calendar = Calendar(identifier: .gregorian)
        date.timeZone = TimeZone(identifier: "America/Sao_Paulo")
        date.translatesAutoresizingMaskIntoConstraints = false
        return date
    }()

    // MARK: - Setup
    
    func setupHierarchy() {
        addSubview(container)
        container.addSubview(scrollView)
        scrollView.addSubview(stackView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            container.heightAnchor.constraint(equalToConstant: 30),

            scrollView.topAnchor.constraint(equalTo: container.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 30),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func setupConfiguration() {
        configurePickerView()
        
        segmentedControlButtons.forEach {
            $0.addTarget(
                self,
                action: #selector(handleSegmentedControlButtons(sender:)),
                for: .touchUpInside
            )
        }
    }

    // MARK: - Date Picker
    
    func configurePickerView() {
        custom.addSubview(datePicker)
        
        datePicker
            .topAnchor(in: custom)
            .leftAnchor(in: custom)
            .rightAnchor(in: custom)
            .heightAnchor(250)
            .bottomAnchor(in: custom)
        
        datePicker.tintColor = .MNColors.grayDarkest
        datePicker.alpha = 0.02
        datePicker.isUserInteractionEnabled = true

        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let minimumDate = formatter.date(from: "01/09/2022")
        
        datePicker.minimumDate = minimumDate
        datePicker.calendar.locale = Locale(identifier: "pt-BR")
        datePicker.timeZone = TimeZone(identifier: "America/Sao_Paulo")
        
        datePicker.addTarget(self, action: #selector(editingDidBeginPicker), for: .editingDidBegin)
        datePicker.addTarget(self, action: #selector(editingDidEndPicker(sender:)), for: .editingDidEnd)
    }

    // MARK: - Actions
    
    @objc
    func editingDidBeginPicker() {
        TrackEvent.track(event: .homeFilterCustom)
        handleSegmentedControlButtons()
        custom.backgroundColor = .MNColors.lightBrown
    }

    @objc
    func editingDidEndPicker(sender: UIDatePicker) {
        
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        
        let dateString = df.string(from: sender.date)
        
        custom.setTitle(dateString, for: .normal)
        
        let filter = ButtonFilterType.custom(start: sender.date)
        currentIndexFilter = filter
        
        didSelectedFilter(filter)
    }

    @objc
    func handleSegmentedControlButtons(sender: UIButton? = nil) {
        
        for button in segmentedControlButtons {
            
            if button == sender {
                
                button.backgroundColor = .MNColors.lightBrown
                
                if let filter = buttonFilterMap[button] {
                    currentIndexFilter = filter
                    didSelectedFilter(filter)
                }
                
            } else {
                button.backgroundColor = UIColor(white: 0.1, alpha: 0.1)
            }
        }
        
        if sender != custom {
            custom.setTitle("Personalizado", for: .normal)
        }
    }
}

class SegmentedControlButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(title: String) {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        setTitle(title, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 14)
        setTitleColor(.black, for: .normal)
        backgroundColor = UIColor(white: 0.1, alpha: 0.1)
        
        roundCorners(cornerRadius: 15)
        
        contentEdgeInsets = UIEdgeInsets(
            top: 0,
            left: 12,
            bottom: 0,
            right: 12
        )
        
        layer.borderColor = UIColor.black.cgColor
    }
}
