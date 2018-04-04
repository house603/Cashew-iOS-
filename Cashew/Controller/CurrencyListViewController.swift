//
//  CurrencyListViewController.swift
//  Cashew
//
//  Created by Robo Atenaga on 3/7/18.
//  Copyright © 2018 Robo Atenaga. All rights reserved.
//

import UIKit
import SDWebImage

class CurrencyListViewController: UIViewController {

    @IBOutlet weak var currencyTable: UITableView!
    
    var activityIndicator: UIActivityIndicatorView!
    //let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    
    var previousVC: MainScreenViewController! = nil
    var senderTag = -1
    let searchController = UISearchController(searchResultsController: nil)
    let currencyData = CurrencyData()
    var currencies = [Currency]()
    var filteredCurrencies = [Currency]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting up the activity indicator
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        currencyTable.backgroundView = activityIndicator
        
        let currencyCellNib = UINib(nibName: "CurrencyTableViewCell", bundle: nil)
        currencyTable.register(currencyCellNib, forCellReuseIdentifier: "currencyCell")
        
        currencyData.loadCurrencies()
        currencyData.didGetCurrencies = didGetCurrencies
        
        setUpSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // if currencies is empty, start activity indicator
        if currencies.count <= 0 {
            activityIndicator.startAnimating()
        }
    }
        
    func didGetCurrencies(_ currencies: [Currency]){
        self.currencies = currencies
        // if currencies is not empty, stop activity indicator
        if currencies.count > 0 {
            activityIndicator.stopAnimating()
        }
        currencyTable.reloadData()
    }
    
    func setUpSearchController(){
        // Setup searchController's parameters
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.returnKeyType = .done
        searchController.searchBar.enablesReturnKeyAutomatically = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.title = "Choose currency"
        definesPresentationContext = true
    }
    
    func searchBarIsEmpty () -> Bool {
        return (searchController.searchBar.text?.isEmpty)!
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredCurrencies = (currencies.filter { (currency : Currency) -> Bool in
            return (currency.currencyName.lowercased().contains(searchText.lowercased()) || currency.iso.lowercased().contains(searchText.lowercased()))
        })
        currencyTable.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

extension CurrencyListViewController: UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering(){
            return filteredCurrencies.count
        }
        return currencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath) as! CurrencyTableViewCell
        let currency : Currency
        if isFiltering() {
            currency = filteredCurrencies[indexPath.row]
        }
        else{
            currency = currencies[indexPath.row]
        }
        cell.imgFlag?.sd_setImage(with: URL(string: currency.flag), completed: nil)
        cell.lblTitle?.text = currency.currencyName
        cell.lblISO?.text = currency.iso
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currency : Currency
        if isFiltering() {
            currency = filteredCurrencies[indexPath.row]
        }
        else{
            currency = currencies[indexPath.row]
        }
        if senderTag == 0 {
            previousVC.topCurrency = currency
            navigationController?.popViewController(animated: true)
        }
        else if senderTag == 1{
            previousVC.bottomCurrency = currency
            navigationController?.popViewController(animated: true)
        }
    }
}
