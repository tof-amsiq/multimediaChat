//
//  VideoPlayerViewCell.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 17/10/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//
import AVFoundation
import MMPlayerView
import UIKit


class VideoPlayerViewCell: UICollectionViewCell {

    @IBOutlet weak var videoPlayerView: MMPlayerView!
    
    @IBOutlet weak var playButton: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(videoPlayer(tapGestureRecognizer:)))
        self.playButton.isUserInteractionEnabled = true
        self.playButton.addGestureRecognizer(tapGestureRecognizer)
       
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.playButton.isHidden = false
        self.videoPlayerView.player?.pause()
        videoPlayerView.set(url: nil, state: nil)
        self.videoPlayerView.alpha = 1
        
    }
    
    func setup(urlString: String, isSent: Bool?) {

        if let _isSent = isSent, _isSent == false {
            self.videoPlayerView.alpha = 0.1
        }
        let url = URL.init(string: urlString)!
        videoPlayerView.replace(cover: CoverA.instantiateFromNib())
//        videoPlayerView.set(url: url, state: nil)
        let thubImage = self.videoPreviewUiimage(filePath: urlString) ?? UIImage(named: "unknow")!
        
        videoPlayerView.set(url: url, thumbImage: thubImage, state: { (MMPlayerPlayStatus) in
            switch MMPlayerPlayStatus {
                
            case .ready:
                break
            case .unknown:
                break
            case .failed(let err):
                break
            case .playing:
                break
            case .pause:
                self.playButton.isHidden = true
            case .end:
                self.videoPlayerView.player?.seek(to: kCMTimeZero)
                self.videoPlayerView.thumbImage = thubImage
                self.playButton.isHidden = false 
            }
        } )
    
        
//        videoPlayerView.startLoading()
        
    }
    
    @objc func videoPlayer(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.videoPlayerView.startLoading()
        self.playButton.isHidden = true
        
    }

    
    func videoPreviewUiimage(filePath:String) -> UIImage? {
        
        let vidURL = NSURL(fileURLWithPath:filePath)
        let asset = AVURLAsset(url: vidURL as URL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 2, preferredTimescale: 60)
        
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage(cgImage: imageRef)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
    
}
