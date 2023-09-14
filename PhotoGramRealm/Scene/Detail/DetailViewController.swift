//
//  DetailViewController.swift
//  PhotoGramRealm
//
//  Created by 마르 on 2023/09/05.
//

import UIKit
import RealmSwift

class DetailViewController: BaseViewController {
    
    var data: DiaryTable?
    
    let realm = try! Realm()
    
    lazy var titleTextField: WriteTextField = {
        let view = WriteTextField()
        view.placeholder = "제목을 입력해주세요"
        view.text = self.data?.diaryTitle
        view.textColor = .white
        return view
    }()
    
    let contentTextField: WriteTextField = {
        let view = WriteTextField()
        view.placeholder = "제목을 입력해주세요"
        //view.text = self.data?.diaryContents
        view.textColor = .white
        return view
    }()
    
    override func configure() {
        super.configure()
        view.addSubview(titleTextField)
        view.addSubview(contentTextField)
        
        
        guard let data = data else { return }
        //titleTextField.text = data.diaryTitle
        contentTextField.text = data.contents
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "수정", style: .plain, target: self, action: #selector(editButtonClicked))
    }
    
    let repository = DiaryTableRepository()
    
    @objc func editButtonClicked() {
        
        guard let data = data else { return }
        
        repository.updateItem(id: data._id, title: titleTextField.text!, contents: contentTextField.text!)
        navigationController?.popViewController(animated: true)
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        titleTextField.snp.makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalTo(50)
            make.center.equalTo(view)
        }
        
        contentTextField.snp.makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(60)
        }
    }
    
}
