//
//  AudioPlayerViewCell.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 18/10/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//
import AVFoundation
import UIKit

class AudioPlayerViewCell:UICollectionViewCell, AVAudioPlayerDelegate {
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    var bombSoundEffect: AVAudioPlayer?
    var songDuration = Timer()
    var isPlaying = false
    private var audioBase64: String?
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBAction func onTapPlayButton(_ sender: Any) {
        if isPlaying {
            self.playButton.setImage(#imageLiteral(resourceName: "play_button"), for: .normal)
            bombSoundEffect?.pause()
            self.songDuration.invalidate()
            self.isPlaying = false
        } else {
            self.playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            bombSoundEffect?.play()
            self.songDuration = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
            self.songDuration.fire()
            self.isPlaying = true
            
        }
        
    }
    
    @objc func update() {
        self.setupProgressView()
    }
    
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
    
    func setup(base64: String) {
        self.audioBase64 = base64
        self.play()
        self.bombSoundEffect?.delegate = self
//        songDuration = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    func play() {
//        let path = Bundle.main.path(forResource: "example1.mp3", ofType:nil)!
//        let url = URL(fileURLWithPath: path)
        guard let audioBase64String = self.audioBase64 else {
            return
        }
        let audioData = Data(base64Encoded: audioBase64String)!
       

        do {
            bombSoundEffect = try AVAudioPlayer(data: audioData)
//            bombSoundEffect?.play()
            self.setupProgressView()
            self.isPlaying = false
      
        } catch {
            // couldn't load file :(
        }
    }

    
    
    func secondsMinutesSeconds (seconds : Int) -> (Int, Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func setupProgressView() {
        self.progressView.progress = Float(bombSoundEffect!.currentTime) / Float(bombSoundEffect!.duration)
        let time = self.secondsMinutesSeconds(seconds: Int(bombSoundEffect!.currentTime))
        let duratuion = self.secondsMinutesSeconds(seconds: Int(bombSoundEffect!.duration ))
        self.timeLabel.text = "\(time.0) : \(time.1) / \(duratuion.0) : \(duratuion.1)"
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            songDuration.invalidate()
            self.playButton.setImage(#imageLiteral(resourceName: "play_button"), for: .normal)
            self.isPlaying = false
            self.setupProgressView()
            
        }
    }
}
