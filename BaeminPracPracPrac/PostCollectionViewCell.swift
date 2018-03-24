//
//  PostCollectionViewCell.swift
//  BaeminPracPracPrac
//
//  Created by 최동호 on 2018. 3. 22..
//  Copyright © 2018년 최동호. All rights reserved.
//

import UIKit

class PostCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = UIColor.green
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Origin Of Symmetry"
        label.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold)
        label.textColor = .white
        return label
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Muse"
        label.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold)
        label.textColor = .white
        return label
    }()
    
    let publishedDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "yyyy-MM-dd"
        label.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.thin)
        label.textColor = .white
        return label
    }()
    
    let tagsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "#Alternative #Progressive"
        label.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.thin)
        label.textColor = .white
        return label
    }()
    
    func setupViews() {
        let margins = contentView.layoutMargins
        
        contentView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margins.top).isActive = true
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: margins.left).isActive = true
        imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant:-margins.right).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 350).isActive = true
        
        contentView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: imageView.leftAnchor, constant: 0).isActive = true
        
        contentView.addSubview(nameLabel)
        nameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: imageView.leftAnchor, constant: 0).isActive = true
        
        contentView.addSubview(publishedDateLabel)
        publishedDateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        publishedDateLabel.leftAnchor.constraint(equalTo: imageView.leftAnchor, constant: 0).isActive = true
        
        contentView.addSubview(tagsLabel)
        tagsLabel.topAnchor.constraint(equalTo: publishedDateLabel.bottomAnchor, constant: 8).isActive = true
        tagsLabel.leftAnchor.constraint(equalTo: imageView.leftAnchor, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
