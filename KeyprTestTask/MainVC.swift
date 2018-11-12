//
//  ViewController.swift
//  KeyprTestTask
//
//  Created by Borys Zinkovych on 11/8/18.
//  Copyright © 2018 bzink. All rights reserved.
//

import UIKit

protocol MainVCProtocol: NSObjectProtocol {
    func startTableUpdate()
    func endTableUpdate()
    func reloadTable(pathArray:[IndexPath])
    func adjustInternet(show: Bool, message: String)
    func startWeatherRefreshing()
    func endWeatherRefreshing()
    func showError(message: String)
}

class MainVC: UIViewController {
    
    private static let keyMainVCId = "MainVC"
    private let keyWeatherCellId = "keyWeatherCellId"
    var presenter: MainVCPresenterProtocol?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topDisclaimerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var noInternetLabel: UILabel!
    
    public static func create() -> MainVC {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: keyMainVCId) as! MainVC
        return mainVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.accessibilityIdentifier = UIAccessibilityIdentifiers.keyMainVCId
        self.automaticallyAdjustsScrollViewInsets = false
        self.updateNavigationBarAppearance()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self,
                                            action: #selector(onRefresh(_:)),
                                            for: .valueChanged)
        self.presenter?.onViewCreate()
    }
    
    @objc private func onRefresh(_: NSObject) {
        self.presenter?.onRefresh()
    }
    
    private func updateNavigationBarAppearance() {
        let leftTitle = "Current weather".localized()
        self.navigationItem.setLeftTitle(title: leftTitle, textColor: .white)
        self.navigationController?.navigationBar.barTintColor = UIColor(rgb:0xF0423F)
        self.navigationController?.navigationBar.barStyle = .black
        UIApplication.shared.statusBarView?.backgroundColor = UIColor(rgb:0x9B32AC)
        createRefreshButton()
    }
    
    private func createRefreshButton() {
        let buttonSize:CGFloat = 24.0;
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(origin: .zero, size: CGSize(width: buttonSize, height: buttonSize))
        menuBtn.setImage(UIImage(named:"refresh"), for: .normal)
        menuBtn.addTarget(self, action: #selector(onRefresh(_:)), for: UIControl.Event.touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: buttonSize)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: buttonSize)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = menuBarItem
    }
}

extension MainVC: MainVCProtocol {
    
    func startTableUpdate() {
        tableView.beginUpdates()
    }
    
    func endTableUpdate() {
        self.tableView.endUpdates()
    }
    
    func reloadTable(pathArray:[IndexPath]) {
        self.tableView.reloadRows(at: pathArray, with: .none)
    }
    
    func adjustInternet(show: Bool, message: String) {
        let currentValue = self.topDisclaimerHeightConstraint.constant
        var newValue = currentValue
        if show {
            newValue = 0
        } else {
            self.noInternetLabel.text = message
            newValue = 35
        }
        if newValue != currentValue {
            self.topDisclaimerHeightConstraint.constant = newValue
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func startWeatherRefreshing() {
        self.navigationItem.rightBarButtonItem?.customView?.rotateInfinity(direction: .Left)
    }
    
    func endWeatherRefreshing() {
        self.tableView.refreshControl?.endRefreshing()
        self.navigationItem.rightBarButtonItem?.customView?.layer.removeAllAnimations()
    }
    
    func showError(message: String) {
        let alertController = UIAlertController(title: "Error!".localized(),
                                                message: message.localized(),
                                                preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "Ok".localized(), style: .default) { (action:UIAlertAction) in
            print("Error alert was dismissed");
        }
        
        alertController.addAction(action1)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension MainVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter!.getCitiesCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: keyWeatherCellId, for: indexPath) as! CityWeatherCell
        if let model = self.presenter?.getCityModel(indexPath: indexPath) {
            cell.setCity(city: model)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

