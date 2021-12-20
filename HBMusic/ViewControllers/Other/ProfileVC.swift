//
//  ProfileVC.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/17.
//

import UIKit
import HBWebImage

class ProfileVC: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isHidden = true
        return tableView
    }()
    
    private var models: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchProfile()
        view.backgroundColor = .systemBackground
        title =  "Profile"
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func fetchProfile() {
        APICaller.shared.getCurrentUserProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.updateUI(with: model)
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    self?.fialedToGetProfile()
                }
            }
        }
    }
    
    private func updateUI(with model: UserProfile) {
        tableView.isHidden = false
        models.append("Name: \(model.display_name)")
        models.append("Email: \(model.email)")
        models.append("Country: \(model.country)")
        models.append("Product: \(model.product)")
        models.append("ID: \(model.id)")
        createTableHeader(with: model.images.first?.url)
        tableView.reloadData()
    }
    
    private func createTableHeader(with str: String?) {
        guard let str = str, let url = URL(string: str) else {
            return
        }
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 200))
        let imageSize = 150
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        header.addSubview(imageView)
        imageView.center = header.center
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = CGFloat(imageSize / 2)
        imageView.layer.borderColor = UIColor.systemPink.cgColor
        imageView.layer.borderWidth = 3
        imageView.hbSetImage(with: url, placeholderImage: nil, completion: nil)
        tableView.tableHeaderView = header
    }
    
    private func fialedToGetProfile() {
        let label = UILabel(frame: .zero)
        label.text = "Fialed to get profile"
        label.sizeToFit()
        label.textColor = .secondaryLabel
        view.addSubview(label)
        label.center = view.center
    }
}

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
}
