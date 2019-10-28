//
//  ViewController.swift
//  People
//
//  Created by Тимур Кошевой on 25.10.2019.
//  Copyright © 2019 Тимур Кошевой. All rights reserved.
//

import UIKit

class HumansViewController: RootViewController, HumansPresenterDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortButtonOutlet: UIButton!
    @IBOutlet weak var firstTextFieldOutlet: UITextField!
    @IBOutlet weak var secondTextFieldOutlet: UITextField!
    @IBOutlet weak var selectWithLettersOutlet: UIButton!
    
    //MARK: - Properties
    lazy var presenter = HumansPresenter(with: self)
    private let refreshControl = UIRefreshControl()
    private let alertView = AlertView()
    private let cellIdentifier = "humanCell"
    var humanDataArray = [HumanData]()
    var sortType: SortTypes = SortTypes.sort_off
    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        
        firstTextFieldOutlet.delegate = self
        secondTextFieldOutlet.delegate = self
        
        sortButtonOutlet.imageView?.image = UIImage(named: "sort_off")
        selectWithLettersOutlet.isEnabled = false
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        loadHumans()
        createRefreshControl()
    }
    
    func loadHumans() {
        showSpinner()
        
        var charA: String? = nil
        var charB: String? = nil
        
        if (!firstTextFieldOutlet.text!.isEmpty && !secondTextFieldOutlet.text!.isEmpty) && ((firstTextFieldOutlet.text! != " ") && (secondTextFieldOutlet.text! != " ")) {
            charA = firstTextFieldOutlet.text!
            charB = secondTextFieldOutlet.text!
        }
        
        presenter.fetchFilteredHumans(sortTypeAscending: self.sortType, charA: charA, charB: charB) { (humanDataArray, error) in
            if let unwrDataArray = humanDataArray {
                self.humanDataArray = unwrDataArray
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.removeSpinner()
                }
            } else {
                self.removeSpinner()
                self.alertView.showAlert(view: self, title: "Error", message: error!)
            }
        }
    }
    
    func createRefreshControl() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshHumans(_:)), for: .valueChanged)
    }
    
    @objc private func refreshHumans(_ sender: Any) {
        loadHumans()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - Actions
    @IBAction func sortButtonAction(_ sender: Any) {
        switch sortType {
        case .sort_off:
            sortType = .ascending_true
            sortButtonOutlet.setImage(UIImage(named: SortTypes.ascending_true.rawValue), for: UIControl.State.normal)
            let sortedArray = presenter.sortHumans(sortTypeAscending: sortType, humanDataArray: self.humanDataArray)
            self.humanDataArray = sortedArray
            self.tableView.reloadData()
        case .ascending_true:
            sortType = .ascending_false
            sortButtonOutlet.setImage(UIImage(named: SortTypes.ascending_false.rawValue), for: UIControl.State.normal)
            let sortedArray = presenter.sortHumans(sortTypeAscending: sortType, humanDataArray: self.humanDataArray)
            self.humanDataArray = sortedArray
            self.tableView.reloadData()
        case .ascending_false:
            sortType = .sort_off
            sortButtonOutlet.setImage(UIImage(named: SortTypes.sort_off.rawValue), for: UIControl.State.normal)
            loadHumans()
        }
    }
    
    @IBAction func selectWithLettersAction(_ sender: Any) {
        loadHumans()
    }
    
}

// MARK: - TableView
extension HumansViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return humanDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! HumanTableViewCell
        
        let data = self.humanDataArray[indexPath.row].avatarData
        
        if let data = data {
            DispatchQueue.main.async {
                cell.avatarImageView.image = UIImage(data: data)
            }
        }
        
        let firstName = humanDataArray[indexPath.row].first_name!
        let lastName = humanDataArray[indexPath.row].last_name!
        
        cell.nameLabel.text = lastName + " " + firstName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96.0
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            let id = self.humanDataArray[indexPath.row].id
            self.presenter.deleteHumanFromLocalStorage(id: id!)
            self.loadHumans()
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return swipeActions
    }
    
}

// MARK: - TextField
extension HumansViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 1
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstTextFieldOutlet {
            secondTextFieldOutlet.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (firstTextFieldOutlet.text!.count + secondTextFieldOutlet.text!.count) < 2 {
            selectWithLettersOutlet.isEnabled = false
        } else {
            selectWithLettersOutlet.isEnabled = true
        }
    }
    
}
