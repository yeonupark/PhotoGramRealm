//
//  ToDoViewController.swift
//  PhotoGramRealm
//
//  Created by 마르 on 2023/09/08.
//

import UIKit
import RealmSwift
import SnapKit

class ToDoViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    let realm = try! Realm()
    
    let tableView = UITableView()
    
    var list: Results<DetailTable>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let data = ToDoTable(title: "영화보기", favorite: false)
//
//        let memo = Memo()
//        memo.content = "주말에 팝콘 먹으면서 영화 보기"
//        memo.date = Date()
//
//        data.memo = memo
//
//        try! realm.write {
//            realm.add(data)
//        }
//        print(realm.objects(ToDoTable.self))
        
        
//        let data = ToDoTable(title: "장보기", favorite: true)
//        let detail1 = DetailTable(detail: "양파", deadline: Date())
//        let detail2 = DetailTable(detail: "감자", deadline: Date())
//        let detail3 = DetailTable(detail: "쪽파", deadline: Date())
//
//        data.detail.append(detail1)
//        data.detail.append(detail2)
//        data.detail.append(detail3)
//
//        try! realm.write {
//            realm.add(data)
//        }
//        print(realm.objects(DetailTable.self)) // DetailTable에만 따로 접근도 가능!
        
        
        print(realm.configuration.fileURL)
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 40
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "todoCell")
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        list = realm.objects(DetailTable.self)
    }
    
//    func createDetail() {
//
//        print(realm.configuration.fileURL)
//        //createTodo()
//
//        let main = realm.objects(ToDoTable.self).where { // 여러 램 파일 중 ToDoTable 찾기
//            $0.title == "장보기"
//        }.first!
//
//        for i in 1...10 {
//            let detailTodo = DetailTable(detail: "장보기 세부 할일 \(i)", deadline: Date() )
//
//            try! realm.write {
//                //realm.add(detailTodo)
//                main.detail.append(detailTodo)
//            }
//        }
//    }
//
//    func createTodo() {
//        for i in ["장보기", "영화보기", "리캡하기", "좋아요구현하기"] {
//
//            let data = ToDoTable(title: i, favorite: false)
//
//            try! realm.write{
//                realm.add(data)
//            }
//        }
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = list[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell")!
        //cell.textLabel?.text = "\(list[indexPath.row].title): \(list[indexPath.row].detail.count)개 \(list[indexPath.row].memo?.content ?? "")"
        cell.textLabel?.text = "\(data.detail) in \(data.mainTodo.first?.title ?? "")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = list[indexPath.row]
        
        try! realm.write {
            //realm.delete(data.detail) // detail을 먼저 지워줘야함
            realm.delete(data)
        }
        
        tableView.reloadData()
    }
}
