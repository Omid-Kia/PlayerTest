//
//  CollectionCell.swift
//  PlayerTest
//
//  Created by Saeed on 7/2/21.
//

import UIKit
import MediaPlayer

class CollectionCell: UICollectionViewCell {
    
    lazy var playerView: PlayerView = {
        let view = PlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    func setup(video: Video) {
        backgroundColor = .purple
        playerView.playerLayer.player = .init(url: URL(string: video.sources.first!)!)
    }
    
    private func setupViews() {
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
    
    func play() {
        self.playerView.player?.play()
    }
    
    func stop() {
        self.playerView.player?.pause()
    }
}
