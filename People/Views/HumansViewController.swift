//
//  ViewController.swift
//  People
//
//  Created by Тимур Кошевой on 25.10.2019.
//  Copyright © 2019 Тимур Кошевой. All rights reserved.
//

import UIKit

class HumansViewController: RootViewController, PresenterDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortButtonOutlet: UIButton!
    @IBOutlet weak var firstTextFieldOutlet: UITextField!
    @IBOutlet weak var secondTextFieldOutlet: UITextField!
    
    //MARK: - Properties
    lazy var presenter = Presenter(with: self)
    private let refreshControl = UIRefreshControl()
    private let alertView = AlertView()
    private let cellIdentifier = "humanCell"
    var humanDataArray = [HumanData]()
    var sortType: Int?
    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false

        firstTextFieldOutlet.delegate = self
        secondTextFieldOutlet.delegate = self
        
        sortButtonOutlet.imageView?.image = UIImage(named: "sort")
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)

        loadHumans()
        createRefreshControl()
    }
    
    func loadHumans() {
        showSpinner()
        presenter.fetchHumans { (humans, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.alertView.showAlert(view: self, title: "Error", message: error)
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.removeSpinner()
                }
            } else {
                self.humanDataArray = self.presenter.fetchSortedHumans(sortTypeAscending: self.sortType, humanDataArray: humans!.humanDataArray)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.removeSpinner()
                }
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
    
    @IBAction func sortButtonAction(_ sender: Any) {
        if sortType != nil {
        } else {
            self.sortType = 1
        }
        
        switch sortType {
        case 0:
            sortButtonOutlet.setImage(UIImage(named: "sort"), for: UIControl.State.normal)
            sortType = 1
        case 1:
            sortButtonOutlet.setImage(UIImage(named: "ascending_true"), for: UIControl.State.normal)
            self.humanDataArray = presenter.fetchSortedHumans(sortTypeAscending: sortType, humanDataArray: self.humanDataArray)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
            sortType = 2
        case 2:
            sortButtonOutlet.setImage(UIImage(named: "ascending_false"), for: UIControl.State.normal)
            self.humanDataArray = presenter.fetchSortedHumans(sortTypeAscending: sortType, humanDataArray: self.humanDataArray)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
            sortType = 0
        default:
            sortButtonOutlet.setImage(UIImage(named: "sort"), for: UIControl.State.normal)
            sortType = 0
        }
    }
    
    
    @IBAction func selectWithLettersAction(_ sender: Any) {
        showSpinner()
        var str: String? = nil

        if (!firstTextFieldOutlet.text!.isEmpty && !secondTextFieldOutlet.text!.isEmpty) && ((firstTextFieldOutlet.text! != " ") && (secondTextFieldOutlet.text! != " ")) {
            str = firstTextFieldOutlet.text! + secondTextFieldOutlet.text!
        }
        
        presenter.fetchFilteredHumans(sortTypeAscending: nil, str: str) { (humanDataArray, error) in
            if let humanDataArray = humanDataArray {
                self.humanDataArray = humanDataArray
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.removeSpinner()
                }
            } else {
                self.removeSpinner()
                print("ERROR OCCUR WHILE SORTING")
            }
        }
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
}
