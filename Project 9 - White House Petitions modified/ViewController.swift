//
//  ViewController.swift
//  Project 7 - White House Petitions
//
//  Created by Shana Pougatsch on 9/9/20.
//  Copyright © 2020 Shana Pougatsch. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
//MARK:- Properties
    
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()

//MARK:- View Management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filterButton = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterPetitions))
        let resetButton = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetPetitions))
            
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(displayCredits))
        navigationItem.leftBarButtonItems = [filterButton, resetButton]
        
        performSelector(inBackground: #selector(fetchJSON), with: nil)
        
    }
        
// MARK:- Fetching JSON
        
    @objc func fetchJSON() {
        /*"https://api.whitehouse.gov/v1/petitions.json?limit=100"
        "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&Limit=100"*/
        
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
       
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    self?.parse(json: data)
                    return
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.showError()
            }
        }
    }
   
    
//MARK:- Methods
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
    
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            filteredPetitions = petitions
            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        } else {
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
    }
    
    @objc func showError() {
        let ac = UIAlertController(title: "Loading Error", message: "There was an error loading the data", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Exit", style: .default))
        present(ac, animated: true)
    }
        
    @objc func filterPetitions() {
        let ac = UIAlertController(title: nil, message: "What can we help you look for?", preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Filter", style: .default) {
            [weak self, weak ac] _ in
            guard let filteredWords = ac?.textFields?[0].text else { return }
            
            self?.performSelector(inBackground: #selector(self?.showPetitions(for:)), with: filteredWords)
            self?.tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    @objc func showPetitions(for filter: String) {
        filteredPetitions = filteredPetitions.filter { $0.title.lowercased().range(of: filter.lowercased()) != nil }
    }
    
    @objc func resetPetitions(action: UIAlertAction) {
        filteredPetitions = petitions
        tableView.reloadData()
    }
    
    @objc func displayCredits() {
        let ac = UIAlertController(title: nil, message: "The data being displayed on these pages are from \n'We The People API of the White House'", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Thank you", style: .default))
        present(ac, animated: true)
    }
    
//MARK:- Table Views
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPetitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = filteredPetitions[indexPath.row]
        
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
        
        }
    }




