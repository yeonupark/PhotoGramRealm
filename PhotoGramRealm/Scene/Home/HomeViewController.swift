//
//  HomeViewController.swift
//  PhotoGramRealm
//
//  Created by jack on 2023/09/03.
//

import UIKit
import SnapKit
import RealmSwift

class HomeViewController: BaseViewController {
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.rowHeight = 100
        view.delegate = self
        view.dataSource = self
        view.register(PhotoListTableViewCell.self, forCellReuseIdentifier: PhotoListTableViewCell.reuseIdentifier)
        return view
    }()
    
    var tasks: Results<DiaryTable>!
    
    let repository = DiaryTableRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Realm Read (램에서 데이터 가지고오기)
        tasks = repository.fetch()
        
        // migration: 운영 상황이 바뀌는 경우. 새로운 환경으로 옮겨가는 작업
        repository.checkSchemaVersion()
        
        print(tasks)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func configure() {
        view.addSubview(tableView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(plusButtonClicked))
        
        let sortButton = UIBarButtonItem(title: "정렬", style: .plain, target: self, action: #selector(sortButtonClicked))
        let filterButton = UIBarButtonItem(title: "필터", style: .plain, target: self, action: #selector(filterButtonClicked))
        let backupButton = UIBarButtonItem(title: "백업", style: .plain, target: self, action: #selector(backupButtonClicked))
        navigationItem.leftBarButtonItems = [sortButton, filterButton, backupButton]
    }
    
    override func setConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    @objc func plusButtonClicked() {
        navigationController?.pushViewController(AddViewController(), animated: true)
    }
    
    @objc func backupButtonClicked() {
        navigationController?.pushViewController(BackupViewController(), animated: true)
    }
    
    
    @objc func sortButtonClicked() {
        
    }
    
    @objc func filterButtonClicked() {
 
        tasks = repository.fetchFilter()
        tableView.reloadData()
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoListTableViewCell.reuseIdentifier) as? PhotoListTableViewCell else { return UITableViewCell() }
        
        let data = tasks[indexPath.row]
        cell.titleLabel.text = data.diaryTitle
        cell.contentLabel.text = data.contents
        cell.dateLabel.text = "\(data.diaryDate)"
        cell.diaryImageView.image = loadImageFromDocument(fileName: "mar_\(data._id).jpg")
        
        // 1. 셀에서 서버 통신이 이뤄지는 경우 -> 용량이 크다면 로드가 오래 걸릴 수 있음
        // 2. 이미지를 미리 (vdl 등) UIImage 형식으로 반환하고, 셀에서 UIImage를 바로 보여주자! -> 재사용 매커니즘의 장점을 활용하지 못함. UIImage 배열 구성 자체가 오래걸릴수도
//        guard let photoUrlString = data.diaryPhotoURL else { return cell }
//        guard let url = URL(string: photoUrlString) else { return cell }
//        DispatchQueue.global().async {
//            if let data = try? Data(contentsOf: url) {
//
//                DispatchQueue.main.async {
//                    cell.diaryImageView.image = UIImage(data: data)
//                }
//            }
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Realm Delete
//        let data = tasks[indexPath.row]
//
//        removeImageFromDocumet(fileName: "mar_\(data._id).jpg") // 폴더에서 먼저 삭제
//
//        try! realm.write {
//            realm.delete(data)
//        }
//
//        tableView.reloadData()
        
        // 셀 선택했을 때 다음 화면으로 넘어가도록
        let vc = DetailViewController()
        vc.data = tasks[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let like = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
            print("좋아요 선택됨")
        }
        like.backgroundColor = .orange
        like.image = tasks[indexPath.row].diaryLike ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        
        let sample = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
            print("테스트 선택됨")
        }
        sample.backgroundColor = .systemGreen
        sample.image = UIImage(systemName: "drop.fill")
        
        return UISwipeActionsConfiguration(actions: [like, sample])
    }
}
