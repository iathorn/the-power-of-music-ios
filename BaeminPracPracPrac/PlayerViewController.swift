//
//  PlayerViewController.swift
//  BaeminPracPracPrac
//
//  Created by 최동호 on 2018. 3. 24..
//  Copyright © 2018년 최동호. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {

//    static let sharedInstance = PlayerViewController()
    
    var audioItems: [AVPlayerItem] = [AVPlayerItem]()
    var audioTitles: [String] = [String]()
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        
        setupViews()

//
//        let downGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissGesture))
//        downGesture.direction = .down
//        view.addGestureRecognizer(downGesture)
//
        
    }
    
    @objc func dismissGesture() {
        dismiss(animated: true, completion: nil)
        
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Now Playing List.."
        label.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.semibold)
        label.textColor = .white
        return label
    }()
    
    let closeButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Close", for: UIControlState.normal)
        button.addTarget(self, action: #selector(dismissGesture), for: UIControlEvents.touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    
    lazy var playListTable: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.dataSource = self
        tv.register(PlayListTableViewCell.self, forCellReuseIdentifier: "listCell")
        tv.backgroundColor = .black
        tv.tableFooterView?.backgroundColor = .black
        return tv
    }()
    
    func setupViews() {
        view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 16).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        
        view.addSubview(closeButton)
        closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor, constant: 0).isActive = true
        closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        
        view.addSubview(playListTable)
        playListTable.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        playListTable.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        playListTable.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        playListTable.rightAnchor.constraint(greaterThanOrEqualTo: view.rightAnchor, constant: 0).isActive = true
        
    }


}

extension PlayerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell") as! PlayListTableViewCell
        cell.title.text = audioTitles[indexPath.row]
        cell.backgroundColor = .black
        return cell
    }
    
    
}

extension PlayerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AudioPlayer.sharedInstance.playByIndex(with: indexPath.row)
        NotificationCenter.default.post(name: NSNotification.Name.PlayerIsPlaying, object: nil)
        NotificationCenter.default.post(name: NSNotification.Name.SetPausedText, object: nil)
        
    }
}
