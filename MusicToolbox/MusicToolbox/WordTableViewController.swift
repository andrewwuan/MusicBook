//
//  WordTableViewController.swift
//  MusicToolbox
//
//  Created by An Wu on 4/8/16.
//  Copyright © 2016 An Wu. All rights reserved.
//

import UIKit

class WordTableViewController: UITableViewController, UISearchBarDelegate {
    // MARK: Properties
    @IBOutlet weak var wordSearchBar: UISearchBar!
    
    var words = [
        Word(spelling: "Andante", explanation: "In a moderately slow tempo, usually considered to be slower than allegretto but faster than adagio"),
        Word(spelling: "Allegretto", explanation: "faster than andante but not so fast as allegro"),
        Word(spelling: "Allegro", explanation: "In a quick, lively tempo, usually considered to be faster than allegretto but slower than presto."),
        Word(spelling: "Presto", explanation: "executed at a rapid tempo")
    ]
    var filteredWords: [Word]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        wordSearchBar.delegate = self
        
        if let savedWords = loadWords() {
            filteredWords = savedWords
        } else {
            loadSampleWords()
        }
    }
    
    func loadSampleWords() {
        filteredWords = words
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Search bar delegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredWords = words
        } else {
            filteredWords = words.filter({ (word: Word) -> Bool in
                word.spelling.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
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
        
        cell.spellingLabel.text = word.spelling
        cell.explanationLabel.text = word.explanation
        
        return cell
    }
    
    func loadWords() -> [Word]? {
        return nil
    }
}
