//
//  ViewController.swift
//  PlayerTest
//
//  Created by Omid Kia on 7/8/21.
//

import UIKit
import Combine
import FLEX

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
            firstCell.play()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        FLEXManager.shared.simulatorShortcutsEnabled = true
        loadJsonFile()
        $visibleIndexPath
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let `self` = self,
                      let visibleIndexPath = value,
                      let playingCell = self.collectionView.cellForItem(at: visibleIndexPath) as? CollectionCell else { return }
                playingCell.play()
                self.collectionView.visibleCells.forEach { cell in
                    if let `cell` = cell as? CollectionCell,
                       cell != playingCell {
                        cell.stop()
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var arr: [Int: CGFloat] = [:]
        collectionView.visibleCells.forEach { [weak self] cell in
            let iter = cell.frame.intersection(collectionView.bounds).size.height / cell.frame.size.height
            if let index = self?.collectionView.indexPath(for: cell)?.item {
                arr[index] = iter
            }
        }
        let sortedArr = arr.sorted(by: {$0.value > $1.value})
        guard let item = sortedArr.first?.key,
              IndexPath(item: item, section: 0) != self.visibleIndexPath else { return }
        self.visibleIndexPath = IndexPath(item: item, section: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        FLEXManager.shared.showExplorer()

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
