//
//  MainViewController.swift
//  BaeminPracPracPrac
//
//  Created by 최동호 on 2018. 3. 22..
//  Copyright © 2018년 최동호. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import AVFoundation
import MediaPlayer

struct Post {
    let _id: String
    let artist: String
    let title: String
    let body: String
    let cover: String
    let tags: [JSON]
    let publishedDate: String
    let trackNameArray: [JSON]
    let trackFileNameArray: [JSON]
}

class MainViewController: UIViewController {
    
    var PostList = [Post]()
    
    let dateFormatter = DateFormatter()
    
    var page: Int = 1
    
    var lastPage: Int?
    
    let group = DispatchGroup()
    let updateQ1 = DispatchQueue(label: "start")
    let updateQ2 = DispatchQueue(label: "end")
    
    
    lazy var topTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Home"
        label.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.semibold)
        
        return label
    }()
    
    lazy var postCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: "cellId")
        cv.backgroundColor = .black
        cv.alwaysBounceVertical = true
        
        return cv
    }()
    
    
    let RealPlayer: AudioPlayer = {
        let p = AudioPlayer(frame: .zero)
        p.translatesAutoresizingMaskIntoConstraints = false
        return p
    }()
    
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollHeight = scrollView.frame.size.height
        
        if offsetY > contentHeight - scrollHeight && offsetY > 0
        {
            if let lp = self.lastPage {
                if lp < self.page {
                    return
                }
                else {
                    self.page += 1
                }
                fetchPostList(urlStr: "http://ipAddress/api/post?page=\(self.page)", appending: true)
            }
            
            
        }
    }
    

    var barStyle: UIStatusBarStyle = .lightContent
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return barStyle
    }
   
  
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        
        self.view.backgroundColor = .black
//
//
       
      self.navigationController?.navigationBar.barTintColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
            

        } catch {
            print(error)
        }

        
      
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.PlayerIsPlaying, object: nil, queue: OperationQueue.main) { (noti) in
            UIView.animate(withDuration: 0.2, animations: {
                self.RealPlayer.alpha = 1.0
                AudioPlayer.sharedInstance.playButton.setTitle("||", for: UIControlState.normal)
            })
        }
        
        let window = UIApplication.shared.keyWindow!
        window.addSubview(RealPlayer)
        RealPlayer.alpha = 0.0
        RealPlayer.leftAnchor.constraint(equalTo: window.leftAnchor, constant: 0).isActive = true
        if #available(iOS 11.0, *) {
            RealPlayer.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        } else {
            RealPlayer.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: 0).isActive = true
        }
        RealPlayer.rightAnchor.constraint(equalTo: window.rightAnchor, constant: 0).isActive = true
        RealPlayer.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentPlayerView))
//        tap.delegate = self as! UIGestureRecognizerDelegate
        RealPlayer.addGestureRecognizer(tap)
        
        setupViews()
        fetchPostList()
        
//        setupNowPlayingInfo()
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    
   
    


    @objc func presentPlayerView() {
//        print("tapped")
        let playerVC = PlayerViewController()
        
        guard let post = AudioPlayer.sharedInstance.post else {
            return
        }
        
        playerVC.audioItems.removeAll()
        playerVC.audioTitles.removeAll()
        for file in post.trackFileNameArray {
            guard let url = URL(string: "http://ipAddress/uploads/\(file)") else {
                return
            }
            playerVC.audioItems.append(AVPlayerItem(url: url))
//            print("items: \(PlayerViewController.sharedInstance.audioItems)")
        }
        
        for name in post.trackNameArray {
           playerVC.audioTitles.append("\(name)")
        }
        
        navigationController?.present(playerVC, animated: true, completion: nil)
    }
//
    func setupViews() {
        self.title = "Home"
        
        view.addSubview(postCollectionView)
        if #available(iOS 11.0, *) {
            postCollectionView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 0).isActive = true
        } else {
            postCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        }
        
        postCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        postCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        postCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true

        
    }
    
    
   
    
  
    
    

    
    
    
    
    
    
    func fetchPostList(urlStr: String = "http://ipAddress/api/post", appending: Bool = false) {
        
        guard let url = URL(string: urlStr) else {
            return
        }
        
        Alamofire.request(url).responseJSON { (response) in
            if response.result.isSuccess {
                
                if let lp = response.response?.allHeaderFields["Last-Page"] as? String {
                    let lpInt = Int(lp)
                    self.lastPage = lpInt
                }
                
                
                if appending {
                    if let dict = response.result.value {
                        let json = JSON(dict)
                        
                        for (index, element) in json.enumerated() {
                            
                            guard let _id = json[index]["_id"].string else {
                                return
                            }
                            guard let artist = json[index]["artist"].string else {
                                return
                            }
                            
                            guard let title = json[index]["title"].string else {
                                return
                            }
                            
                            guard let body = json[index]["body"].string else {
                                return
                            }
                            
                            guard let cover = json[index]["cover"].string else {
                                return
                            }
                            
                            guard let tags = json[index]["tags"].array else {
                                return
                            }
                            
                            guard let publishedDate = json[index]["publishedDate"].string else {
                                return
                            }
                            
                            guard let list = json[index]["list"].dictionary else {
                                return
                            }
                            guard let trackNameArray = list["name"]?.array else{
                                return
                            }
                            
                            guard let trackFileNameArray = list["track"]?.array else {
                                return
                            }
                            
                            
                            
                            
                            let post = Post(_id: _id, artist: artist, title: title, body: body, cover: cover, tags: tags, publishedDate: publishedDate, trackNameArray: trackNameArray, trackFileNameArray: trackFileNameArray)
                            
                            self.PostList.append(post)
                            
                            DispatchQueue.main.async {
                                self.postCollectionView.reloadData()
                            }
                        }
                        //                    print(self.PostList)
                        
                        
                    } else {
                        fatalError()
                    }
                } else {
                    self.PostList.removeAll()
                    if let dict = response.result.value {
                        let json = JSON(dict)
                        
                        for (index, element) in json.enumerated() {
                            
                            guard let _id = json[index]["_id"].string else {
                                return
                            }
                            guard let artist = json[index]["artist"].string else {
                                return
                            }
                            
                            guard let title = json[index]["title"].string else {
                                return
                            }
                            
                            guard let body = json[index]["body"].string else {
                                return
                            }
                            
                            guard let cover = json[index]["cover"].string else {
                                return
                            }
                            
                            guard let tags = json[index]["tags"].array else {
                                return
                            }
                            
                            guard let publishedDate = json[index]["publishedDate"].string else {
                                return
                            }
                            
                            guard let list = json[index]["list"].dictionary else {
                                return
                            }
                            guard let trackNameArray = list["name"]?.array else{
                                return
                            }
                            
                            guard let trackFileNameArray = list["track"]?.array else {
                                return
                            }
                            
                            
                            
                            
                            let post = Post(_id: _id, artist: artist, title: title, body: body, cover: cover, tags: tags, publishedDate: publishedDate, trackNameArray: trackNameArray, trackFileNameArray: trackFileNameArray)
                            
                            self.PostList.append(post)
                            
                            DispatchQueue.main.async {
                                self.postCollectionView.reloadData()
                            }
                        }
                        //                    print(self.PostList)
                        
                        
                    } else {
                        fatalError()
                    }
                }
            } else {
                fatalError()
            }
        }
    }

    
    

    
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.PostList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! PostCollectionViewCell
        cell.backgroundColor = .black
        let targetPost = PostList[indexPath.row]        
        
        let coverUrlStr = "http://ipAddress/uploads/\(targetPost.cover)"
        
        if let url = URL(string: coverUrlStr) {
            cell.imageView.kf.setImage(with: url)
        }
        cell.titleLabel.text = targetPost.title
        
        cell.nameLabel.text = "by \(targetPost.artist)"
        let splittedDate = targetPost.publishedDate.components(separatedBy: "T")
        if splittedDate.count > 0 {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let parsedDate = dateFormatter.date(from: splittedDate[0]) {
                let split = String.init(describing: parsedDate).split(separator: " ")[0]
                cell.publishedDateLabel.text = "\(split)"
            }
        }
        
        let tags = targetPost.tags
        var tagStr = ""
        for tag in tags {
            tagStr += "#\(tag) "
        }
        cell.tagsLabel.text = tagStr
        
        return cell
    }
    
    

    
    
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 480)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let targetPost = PostList[indexPath.row]        
        
        AudioPlayer.sharedInstance.post = targetPost
        
        let destVC = DetailViewController()
        let coverUrlStr = "http://ipAddress/uploads/\(targetPost.cover)"
        
        if let url = URL(string: coverUrlStr) {
            destVC.topImageView.kf.setImage(with: url)
        }
        
        destVC.albumTitle = targetPost.title
        destVC.artist = targetPost.artist
        destVC.trackNames = targetPost.trackNameArray
        
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    
   
    
}




