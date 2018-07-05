//
//  SearchController.swift
//  Audy
//
//  Created by Sammy Yousif on 8/31/17.
//  Copyright © 2017 Sammy Yousif. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class LibraryController: UIViewController {
    
    let bag = DisposeBag()
    
    var tracks: [Track] = MusicLibrary.shared.tracks.value
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 54)
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collection.backgroundColor = UIColor.white
        collection.register(TrackCell.self, forCellWithReuseIdentifier: TrackCell.identifier)
        collection.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: PlayerController.minimizedHeight, right: 0)
        collection.scrollIndicatorInsets = UIEdgeInsets(top: 20, left: 0, bottom: PlayerController.minimizedHeight + 5, right: 0)
        return collection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        MusicLibrary.shared.tracks.asObservable().subscribe(onNext: { [weak self] tracks in
            self?.tracks = tracks
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }).addDisposableTo(bag)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension LibraryController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackCell.identifier, for: indexPath) as! TrackCell
        cell.track = tracks[indexPath.row]
        return cell
    }
}

extension LibraryController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Player.shared.selectTrack(list: self.tracks, index: indexPath.row)
    }
}
