//
//  BannerTableViewCell.swift
//  BaeminPracPracPrac
//
//  Created by 최동호 on 2018. 3. 24..
//  Copyright © 2018년 최동호. All rights reserved.
//

import UIKit

class BannerTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = .white

        return label
    }()
    
    let artistLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Artist"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white

        return label
    }()
    
  
    
    func setupViews() {
        let margin = layoutMargins
        contentView.addSubview(titleLabel)
        contentView.addSubview(artistLabel)
        titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin.top).isActive = true
        
        artistLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        
        
       
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
