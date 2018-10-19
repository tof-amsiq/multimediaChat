//
//  VideoPlayerViewCell.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 17/10/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//
import MMPlayerView
import UIKit


class VideoPlayerViewCell: UICollectionViewCell {

    @IBOutlet weak var videoPlayerView: MMPlayerView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let url = URL.init(string: "http://www.html5videoplayer.net/videos/toystory.mp4")!
        videoPlayerView.replace(cover: CoverA.instantiateFromNib())
        videoPlayerView.set(url: url, state: nil)
        videoPlayerView.startLoading()
    }

    
}
