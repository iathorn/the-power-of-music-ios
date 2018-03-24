//
//  PlayListTableViewCell.swift
//  BaeminPracPracPrac
//
//  Created by 최동호 on 2018. 3. 24..
//  Copyright © 2018년 최동호. All rights reserved.
//

import UIKit

class PlayListTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    let title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.textColor = .white
        return label
    }()
    
    func setupViews() {
        let margins = contentView.layoutMargins
        contentView.addSubview(title)
        
        title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        title.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: margins.left).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
