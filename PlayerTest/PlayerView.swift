//
//  PlayerView.swift
//  PlayerTest
//
//  Created by Saeed on 7/2/21.
//

import UIKit
import AVKit
import AVFoundation

class PlayerView: UIView {
    override static var layerClass: AnyClass {
        AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }
    
    var player: AVPlayer? {
        get {
            playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    var isPlaying: Bool {
        player?.rate != 0
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        commonInit()
    }
    private func commonInit() {
        self.playerLayer.frame = self.bounds
        self.playerLayer.masksToBounds = true

    }
}
