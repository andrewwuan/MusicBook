//
//  WordTableViewController.swift
//  MusicToolbox
//
//  Created by An Wu on 4/8/16.
//  Copyright © 2016 An Wu. All rights reserved.
//

import UIKit
import CoreData

class WordTableViewController: UITableViewController, UISearchBarDelegate {
    // MARK: Properties
    @IBOutlet weak var wordSearchBar: UISearchBar!
    
    var allWords: [NSManagedObject]!
    var filteredWords: [NSManagedObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        wordSearchBar.delegate = self
        
        loadWords()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Search bar delegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredWords = allWords
        } else {
            filteredWords = allWords.filter({ (word: NSManagedObject) -> Bool in
                (word.valueForKey("spelling") as? String)!.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            })
        }
        tableView.reloadData()
    }
    
    // MARK: Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredWords.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "WordTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! WordTableViewCell

        // Fetches the appropriate meal for the data source layout.
        let word = filteredWords[indexPath.row]

        cell.spellingLabel.text = word.valueForKey("spelling") as? String
        cell.explanationLabel.text = word.valueForKey("explanation") as? String
        
        return cell
    }
    
    func loadWords() {

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Word")

        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            allWords = results as! [NSManagedObject]
            filteredWords = allWords
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}
