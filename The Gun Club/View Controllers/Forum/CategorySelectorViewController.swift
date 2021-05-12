//
//  CategorySelectorViewController.swift
//  The Gun Club
//
//  Created by Chuck Zumbaugh on 8/5/20.
//  Copyright © 2020 Chuck Zumbaugh. All rights reserved.
//

import UIKit

class CategorySelectorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var categories: [String] = []
    var categoryDescriptions: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categories = infoForKeyArray("Categories")!
        categoryDescriptions = infoForKeyArray("Category Descriptions")!
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "category")
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: NavigationBarLogoView())
    }
    
    func infoForKeyArray (_ key: String) -> Array<String>? {
        return (Bundle.main.infoDictionary?[key] as? Array)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "category", for: indexPath) as! CategoryTableViewCell
        let category = categories[indexPath.row]
        cell.titleLabel.text = category
        cell.subtitleLabel.text = categoryDescriptions[indexPath.row]
        cell.categoryImageView.image = UIImage(named: category.lowercased())
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "categorySegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categorySegue" {
            let indexPath = tableView.indexPathForSelectedRow!
            let category = categories[indexPath.row]
            let destinationViewController = segue.destination as! ForumViewController
            destinationViewController.selectedCategory = category
        }
    }

}
