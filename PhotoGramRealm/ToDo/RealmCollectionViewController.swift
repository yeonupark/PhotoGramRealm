//
//  RealmCollectionViewController.swift
//  PhotoGramRealm
//
//  Created by 마르 on 2023/09/14.
//

import UIKit
import SnapKit
import RealmSwift

class RealmCollectionViewController: BaseViewController {
    
    let realm = try! Realm()
    
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    
    //let list = ["ㅇㅇ", "ㅂㅂ", "ㅎㅎ"]
    var list: Results<ToDoTable>!
    
    var cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, ToDoTable>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        list = realm.objects(ToDoTable.self)
        
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        cellRegistration = UICollectionView.CellRegistration(handler: { cell, indexPath, itemIdentifier in
            
            var content = UIListContentConfiguration.valueCell()
            content.text = itemIdentifier.title
            content.image = itemIdentifier.favorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
            content.secondaryText = "\(itemIdentifier.detail.count)개의 세부 할일"
            cell.contentConfiguration = content
        })
    }
    
    static func layout() -> UICollectionViewLayout {
        
        let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        return layout
        
    }
    
}

extension RealmCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = list[indexPath.item] // 얘의 타입이 제네릭에 들어감
        let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: data)
        
        return cell
    }
    
}
