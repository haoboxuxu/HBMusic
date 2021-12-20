//
//  CreatePlayListView.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/12/16.
//

import UIKit

struct CreatePlayListVM {
    let name: String
}

protocol CreatePlayListVCDelegate: AnyObject {
    func createPlayListVCDelegateDidTapDone(_ createPlayListVC: CreatePlayListVC, _ createPlayListVM: CreatePlayListVM)
}

class CreatePlayListVC: UIViewController {
    
    weak var delegate: CreatePlayListVCDelegate?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "music.note.list", withConfiguration: UIImage.SymbolConfiguration(paletteColors: [.systemPink, .red]))
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 30)
        textView.text = "Name your playlist"
        textView.textColor = .secondaryLabel
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true
        view.addSubview(imageView)
        view.addSubview(textView)
        textView.delegate = self
        view.backgroundColor = .systemBackground
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        rightBarButtonItem.tintColor = .systemPink
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let imageSize = view.width / 1.5
        imageView.frame = CGRect(x: (view.width-imageSize)/2, y: 50, width: imageSize, height: imageSize)
        textView.frame = CGRect(x: 50, y: imageView.bottom+100, width: view.width-100, height: 200)
    }
    
    @objc func didTapDone() {
        delegate?.createPlayListVCDelegateDidTapDone(self, CreatePlayListVM(name: textView.text))
    }
}

extension CreatePlayListVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .secondaryLabel {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Name your playlist"
            textView.textColor = .systemBackground
        }
    }
}
