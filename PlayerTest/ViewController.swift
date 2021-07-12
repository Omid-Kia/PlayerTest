//
//  ViewController.swift
//  PlayerTest
//
//  Created by Omid Kia on 7/8/21.
//

import UIKit
import Combine

final class ViewController: UIViewController {
    private var dataSource = [Video]()
    @Published private var visibleIndexPath: IndexPath?
    private var disposeBag: Set<AnyCancellable> = []
    private var size: CGSize {
        view.bounds.size
    }
    
    private lazy var layout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = .init(width: size.width, height: 300)
        layout.itemSize = .init(width: size.width, height: self.view.frame.size.height * 0.6)

        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        view.register(CollectionCell.self, forCellWithReuseIdentifier: "cell")
        view.dataSource = self
        view.delegate = self
        view.allowsMultipleSelection = false
        
        return view
    }()
    
    private func loadJsonFile() {
        if let url = Bundle.main.url(forResource: "file", withExtension: "json") {
            if let data = try? Data(contentsOf: url) {
                if let model = try? JSONDecoder().decode(ObjectModel.self, from: data) {
                    dataSource = model.categories.first?.videos ?? []
                    collectionView.reloadData()
                }
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        self.view = collectionView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let firstCell = self.collectionView.cellForItem(at: .init(item: 0, section: 0)) as? CollectionCell {
            if firstCell.backgroundColor != .red {
                firstCell.backgroundColor = .red
            }
            
        }
//        self.visibleIndexPath = .init(item: 0, section: 0)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loadJsonFile()
        $visibleIndexPath
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                guard let `self` = self,
                      let visibleIndexPath = value,
                      let playingCell = self.collectionView.cellForItem(at: visibleIndexPath) as? CollectionCell else { return }
                guard visibleIndexPath != self.visibleIndexPath else { return }
                playingCell.backgroundColor = .red
                self.collectionView.visibleCells.forEach { cell in
                    if let `cell` = cell as? CollectionCell, cell != playingCell {
                        cell.backgroundColor = .purple
                    }
                }
            }
            .store(in: &disposeBag)
            
    }
}




extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionCell
        cell.setup(video: dataSource[indexPath.row])
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        guard let videoCell = (cell as? CollectionCell) else { return }
////        let visibleCells = collectionView.visibleCells
////        let minIndex = visibleCells.startIndex
////        if let firstCell = visibleCells.first as? CollectionCell {
////            firstCell.playerView.player?.play()
////        } else {
//            videoCell.playerView.player?.pause()
//            videoCell.playerView.player = nil
////        }
////        if collectionView.visibleCells.firstIndex(of: cell) == minIndex {
////            videoCell.playerView.player?.play()
////        }
//
//        let center = collectionView.center
//        let indexPath = collectionView.indexPathForItem(at: center)
//        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
//    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let videoCell = cell as? CollectionCell else { return }
        videoCell.playerView.player?.pause()
        videoCell.playerView.player = nil
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
//        collectionView.cellForItem(at: indexPath)?.backgroundColor = .red
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var arr: [Int: CGFloat] = [:]
//        let cells = self.collectionView.getFullyVisibleCells()
//        if let indexPath = cells.first, let playingCell = self.collectionView.cellForItem(at: indexPath) as? CollectionCell {
//            guard !playingCell.playerView.isPlaying else {
//                return
//            }
//            self.visibleIndexPath = indexPath
//            playingCell.backgroundColor = .red
//            playingCell.play()
//            print("playingCell: ", indexPath.item)
//        }
//        self.collectionView.visibleCells.forEach { cell in
//            if let indexPath = self.collectionView.indexPath(for: cell),
//               !cells.contains(indexPath),
//               let notPlayingCell = cell as? CollectionCell {
//                guard notPlayingCell.playerView.isPlaying else {
//                    return
//                }
//                print("not playingCell: ", indexPath.item)
//                notPlayingCell.backgroundColor = .purple
//                notPlayingCell.stop()
//            }
//        }
//        print("visiblecells count", cells.count)
        collectionView.visibleCells.forEach { cell in
            let iter = cell.frame.intersection(collectionView.bounds).size.height / cell.frame.size.height
            if let index = self.collectionView.indexPath(for: cell)?.item {
                arr[index] = iter
            }
        }
        let arr1 = arr.sorted(by: {$0.value > $1.value})
        if let mostVisible = arr1.first, let visibleIndexCell = self.collectionView.cellForItem(at: .init(item: mostVisible.key, section: 0)) as? CollectionCell {
            if visibleIndexCell.backgroundColor != .red {
                print("visible", mostVisible.key)
                visibleIndexCell.backgroundColor = .red
                visibleIndexCell.play()
            }
            let newArr = arr1.filter({$0 != mostVisible})
            newArr.forEach { [weak self] (key: Int, value: CGFloat) in
                guard let `self` = self else { return }
                if let notPlayingIndex = self.collectionView.cellForItem(at: .init(item: key, section: 0)) as? CollectionCell {
                    if notPlayingIndex.backgroundColor != .purple {
                        notPlayingIndex.backgroundColor = .purple
                        notPlayingIndex.playerView.player?.pause()
                        notPlayingIndex.playerView.player = nil
                    }
                }
            }
        }
        
//        let arr1 = arr.values.filter { iter in
//            return iter == 1
//        }
//        if arr1.count > 1 {
//            /// this means there are more than one cell in collectionView bounds intersection
//            /// must play only one cell
//        }
//        arr.forEach { (item: Int, iter: CGFloat) in
//            guard let cell = self.collectionView.cellForItem(at: IndexPath(item: item, section: 0)) else {
//                return
//            }
//            if iter >= 1 {
//                guard let playingCell = cell as? CollectionCell else { return }
//                DispatchQueue.main.async {
//                    guard cell.backgroundColor == .red else {
//                        cell.backgroundColor = .red
//                        playingCell.play()
//                        return
//                    }
//                }
//            } else {
//                guard let notPlayingCell = cell as? CollectionCell else { return }
//                DispatchQueue.main.async {
//                    guard cell.backgroundColor == .purple else {
//                        cell.backgroundColor = .purple
//                        notPlayingCell.stop()
//                        return
//                    }
//
//                }
//
//            }
//        }
        
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        collectionView.visibleCells.forEach { cell in
//            let iter = cell.frame.intersection(collectionView.bounds).size.height / cell.frame.size.height
//            if let index = self.collectionView.indexPath(for: cell)?.item {
//                if iter >= 1 {
//                    guard let playingCell = cell as? CollectionCell else { return }
//                    DispatchQueue.main.async {
//                        cell.backgroundColor = .red
//                        playingCell.play()
//                    }
//
//                    print("cell \(index) is showing fully")
//                } else {
//                    guard let notPlayingCell = cell as? CollectionCell else { return }
//                    DispatchQueue.main.async {
//                        cell.backgroundColor = .purple
//                        notPlayingCell.stop()
//                    }
//
//                }
////                print("cell iter", iter, "cell index", index?.item)
//            }
//
//        }
    }
}

extension UICollectionView {
    func getFullyVisibleCells() -> [IndexPath] {

        var cells = [IndexPath]()

        var visibleCells = self.visibleCells
        visibleCells = visibleCells.filter({ cell -> Bool in
            let cellRect = self.convert(cell.frame, to: self.superview)
            return self.frame.contains(cellRect)
        })

        visibleCells.forEach({
            if let indexPath = self.indexPath(for: $0) {
                cells.append(indexPath)
            }
        })

        return cells

    }
}
