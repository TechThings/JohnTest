////
////  ActivityInfoAmenityTableViewCell.swift
////  FAVE
////
////  Created by Kevin Mun on 25/05/2016.
////  Copyright © 2016 kfit. All rights reserved.
////
//
//import UIKit
//
//class ActivityInfoAmenityTableViewCell: UITableViewCell, CollectionViewContainer {
//    @IBOutlet weak var titleLabel: KFITLabel!
//    @IBOutlet weak var collectionView: UICollectionView!
//    private var dataSource:protocol<UICollectionViewDataSource,UICollectionViewDelegate,CollectionAdapterProtocol>!
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//    
//    func setCollectionViewDataSourceDelegate
//        <D: protocol<UICollectionViewDataSource, UICollectionViewDelegate, CollectionAdapterProtocol>>
//        (dataSourceDelegate: D, forRow row: Int) {
//        dataSource = dataSourceDelegate
//        dataSource.registerCollectionView(collectionView)
//        collectionView.delegate = dataSourceDelegate
//        collectionView.dataSource = dataSourceDelegate
//        collectionView.tag = row
//        collectionView.reloadData()
//    }
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        collectionView.delegate = nil
//        collectionView.dataSource = nil
//        dataSource = nil
//        collectionView.reloadData()
//        collectionView.setContentOffset(CGPointZero, animated: false)
//    }
//
//    
//}
