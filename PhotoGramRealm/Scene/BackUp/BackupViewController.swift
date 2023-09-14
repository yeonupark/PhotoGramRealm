//
//  BackupViewController.swift
//  PhotoGramRealm
//
//  Created by 마르 on 2023/09/07.
//

import UIKit
import Zip

class BackupViewController: BaseViewController {
    
    let backupButton = {
        let view = UIButton()
        view.backgroundColor = .systemGreen
        
        return view
    }()
    
    let restoreButton = {
        let view = UIButton()
        view.backgroundColor = .orange
        
        return view
    }()
    
    let tableView = {
        let view = UITableView()
        view.rowHeight = 50
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func configure() {
        super.configure()
        
        view.addSubview(tableView)
        view.addSubview(backupButton)
        view.addSubview(restoreButton)
        
        backupButton.addTarget(self, action: #selector(backupButtonClicked), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(restoreButtonClicked), for: .touchUpInside)
        
    }
    
    @objc func backupButtonClicked() {
        
        // 1. 백업하고자 하는 파일들의 경로 배열 생성
        var urlPaths = [URL]()
        
        // 2. 도큐먼트 위치 확인
        guard let path = documentDirectoryPath() else {
            print("도큐먼트 위치에 오류가 있습니다.")
            return
        }
        
        // 3. 백업하고자 하는 파일 경로 (ex ~~~/~~/~~~/Document/deafult.realm
        let realmFile = path.appendingPathComponent("default.realm")
        
        // 4. 3번 경로가 유효한지 확인
        guard FileManager.default.fileExists(atPath: realmFile.path) else {
            print("백업할 파일이 없습니다")
            return
        }
        
        // 5. 압축하고자 하는 파일을 배열에 추가
        urlPaths.append(realmFile)
        
        // 6. 배열 압축
        do {
            let zipFilePath = try Zip.quickZipFiles(urlPaths, fileName: "MarArchive")
            print("location: \(zipFilePath)")
        } catch {
            print("압축 실패함")
        }
        
    }
    
    @objc func restoreButtonClicked() {
        
        // 파일 앱을 통한 복구 진행
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.archive], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false // 하나만 가져오도록
        present(documentPicker, animated: true)
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        tableView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(100)
        }
        
        backupButton.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.top.leading.equalTo(view.safeAreaLayoutGuide)
        }
        
        restoreButton.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.trailing.top.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension BackupViewController: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print(#function)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let selectedFileURL = urls.first else { // 파일앱 내 URL 주소
            print("선택한 파일에 오류가 있어요")
            return
        }
        guard let path = documentDirectoryPath() else {
            print("도큐먼트 위치에 오류가 있어요")
            return
        }
        
        // 도큐먼트 폴더 내 저장할 경로 설정
        let sandboxFileURL = path.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        // 경로에 복구할 파일(zip)이 이미 있는지 확인
        if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
            let fileURL = path.appendingPathComponent("MarArchive.zip") // 파일명 설정 어떻게 해주느냐에 따라
            // 압축해제
            do {
                try Zip.unzipFile(fileURL, destination: path, overwrite: true, password: nil, progress: { progress in
                    print("progress: \(progress)")
                }, fileOutputHandler: { unzippedFile in
                    print("압축 해제 완료: \(unzippedFile)")
                    exit(0)
                })
            } catch {
                print("압축 해제 실패")
            }
            
        } else {
        // 경로에 복구할 파일이 없을 때에 대한 대응
            do {
                try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL) // 파일앱 내 url -> 도큐먼트 폴더 내 url로 복사.
                
                let fileURL = path.appendingPathComponent("MarArchive.zip")
                
                try Zip.unzipFile(fileURL, destination: path, overwrite: true, password: nil, progress: { progress in
                    print("progress: \(progress)")
                }, fileOutputHandler: { unzippedFile in
                    print("압축 해제 완료: \(unzippedFile)")
                    exit(0)
                })
            } catch {
                print("압축 해제 실패")
            }
            
        }
        
    }
}

extension BackupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func fetchZipList() -> [String] {
        var list: [String] = []
        
        do {
            guard let path = documentDirectoryPath() else { return list } // 경로 가져오기
            let docs = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil) // 해당 폴더 내 모든 파일들
            let zip = docs.filter { $0.pathExtension == "zip" } // 그 파일들 중 확장자가 zip인 애들
            for i in zip {
                list.append(i.lastPathComponent)
            }
        } catch {
            print("ERROR")
        }
        return list
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchZipList().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = fetchZipList()[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAcvitityViewController(fileName: fetchZipList()[indexPath.row])
    }
    
    func showAcvitityViewController(fileName: String) {
        
        guard let path = documentDirectoryPath() else {
            print("도큐먼트 위치에 오류가 있어요")
            return
        }
        
        let backupFileURL = path.appendingPathComponent(fileName)
        
        let vc = UIActivityViewController(activityItems: [backupFileURL], applicationActivities: [])
        present(vc, animated: true)
    }
}
