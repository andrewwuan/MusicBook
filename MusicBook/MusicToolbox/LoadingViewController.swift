//
//  LoadingViewController.swift
//  MusicBook
//
//  Created by An Wu on 4/11/16.
//  Copyright © 2016 An Wu. All rights reserved.
//

import UIKit
import CoreData

class LoadingViewController: UIViewController {
    
    
    @IBOutlet weak var loadingProgress: UIProgressView!

    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(animated: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let isPreloaded = defaults.boolForKey("isPreloaded")
        if !isPreloaded {
            appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            managedContext = appDelegate.managedObjectContext
            preloadData()
            defaults.setBool(true, forKey: "isPreloaded")
        } else {
            loadingProgress.setProgress(1.0, animated: true)
        }

        performSegueWithIdentifier("ShowWordTable", sender: loadingProgress)
    }
    
    func transitionToTableView() {
        presentViewController(WordTableViewController(), animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Core Data loading
    func preloadData () {
        // Retrieve data from the source files
        let resourcePath = NSBundle.mainBundle().resourcePath!
        let allFilesOpt = try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(resourcePath)
        
        print("Going to process all files")
        if let allFiles = allFilesOpt {
            let dataFiles = allFiles.filter { (filename: String) -> Bool in
                filename.hasSuffix(".json")
            }
            
            // Remove existing data in data model
            print("Removing data")
            removeData()
            
            // Parse data files and insert into data model
            dataFiles.enumerate().forEach({ (index: Int, dataFile: String) in
                do {
                    print("Parsing data file \(dataFile)")
                    try parseDataFile(dataFile, index, dataFiles.count)
                } catch let error as NSError {
                    print("Could not parse \(dataFile), \(error.userInfo)")
                }
            })
            
        } else {
            print("Can't get files under " + resourcePath)
        }
    }
    
    func removeData() {
        
        let fetchRequest = NSFetchRequest(entityName: "Word")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedContext.executeRequest(deleteRequest)
        } catch let error as NSError {
            print("Could not delete all \(error), \(error.userInfo)")
        }
    }
    
    func parseDataFile(filename: String, _ fileIndex: Int, _ totalFiles: Int) throws {
        let wordEntity = NSEntityDescription.entityForName("Word", inManagedObjectContext: managedContext)!
        let wordExplanationEntity = NSEntityDescription.entityForName("WordExplanation", inManagedObjectContext: managedContext)!
        
        if let path = NSBundle.mainBundle().resourcePath?.stringByAppendingString("/\(filename)") {
            if let jsonData = NSData(contentsOfFile: path) {
                if let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                    jsonResult.forEach { (spellingObj, explanationObjs) -> Void in
                        let spelling = spellingObj as! String
                        let finalSpelling = spelling.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        let word = Word(entity: wordEntity, insertIntoManagedObjectContext: managedContext)
                        word.spelling = finalSpelling
                        
                        let explanations = (explanationObjs as! NSArray).map({ (explanationObj) -> NSManagedObject in
                            let explanation = WordExplanation(entity: wordExplanationEntity, insertIntoManagedObjectContext: managedContext)
                            let explanationStr = explanationObj as? String
                            let attributedString = try? NSAttributedString(data: explanationStr!.dataUsingEncoding(NSUTF8StringEncoding)!, options:[NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding], documentAttributes: nil)
                            
                            explanation.encodedStr = explanationStr
                            explanation.decodedObj = attributedString
                            explanation.decodedStr = attributedString!.string
                            
                            explanation.word = word
                            return explanation
                        })
                        
                        word.explanations = NSOrderedSet(array: explanations)
                    }
                }
            }
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        loadingProgress.setProgress(Float(fileIndex + 1) / Float(totalFiles), animated: true)
    }
    
}
