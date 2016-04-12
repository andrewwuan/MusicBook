//
//  WordTableViewController.swift
//  MusicToolbox
//
//  Created by An Wu on 4/8/16.
//  Copyright © 2016 An Wu. All rights reserved.
//

import UIKit
import CoreData

class WordTableViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    // MARK: Properties
    @IBOutlet weak var wordSearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    var filteredWords: [Word]!
    var globalSearchText: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        wordSearchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        globalSearchText = ""
        loadWords()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue,
                                  sender: AnyObject?) {
        
        if segue.identifier == "ShowWordDetails" {
            let detailViewController = segue.destinationViewController
                as! WordDetailViewController
            
            let myIndexPath = self.tableView.indexPathForSelectedRow!
            detailViewController.word = filteredWords[myIndexPath.row]
        }
    }
    
    // MARK: Search bar delegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(loadWords), object: nil)
        globalSearchText = searchText
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(loadWords), userInfo: nil, repeats: false)
    }

    // MARK: Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredWords.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "WordTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)

        return cell
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Fetches the appropriate meal for the data source layout.
        let word = filteredWords[indexPath.row]

        let wordCell = cell as! WordTableViewCell

        wordCell.spellingLabel.text = word.spelling

        let explanation = word.explanations!.map({ (explanationObj) -> String in
            let explanation = explanationObj as! WordExplanation
            return explanation.decodedStr!
        })

        wordCell.explanationLabel.text = explanation.joinWithSeparator("\n")
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        wordSearchBar.resignFirstResponder()
    }
    
    func loadWords() {

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Word")
        if (!globalSearchText.isEmpty) {
            fetchRequest.predicate = NSPredicate(format: "spelling CONTAINS %@", globalSearchText)
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "spelling", ascending: true)]

        do {
            filteredWords = try managedContext.executeFetchRequest(fetchRequest) as! [Word]
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}
