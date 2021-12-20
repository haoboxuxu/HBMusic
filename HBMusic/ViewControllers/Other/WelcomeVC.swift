//
//  WelcomeVC.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/17.
//

import UIKit

class WelcomeVC: UIViewController {
    
    private let signInBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .white
        btn.setTitle("Sign In with Spotify", for: .normal)
        btn.titleLabel!.font = .systemFont(ofSize: 20)
        btn.layer.cornerRadius = 15
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "HB Music"
        view.backgroundColor = .systemPink
        view.addSubview(signInBtn)
        signInBtn.addTarget(self, action: #selector(didTappedSignin), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        signInBtn.frame = CGRect(
            x: 20,
            y: view.height-80-view.safeAreaInsets.bottom,
            width: view.width-40,
            height: 50
        )
    }
    
    @objc func didTappedSignin() {
        let authVC = AuthVC()
        authVC.navigationItem.largeTitleDisplayMode = .never
        authVC.completionHandler = { [weak self] success in
            DispatchQueue.main.async {
                self?.handleSignInSuccess(success: success)
            }
        }
        navigationController?.pushViewController(authVC, animated: true)
    }
    
    func handleSignInSuccess(success: Bool) {
        guard success else {
            let alert = UIAlertController(title: "Oh no", message: "Can't successfully sign in", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancle", style: .cancel))
            present(alert, animated: true)
            return
        }
        let tabBarVC = TabBarVC()
        tabBarVC.modalPresentationStyle = .fullScreen
        present(tabBarVC, animated: true)
    }
}
