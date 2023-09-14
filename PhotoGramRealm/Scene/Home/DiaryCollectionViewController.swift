//
//  DiaryCollectionViewController.swift
//  PhotoGramRealm
//
//  Created by 마르 on 2023/09/14.
//
import UIKit
import RealmSwift

class DiaryCollectionViewController: UIViewController {
    
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    
    var repository = DiaryTableRepository()
    var list: Results<DiaryTable>!
    var cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, DiaryTable>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        list = repository.fetch()
        
        cellRegistration = UICollectionView.CellRegistration(handler: { cell, indexPath, itemIdentifier in
            var content = UIListContentConfiguration.valueCell()
            content.text = itemIdentifier.diaryTitle
            content.textProperties.font = .boldSystemFont(ofSize: 15)
            let dateText = "\(itemIdentifier.diaryDate)".prefix(10)
            content.secondaryText = "\(dateText)"
            content.image = UIImage(systemName: "star")
            content.imageProperties.tintColor = .systemPink
            
            cell.contentConfiguration = content
            
            var backgroundConfig = UIBackgroundConfiguration.listPlainCell()
            //backgroundConfig.backgroundColor = .black
            backgroundConfig.strokeWidth = 1
            backgroundConfig.strokeColor = .systemPink
            
            cell.backgroundConfiguration = backgroundConfig
        })
        
    }
    
    static func layout() -> UICollectionViewLayout {
        
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.backgroundColor = .black
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        return layout
        
    }
}

extension DiaryCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = list[indexPath.row]
        let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: data)
        
        return cell
    }
    
    
}

