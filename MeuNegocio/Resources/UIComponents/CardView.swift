//
//  CardView.swift
//  MeuNegocio
//
//  Created by Leonardo Portes on 28/09/22.
//

import UIKit

class CardView: UIView {
    
    init(
        shadowColor: CGColor = UIColor.black.cgColor,
        shadowOpacity: Float = 0.3,
        shadowOffset: CGSize = CGSize(width: 0.0, height: 1),
        shadowRadius: CGFloat = 2,
        cornerRadius: CGFloat = 10,
        backgroundColor: UIColor = .MNColors.yellow
    ) {
        super.init(frame: .zero)
        self.layer.shadowColor = shadowColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
        self.layer.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
