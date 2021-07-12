//
//  CollectionCell.swift
//  PlayerTest
//
//  Created by Saeed on 7/2/21.
//

import UIKit
import MediaPlayer

class CollectionCell: UICollectionViewCell {
    
    private var video: Video!
    
    var isPlaying: Bool {
        playerView.isPlaying
    }
    
    lazy var playerView: PlayerView = {
        let view = PlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func setup(video: Video) {
        self.video = video
        playerView.playerLayer.player = .init(url: URL(string: self.video.sources.first!)!)
    }
    
    private func setupViews() {
        backgroundColor = .purple
        addSubview(playerView)
        playerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        playerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        playerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        playerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.playerView.layer.frame = self.bounds
        self.playerView.layer.masksToBounds = true
    }
    
    func play() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if self.playerView.player == nil {
                self.playerView.playerLayer.player = .init(url: URL(string: self.video.sources.first!)!)
            }
            self.playerView.player?.play()
        }
        
    }
    
    func stop() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.playerView.player?.pause()
            self.playerView.player = nil
        }
    }
}
