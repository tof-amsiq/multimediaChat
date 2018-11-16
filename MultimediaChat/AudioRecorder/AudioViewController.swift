//
//  AudioRecorderViewController.swift
//  CollectionView
//
//  Created by Tobias Frantsen on 02/10/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//

import AVFoundation
import UIKit

//protocol AudioPickerDelegate: class {
//    func getAudioBase64(_ url: String?)
//}

class AudioViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var recordButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    weak var delegate: AudioPickerDelegate?
    
    private var audioBase64 : String?
    private var audioFilePath: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    
    func loadRecordingUI() {
        
        recordButton.setTitle("Tap to Record", for: .normal)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
    }
    
    func startRecording() {
        
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
            
            recordButton.setTitle("Tap to Stop", for: .normal)
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
        
        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
            
            if let audioURL = self.audioFilePath {
                let dataURL = NSData(contentsOf: audioURL)
                
                let base64String = dataURL?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
              delegate?.getAudioBase64(base64String)
            }
           
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }
    
    @objc func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}
