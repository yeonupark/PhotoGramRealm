//
//  DiaryTableRepository.swift
//  PhotoGramRealm
//
//  Created by 마르 on 2023/09/06.
//

import UIKit
import RealmSwift

protocol DiaryTableRepositoryType: AnyObject {
    func fetch() -> Results<DiaryTable>
    func fetchFilter() -> Results<DiaryTable>
    func createItem(_ item: DiaryTable)
}

class DiaryTableRepository: DiaryTableRepositoryType {
    
    private let realm = try! Realm()
    
    func checkSchemaVersion() {
        do {
            let version = try schemaVersionAtURL(realm.configuration.fileURL!)
            print("Schema Version: \(version)")
        } catch {
            print(error)
        }
    }
    
    func fetch() -> Results<DiaryTable> {
        
        // Realm Read (램에서 데이터 가지고오기)
        let data = realm.objects(DiaryTable.self).sorted(byKeyPath: "diaryDate", ascending: true)
        return data
    }
    
    func fetchFilter() -> Results<DiaryTable> {
        
        let result = realm.objects(DiaryTable.self).where {
             /*1. 대소문자 구분 없음 - .caseInsensitive
             $0.diaryTitle.contains("테스트", options: .caseInsensitive)
             2. Bool
            $0.diaryLike == true*/
            
            // 3. 사진이 있는 데이터만 불러오기 (diaryPhoto의 nil 여부 판단)
            $0.diaryPhoto != nil
        }

        return result
    }
    
    func createItem(_ item: DiaryTable) {
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print(error)
        }
    }
    
    func updateItem(id: ObjectId, title: String, contents: String) {
        do {
            try realm.write {
                realm.create(DiaryTable.self, value: ["_id": id, "diaryTitle": title, "diaryContents": contents], update: .modified)
            }
        } catch {
            print("????")
        }
    }
    
}
