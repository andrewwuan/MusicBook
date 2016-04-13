//
//  WordDetailViewController.swift
//  MusicBook
//
//  Created by An Wu on 4/10/16.
//  Copyright © 2016 An Wu. All rights reserved.
//

import UIKit

class WordDetailViewController: UIViewController {
    
    // MARK: Properties
    var word: Word!
    @IBOutlet weak var explanationBox: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = word.spelling!

        explanationBox.textContainerInset = UIEdgeInsetsMake(15, 30, 0, 30)
        
        let mutableAttributedString = NSMutableAttributedString()
        word.explanations!.enumerate().forEach({ (index, explanationObj) in
            let explanation = explanationObj as! WordExplanation
            
            let attributedString = try? NSAttributedString(data: ("\(index + 1). " + cleanEncodedStr(explanation.encodedStr!) + "<br /><br />" + "<style>* {font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 16px; line-height: 150%;}</style>").dataUsingEncoding(NSUTF8StringEncoding)!, options:[NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding], documentAttributes: nil)
            mutableAttributedString.appendAttributedString(attributedString!)
        })

        explanationBox.attributedText = mutableAttributedString
        explanationBox.showsVerticalScrollIndicator = false
        explanationBox.scrollEnabled = false
    }
    
    func cleanEncodedStr(encodedStr: String) -> String {
        
        return encodedStr.componentsSeparatedByString("<li>").count == 2 ?
            encodedStr
                .stringByReplacingOccurrencesOfString("<li>", withString: "")
                .stringByReplacingOccurrencesOfString("</li>", withString: "")
                .stringByReplacingOccurrencesOfString("<ul>", withString: "")
                .stringByReplacingOccurrencesOfString("</ul>", withString: "")
            : encodedStr
        
    }
    
    override func viewDidAppear(animated: Bool) {
        explanationBox.scrollEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
