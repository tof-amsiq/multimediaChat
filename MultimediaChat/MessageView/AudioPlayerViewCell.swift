//
//  AudioPlayerViewCell.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 18/10/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//
import AVFoundation
import UIKit

class AudioPlayerViewCell:UICollectionViewCell {
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    var audioPlayer: AVPlayer?
    var songDuration = Timer()
    var isPlaying = false
    private var audioURL: String?
    
    @IBOutlet weak var timeLabel: UILabel!
    
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.leadingConstraint.constant = 50
        self.progressView.layer.cornerRadius = 12
        self.progressView.clipsToBounds = true
        self.timeLabel.textColor = .white
        self.progressView.trackTintColor = .blue
        self.progressView.progressTintColor = UIColor(red: 0.1608, green: 0.749, blue: 0.949, alpha: 1.0)
        self.progressView.setProgress(0, animated: true)
        self.progressView.progressViewStyle = .bar
        self.playButton.setImage(#imageLiteral(resourceName: "play_button"), for: .normal)
        
        
    }
    
    func setup(url: String, isSent: Bool?) {
        if let _isSent = isSent, _isSent == false {
            self.alpha = 0.1
        }
        self.audioURL = url
        self.play()
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: audioPlayer?.currentItem)
    }
    
    func play() {
        
        do {
            if let _audioURL = self.audioURL, let soundUrl = URL(string: _audioURL) {
                let playerItem = AVPlayerItem(url: soundUrl)
                audioPlayer =  AVPlayer(playerItem:playerItem)
               
                self.setupProgressView()
                self.isPlaying = false
            }
        }
    }
    
    
    func setupProgressView() {
        
        let currentTime = CMTimeGetSeconds((((audioPlayer?.currentTime()) ?? kCMTimeZero )))
        let duration = CMTimeGetSeconds((audioPlayer?.currentItem?.asset.duration) ?? kCMTimeZero)
        
        self.progressView.progress = Float(currentTime) / Float(duration)
        let time = self.secondsMinutesSeconds(seconds: Int(currentTime))
        let duratuion = self.secondsMinutesSeconds(seconds: Int(duration ))
        self.timeLabel.text = "\(time.0) : \(time.1) / \(duratuion.0) : \(duratuion.1)"
    }
    
    func secondsMinutesSeconds (seconds : Int) -> (Int, Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        print("Video Finished")
        songDuration.invalidate()
        self.audioPlayer?.seek(to: kCMTimeZero)
        self.playButton.setImage(#imageLiteral(resourceName: "play_button"), for: .normal)
        self.isPlaying = false
        self.setupProgressView()
    }
    
    @IBAction func onTapPlayButton(_ sender: Any) {
        if isPlaying {
            self.playButton.setImage(#imageLiteral(resourceName: "play_button"), for: .normal)
            audioPlayer?.pause()
            self.songDuration.invalidate()
            self.isPlaying = false
        } else {
            self.playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            audioPlayer?.play()
            self.songDuration = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
            self.songDuration.fire()
            self.isPlaying = true
            
        }
        
    }
    
    @objc func update() {
        self.setupProgressView()
    }
    
    
    deinit {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
}
