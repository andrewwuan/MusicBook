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
        
        loadingProgress.setProgress(0.0, animated: false)

    }
    
    override func viewDidAppear(animated: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let isPreloaded = defaults.boolForKey("isPreloaded")
        if !isPreloaded {
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                self.managedContext = self.appDelegate.managedObjectContext
                
                self.preloadData()
                
                defaults.setBool(true, forKey: "isPreloaded")

                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("ShowWordTable", sender: self.loadingProgress)
                }
            }
        } else {
            loadingProgress.setProgress(1.0, animated: true)
            performSegueWithIdentifier("ShowWordTable", sender: loadingProgress)
        }

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
                print("Parsing data file \(dataFile)")
                dispatch_sync(dispatch_get_main_queue(), {
                    _ = try? self.parseDataFile(dataFile, index, dataFiles.count)
                })
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
                            
                            explanation.encodedStr = explanationStr
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
        
        self.loadingProgress.setProgress(Float(fileIndex + 1) / Float(totalFiles), animated: true)

    }
    
}
