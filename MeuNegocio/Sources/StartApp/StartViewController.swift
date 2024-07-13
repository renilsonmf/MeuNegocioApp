//
//  StartViewController.swift
//  MeuNegocio
//
//  Created by Renilson Moreira on 27/10/22.
//

import UIKit
import Lottie

class StartViewController: CoordinatedViewController {
    
    private let viewModel: StartViewModelProtocol
    private var animationView: AnimationView?
    
    init(viewModel: StartViewModelProtocol, coordinator: CoordinatorProtocol){
        self.viewModel = viewModel
        super.init(coordinator: coordinator)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        showAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.validate()
    }
    
    private func showAnimation() {
        animationView = .init(name: "loading")
        animationView?.frame = view.bounds
        animationView?.contentMode = .scaleAspectFit
        animationView?.loopMode = .loop
        animationView?.animationSpeed = 0.5
        view.addSubview(animationView!)
        animationView?.play()
    }
}
