//
//  AudioPlayer.swift
//  the-power-of-music-ios
//
//  Created by 최동호 on 2018. 3. 11..
//  Copyright © 2018년 최동호. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

extension Notification.Name {
    static let PlayerSetupCompleted = Notification.Name("PlayerSetupCompleted")
    static let SetPausedText = Notification.Name("SetPausedText")
    static let SetPlayImage = Notification.Name("SetPlayImage")
    static let SetHighlight = Notification.Name("SetHighlight")
    static let PlayerIsPlaying = Notification.Name("PlayerIsPlaying")
    
}

class AudioPlayer: UIView {
    
    
    let group = DispatchGroup()
    let updateQ1 = DispatchQueue(label: "start")
    let updateQ2 = DispatchQueue(label: "end")
    
    
//    override var canBecomeFirstResponder: Bool {
//        return true
//    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.becomeFirstResponder()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.SetPausedText, object: nil, queue: OperationQueue.main) { (noti) in
            self.playButton.setTitle("||", for: UIControlState.normal)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.SetPlayImage, object: nil, queue: OperationQueue.main) { (noti) in
            self.playButton.setTitle("▶", for: UIControlState.normal)
        }
        
        
        backgroundPlay()
        setupViews()
        setupPlayer()
    }
    
    let playButton: UIButton = {
        let btn = UIButton(type: UIButtonType.system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("▶", for: UIControlState.normal)
        btn.addTarget(self, action: #selector(clickPlay), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    let progressSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(updateProgress), for: UIControlEvents.valueChanged)
        
        return slider
    }()
    
    let initTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        return label
    }()
    
    
    func setupViews() {
        backgroundColor = .white
        addSubview(playButton)
        playButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        playButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        
        addSubview(progressSlider)
        progressSlider.leftAnchor.constraint(equalTo: playButton.rightAnchor, constant: 8).isActive = true
        progressSlider.centerYAnchor.constraint(equalTo: playButton.centerYAnchor, constant: 0).isActive = true
        
        addSubview(initTimeLabel)
        initTimeLabel.centerYAnchor.constraint(equalTo: playButton.centerYAnchor, constant: 0).isActive = true
        initTimeLabel.leftAnchor.constraint(equalTo: progressSlider.rightAnchor, constant: 8).isActive = true
        initTimeLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
    }

    @objc func clickPlay(){
        AudioPlayer.sharedInstance.play()

    }
    
    @objc func updateProgress() {
        
        updateQ1.async(group: group, qos: DispatchQoS.default, flags: DispatchWorkItemFlags.detached) {
            AudioPlayer.sharedInstance.player.pause()
        }
        
        updateQ2.async(group: group, qos: DispatchQoS.default, flags: DispatchWorkItemFlags.detached) {
            if let duration = AudioPlayer.sharedInstance.player.currentItem?.duration {
                let totalSeconds = CMTimeGetSeconds(duration)
                
                
                let value = Float64(self.progressSlider.value) * totalSeconds
                
                let seekTime = CMTime(value: Int64(value), timescale: 1)
                
                AudioPlayer.sharedInstance.player.seek(to: seekTime) { (completedSeek) in
                    print("seekTime: \(seekTime)")
                }
                
                
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            AudioPlayer.sharedInstance.player.play()
        }
    }
    
    func setupPlayer() {
        //        print("\(self.player?.currentItem?.asset.duration.seconds)")
        NotificationCenter.default.addObserver(forName: NSNotification.Name.PlayerSetupCompleted, object: nil, queue: OperationQueue.main) { (noti) in
            print("Setup Completed")
            //            self.progressSlider.value = 0.0
            guard let currentSong = AudioPlayer.sharedInstance.player.currentItem else {
                return
            }
            
            
            
            let interval = CMTime(value: 1, timescale: 2)
            AudioPlayer.sharedInstance.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { (progressTime) in
                let seconds = CMTimeGetSeconds(progressTime)
                //                print(seconds)
                let secondsString = String(format: "%02d", Int(seconds.truncatingRemainder(dividingBy: 60)))
                let minutesString = String(format: "%02d", Int(seconds / 60))
                
                self.initTimeLabel.text = "\(minutesString):\(secondsString)"
                
                if let duration = AudioPlayer.sharedInstance.player.currentItem?.duration {
                    let durationSeconds = CMTimeGetSeconds(duration)
                    //                    self.slider.value = Float(seconds / durationSeconds)
                    self.progressSlider.setValue(Float(seconds / durationSeconds), animated: true)
                    
                }
                
            }
            
            
            
        }
        
        
        
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static let sharedInstance = AudioPlayer()
    
    var player: AVPlayer = AVPlayer()
    var audioSession = AVAudioSession.sharedInstance()
    
    var listNum = 1
    //LIST OF Audio Files
    
    var listOfSongs: [String]?
    var post: Post?
    var isInitial = true
    
    var currentSong = 0
    
    var playerVisible: Bool = false
    var isPlaying: Bool = false
    var currentTime: Float64?
    var currentDuration: Float64?

    func backgroundPlay() {
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print(error)
        }
    }
    
    @objc func play() {
//        NotificationCenter.default.post(name: NSNotification.Name.SetHighlight, object: nil)
        NotificationCenter.default.post(name: NSNotification.Name.PlayerIsPlaying, object: nil)

        if self.isInitial {
            guard let trackArray = post?.trackFileNameArray else {
                return
            }
            
            guard let url = URL(string: "http://ipAddress/uploads/\(trackArray[currentSong])") else {
                return
            }
            let playerItem:AVPlayerItem = AVPlayerItem(url: url)
            self.player = AVPlayer(playerItem: playerItem)
            
            self.player.play()
            self.isInitial = false
            NotificationCenter.default.post(name: NSNotification.Name.SetPausedText, object: nil)
//            AudioPlayer.sharedInstance.playButton.setTitle("||", for: UIControlState.normal)
        }
        else {
            if self.player.rate != 0 {
                print("player is playing now..")
                self.player.pause()
                NotificationCenter.default.post(name: NSNotification.Name.SetPlayImage, object: nil)
//                AudioPlayer.sharedInstance.playButton.setTitle("▶", for: UIControlState.normal)
                return
            }
            else {
                self.player.play()
                self.isInitial = false
                NotificationCenter.default.post(name: NSNotification.Name.SetPausedText, object: nil)
//                self.playButton.setTitle("▶", for: UIControlState.normal)
//                AudioPlayer.sharedInstance.playButton.setTitle("||", for: UIControlState.normal)
                return
            }
        }
        
        
        NotificationCenter.default.post(name: NSNotification.Name.PlayerSetupCompleted, object: nil)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: OperationQueue.main) { (noti) in
            AudioPlayer.sharedInstance.playNextSong()
        }
        
        
        
    }
    
    func playNextSong() {
        backgroundPlay()
        
        if self.player.rate != 0 {
            print("player is playing now..")
            self.player.pause()
        }

        guard let trackArray = post?.trackFileNameArray else {
            return
        }
        
        if self.currentSong < trackArray.count - 1 {
            self.currentSong += 1
            
            guard let url = URL(string: "http://ipAddress/uploads/\(trackArray[currentSong])") else {
                return
            }
            let playerItem:AVPlayerItem = AVPlayerItem(url: url)
            self.player = AVPlayer(playerItem: playerItem)
            
            self.player.play()
            NotificationCenter.default.post(name: NSNotification.Name.SetPausedText, object: nil)
            
        } else {
            self.currentSong = 0
            
            guard let url = URL(string: "http://ipAddress/uploads/\(trackArray[currentSong])") else {
                return
            }
            let playerItem:AVPlayerItem = AVPlayerItem(url: url)
            self.player = AVPlayer(playerItem: playerItem)
            NotificationCenter.default.post(name: NSNotification.Name.SetPlayImage, object: nil)
            
        }
        
      
        NotificationCenter.default.post(name: NSNotification.Name.PlayerSetupCompleted, object: nil)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: OperationQueue.main) { (noti) in
            AudioPlayer.sharedInstance.playNextSong()
        }
        
//        NotificationCenter.default.post(name: NSNotification.Name.SetHighlight, object: nil)
        NotificationCenter.default.post(name: NSNotification.Name.PlayerIsPlaying, object: nil)

        
        guard let targetPost = post else {
            return
        }
        
         let controlCenterImage = MPMediaItemArtwork(image: UIImage(named: "back")!)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo =
            [
                MPMediaItemPropertyTitle: "\(targetPost.trackNameArray[currentSong])",
                MPMediaItemPropertyArtist: "\(targetPost.artist)",
                MPMediaItemPropertyArtwork: controlCenterImage,
                MPMediaItemPropertyPlaybackDuration: self.player.currentItem?.asset.duration.seconds,
                MPMediaItemPropertyRating: 1.0,
                MPNowPlayingInfoPropertyElapsedPlaybackTime: CMTimeGetSeconds((self.player.currentItem?.currentTime())!)
        ]
        
    }
    
    func playByIndex(with index: Int) {
    
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        setupControlCenter()
        
        
        self.currentSong = index
        if self.player.rate != 0 {
            self.player.pause()
        }
        
        
        guard let targetPost = self.post else {
            return
        }
        
        
        
        
        
        
        
        
       
        
        guard let trackArray = post?.trackFileNameArray else {
            return
        }
        guard let url = URL(string: "http://ipAddress/uploads/\(trackArray[index])") else {
            return
        }
        
        let playerItem:AVPlayerItem = AVPlayerItem(url: url)
        self.player = AVPlayer(playerItem: playerItem)
        let controlCenterImage = MPMediaItemArtwork(image: UIImage(named: "back")!)
        MPNowPlayingInfoCenter.default().nowPlayingInfo =
            [
                MPMediaItemPropertyTitle: "\(targetPost.trackNameArray[index])",
                MPMediaItemPropertyArtist: "\(targetPost.artist)",
                MPMediaItemPropertyArtwork: controlCenterImage,
                MPMediaItemPropertyPlaybackDuration: self.player.currentItem?.asset.duration.seconds,
                MPMediaItemPropertyRating: 1.0
        ]
        
        self.player.play()
        
        
        NotificationCenter.default.post(name: NSNotification.Name.PlayerSetupCompleted, object: nil)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: OperationQueue.main) { (noti) in
            self.playNextSong()
        }
        NotificationCenter.default.post(name: NSNotification.Name.PlayerIsPlaying, object: nil)

        
        
        
    }
    
    func setupControlCenter() {
        let center = MPRemoteCommandCenter.shared()
        center.nextTrackCommand.isEnabled = true
    }
    
    
    override func remoteControlReceived(with event: UIEvent?) {
        if let event = event {
            if event.type == .remoteControl {
                print("remote control")
                switch event.subtype {
                case .remoteControlTogglePlayPause:
                    AudioPlayer.sharedInstance.play()
                case .remoteControlPlay:
                    AudioPlayer.sharedInstance.play()
                case .remoteControlPause:
                    AudioPlayer.sharedInstance.player.pause()
                case .remoteControlNextTrack:
                    AudioPlayer.sharedInstance.player.pause()
                    AudioPlayer.sharedInstance.playNextSong()
                case .remoteControlPreviousTrack:
                    AudioPlayer.sharedInstance.player.pause()
                    AudioPlayer.sharedInstance.playPrevSong()
                default:
                    print("remote isn't registered")
                }
            }
        }
    }
    
    
    
    func playPrevSong() {
        backgroundPlay()
        if self.player.rate != 0 {
            print("player is playing now..")
            self.player.pause()
        }

        
        guard let trackArray = post?.trackFileNameArray else {
            return
        }
        
        
        if self.currentSong <= 0 {
            self.currentSong = trackArray.count - 1
            
            guard let url = URL(string: "http://ipAddress/uploads/\(trackArray[currentSong])") else {
                return
            }
            let playerItem:AVPlayerItem = AVPlayerItem(url: url)
            self.player = AVPlayer(playerItem: playerItem)
            
            self.player.play()
        } else {
            self.currentSong -= 1
            
            guard let url = URL(string: "http://ipAddress/uploads/\(trackArray[currentSong])") else {
                return
            }
            let playerItem:AVPlayerItem = AVPlayerItem(url: url)
            self.player = AVPlayer(playerItem: playerItem)
            
            self.player.play()
        }
        NotificationCenter.default.post(name: NSNotification.Name.PlayerSetupCompleted, object: nil)
        
        guard let targetPost = post else {
            return
        }
        
        let controlCenterImage = MPMediaItemArtwork(image: UIImage(named: "back")!)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo =
            [
                MPMediaItemPropertyTitle: "\(targetPost.trackNameArray[currentSong])",
                MPMediaItemPropertyArtist: "\(targetPost.artist)",
                MPMediaItemPropertyArtwork: controlCenterImage,
                MPMediaItemPropertyPlaybackDuration: self.player.currentItem?.asset.duration.seconds
        ]
    }
    
    @objc func stopSong() {
        self.player.pause()
        self.currentSong = 0
        self.isInitial = true
    }
    
}

