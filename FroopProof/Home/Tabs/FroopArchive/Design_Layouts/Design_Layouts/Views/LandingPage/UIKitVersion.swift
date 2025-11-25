//
//  UIKitVersion.swift
//  Design_Layouts
//
//  Created by David Reed on 7/13/23.
//

import UIKit

class AnnotationDetailView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Annotation Title"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "SubTitle"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Ipsum lorum dolores sumpre compre sseder erre es werelkdh"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 10, weight: .light)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let editButton: UIButton = {
        let button = UIButton()
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .thin)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.white.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.black.cgColor]
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(descriptionLabel)
        addSubview(editButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            descriptionLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            editButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            editButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 50),
            editButton.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


