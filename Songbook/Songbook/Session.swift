//
//  Lobby.swift
//  Songbook
//
//  Created by William Liddy on 3/21/17.
//  Copyright © 2017 NeutralSpace. All rights reserved.
//

import Foundation
import UIKit

class Session : UIViewController
{
    //TODO dump songs into a more friendly data struct based on musicXML specs.
    static var songXMLs : [XMLIndexer] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getPartNumberDesired()
    }
    
    //curry magic
    func assignPart (x: Int) -> (UIAlertAction?) -> Void
    {
        return {_ in print(x)}
    }
    
    func getPartNumberDesired()
    {        // create the alert
        let songname = Session.songXMLs[0]["score-partwise"]["work"]["work-title"][0].element!.text!
        let alert = UIAlertController(title: "Select primary part for: ", message: songname, preferredStyle: UIAlertControllerStyle.alert)

        print(Session.songXMLs[0]["score-partwise"]["part-list"].all.count)
        print(Session.songXMLs[0]["score-partwise"]["part-list"]["score-part"].all.count)
        for (index,element) in Session.songXMLs[0]["score-partwise"]["part-list"]["score-part"].all.enumerated()
        {
            
        let cl = assignPart(x: index)
        let action = UIAlertAction(title: element["part-name"][0].element!.text!, style: UIAlertActionStyle.default, handler: cl)
        alert.addAction(action)
        // show the alert
        }
        
        self.present(alert, animated: true, completion: nil)
    }
}
