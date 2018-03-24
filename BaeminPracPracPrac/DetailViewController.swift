//
//  DetailViewController.swift
//  BaeminPracPracPrac
//
//  Created by 최동호 on 2018. 3. 23..
//  Copyright © 2018년 최동호. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import MediaPlayer

class DetailViewController: UIViewController {
    
    var albumTitle: String?
    var artist: String?
    var trackNames: [JSON]?
    
    let group = DispatchGroup()
    let updateQ1 = DispatchQueue(label: "start")
    let updateQ2 = DispatchQueue(label: "end")
    
    

    
    let topImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .orange
        iv.image = UIImage(named: "back")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let topView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        return view
    }()
    
    let backButtonWhite: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(named: "back-white"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(goBack), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    let backButtonBlack: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(named: "back-black"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(goBack), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.semibold)
        return label
    }()
    
    
    lazy var listTableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.dataSource = self
        tv.register(InfoTableViewCell.self, forCellReuseIdentifier: "infoCell")
        tv.register(BannerTableViewCell.self, forCellReuseIdentifier: "bannerCell")
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "dummyCell")
        if let heightConstraint = topImageViewHeightConstraint {
            tv.contentInset = UIEdgeInsets(top: heightConstraint.constant, left: 0, bottom: 0, right: 0)
            tv.scrollIndicatorInsets = tv.contentInset
        }
        
        tv.backgroundColor = .clear
        tv.showsVerticalScrollIndicator = false
        tv.separatorStyle = .none
        
    
        
        return tv
    }()
    
    
    
    
    var topImageViewHeightConstraint: NSLayoutConstraint?
    
    let RealPlayer: AudioPlayer = {
        let p = AudioPlayer(frame: .zero)
        p.translatesAutoresizingMaskIntoConstraints = false
        return p
    }()
    
    
    var barStyle: UIStatusBarStyle = .lightContent
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return barStyle
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        self.navigationController?.navigationBar.tintColor = .white
        
        
        setupViews()
        
        setNeedsStatusBarAppearanceUpdate()
        
        
        
        
    }
    
    
    func setupViews() {
        
        
        
        topImageViewHeightConstraint = NSLayoutConstraint(item: topImageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 300)
        
        
        view.addSubview(topImageView)
        guard let heightConstraint = topImageViewHeightConstraint else {
            return
        }
        topImageView.topAnchor.constraint(equalTo: view.topAnchor, constant:0).isActive = true
        topImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        topImageView.addConstraint(heightConstraint)
        topImageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        
        
        
        view.addSubview(listTableView)
        listTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        listTableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        listTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        listTableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        
    }
    
    
    
    @objc func goBack() {
         self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
    
    
    
    
    
    
}


extension DetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        let diff = offsetY + 50
        guard let heightConstraint = topImageViewHeightConstraint else {
            return
        }
        if offsetY < -50 {
            heightConstraint.constant = 300 + abs(diff)
        } else {
            heightConstraint.constant = 300
        }
        
        
        
    }
}


extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackNames!.count + 2
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let tracks = trackNames else {
            return tableView.dequeueReusableCell(withIdentifier: "dummyCell")!
        }
        
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bannerCell") as! BannerTableViewCell
            cell.backgroundColor = .white
            cell.titleLabel.text = albumTitle
            cell.artistLabel.text = artist
            cell.selectionStyle = .none
            cell.isUserInteractionEnabled = false
            cell.backgroundColor = .black
            return cell
        }
        else if indexPath.row <= tracks.count && indexPath.row != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell") as! InfoTableViewCell
            cell.backgroundColor = .white
            cell.titleLabel.text = "\(tracks[indexPath.row - 1])"
            cell.backgroundColor = .black
            return cell
        }
            
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dummyCell")!
            cell.selectionStyle = .none
            cell.isUserInteractionEnabled = false
            cell.backgroundColor = .black
            return cell
        }
        
        
    }
    
    
}

extension DetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let tracks = trackNames else {
            return 0
        }
        if indexPath.row == 0 {
            return 150
        }
        else if indexPath.row <= tracks.count && indexPath.row != 0 {
            return UITableViewAutomaticDimension
        }
            
        else {
            
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        AudioPlayer.sharedInstance.isInitial = false
        AudioPlayer.sharedInstance.playByIndex(with: indexPath.row - 1)
        NotificationCenter.default.post(name: NSNotification.Name.PlayerIsPlaying, object: nil)
        NotificationCenter.default.post(name: NSNotification.Name.SetPausedText, object: nil)
        
        
        
//        
    }
    
}







