//
//  SettingVC.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/17.
//

import UIKit

class SettingVC: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var sections: [Section] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Setting"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        setUpModels()
    }
    
    private func setUpModels() {
        sections.append(Section(title: "Profile", option: [Option(title: "Your Profile", handler: { [weak self] in
            DispatchQueue.main.async {
                self?.viewYourProfile()
            }
        })]))
        
        sections.append(Section(title: "Account", option: [Option(title: "Sign Out", handler: { [weak self] in
            DispatchQueue.main.async {
                self?.signOut()
            }
        })]))
    }
}

extension SettingVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].option.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].option[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = sections[indexPath.section].option[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        model.handler()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let model = sections[section]
        return model.title
    }
}

// Cell Handler
extension SettingVC {
    private func viewYourProfile() {
        let profileVC = ProfileVC()
        profileVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    private func signOut() {
        
        let alert = UIAlertController(title: "Sign Out", message: "Are u sure? :(", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Never mind", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            AuthManger.shared.signOut { [weak self] success in
                if success {
                    DispatchQueue.main.async {
                        let navVC = UINavigationController(rootViewController: WelcomeVC())
                        navVC.navigationBar.prefersLargeTitles = true
                        navVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
                        navVC.modalPresentationStyle = .fullScreen
                        self?.present(navVC, animated: true, completion: {
                            self?.navigationController?.popToRootViewController(animated: false)
                        })
                    }
                } else {
                    HapticsManger.shared.vibrate(for: .error)
                }
            }
        }))
        
        present(alert, animated: true)
    }
}
