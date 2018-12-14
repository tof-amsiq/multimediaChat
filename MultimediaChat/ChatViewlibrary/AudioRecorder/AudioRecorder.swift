//
//  AudioRecorder.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 16/11/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//
import AVFoundation
import UIKit

protocol AudioPickerDelegate: class {
    func getAudioBase64(_ url: String?)
}

class AudioRecorder: UIView, AVAudioRecorderDelegate {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var buttonView: UIButton!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
  
    let kCONTENT_XIB_NAME = "AudioRecorderView"
    
  
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    weak var delegate: AudioPickerDelegate?
    
    private var audioBase64 : String?
    private var audioFilePath: URL?
    private var isSendButtonActive = false
    
    var secounds = 20
    var timer = Timer()
    var isTimerRunning = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if self.subviews.count == 0 {
            commonInit()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if self.subviews.count == 0 {
            commonInit()
        }
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
        self.setup()
    }
    
    func setup() {
        
        self.progressView.layer.cornerRadius = 8
        self.progressView.clipsToBounds = true
        self.timeLabel.textColor = .black
        self.progressView.trackTintColor = .red
        self.progressView.progressTintColor = UIColor(red: 0.1608, green: 0.749, blue: 0.949, alpha: 1.0)
        self.progressView.setProgress(0.0, animated: true)
        self.progressView.progressViewStyle = .bar
        
        let time = self.secondsMinutesSeconds(seconds: 20 - self.secounds)
        let duratuion = self.secondsMinutesSeconds(seconds: 20)
        self.timeLabel.text = "\(time.0) : \(time.1) / \(duratuion.0) : \(duratuion.1)"
        
   
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        self.setupProgressView()
    }
    
    func setupProgressView() {
        self.secounds -= 1
        if self.secounds < 0 {
            timer.invalidate()
            self.finishRecording(success: true)
        } else {
            let timeSpent = Float (20 - self.secounds)
            let maxRecordTime = Float(20)
            var progress = Float(timeSpent / maxRecordTime)
            if progress < 0.1 {
                progress = Float(0)
            }
            self.progressView.progress = progress
            debugPrint(progress)
            let time = self.secondsMinutesSeconds(seconds: 20 - self.secounds)
            let duratuion = self.secondsMinutesSeconds(seconds: 20)
            self.timeLabel.text = "\(time.0) : \(time.1) / \(duratuion.0) : \(duratuion.1)"
        }
    }
    
    func secondsMinutesSeconds (seconds : Int) -> (Int, Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func loadRecordingUI() {
        self.buttonView.setTitle("Tap to Record", for: .normal)
        self.buttonView.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
    }
    
    func startRecording() {
        self.runTimer()
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatterGet.string(from: Date())
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(date)recording.m4a")
        
        self.audioFilePath = audioFilename
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            self.buttonView.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        timer.invalidate()
        
        if success {
            self.buttonView.setTitle("Send", for: .normal)
            self.isSendButtonActive = true
        } else {
            self.buttonView.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }
    
    @objc func recordTapped() {
        if audioRecorder == nil {
            if isSendButtonActive {
                if let audioURL = self.audioFilePath {
                    delegate?.getAudioBase64(audioURL.absoluteString)
                    self.reset()
                }
            } else {
                startRecording()
            }
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func reset(){
        self.isSendButtonActive = false
        self.secounds = 20
        self.progressView.setProgress(0.0, animated: false)
        let time = self.secondsMinutesSeconds(seconds: 20 - self.secounds)
        let duratuion = self.secondsMinutesSeconds(seconds: 20)
        self.timeLabel.text = "\(time.0) : \(time.1) / \(duratuion.0) : \(duratuion.1)"
        self.buttonView.setTitle("Tap to Record", for: .normal)
    }
 


}
