//
//  CountryViewController.swift
//  ChatApp
//
//  Created by Владимир on 31.07.2021.
//  Copyright © 2021 Владимир. All rights reserved.
//

import UIKit

class CountryViewController: UITableViewController, UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            filtredCountry = country.countryName
            return
        }else{
            var newFilterCountry = [[String]]()
            for countr in country.countryName{
                let groupCountry = searchText.isEmpty ? countr : countr.filter { (item: String) -> Bool in
                    return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
                    }
                newFilterCountry.append(groupCountry)
            }
            filtredCountry = newFilterCountry
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filtredCountry = country.countryName
        tableView.reloadData()
    }

    var delegateCountry: SharedCountry?
    var delegateCode: SharedNumCode?
    let country: CountriesInfo = CountriesInfo()
    
    let cellID = "cellId"
    let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "Y", "Z"]
    
    let searchController = UISearchController()
    var filtredCountry = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        filtredCountry = country.countryName
        navigationItem.title = "Counries"
        navigationController?.navigationBar.barTintColor = .systemBackground
        tableView.register(CustomViewCellCountry.self, forCellReuseIdentifier: cellID)
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search your Country"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegateCountry!.protocolCountry(country: country.contryIsoCodes[indexPath.section][indexPath.row])
        delegateCode!.protocolNumberCode(nummber: country.countryCode[indexPath.section][indexPath.row])
        navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = alphabet[section]
        label.font = UIFont.init(name: "HelveticaNeue-Bold", size: 20)
        label.backgroundColor = UIColor.lightGray
        return label
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height: CGFloat = 24.0
        if searchController.isActive{
            height = 0.0
        }else{height = 24.0}
        return height
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return filtredCountry.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtredCountry[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? CustomViewCellCountry else {fatalError("Fatal error")}
        cell.countryName.text = self.filtredCountry[indexPath.section][indexPath.row]
        cell.codeNum.text = "+\(self.country.countryCode[indexPath.section][indexPath.row])"
        return cell
    }
}
//self.dismiss(animated: true, completion: nil) - dismiss in popover
