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
    static var songXMLs : [XMLIndexer] = []
    static var songParts : [MusicXMLPart]? = nil
    static var songPartIndexesToDisplay : [Int] = []
    
    //playback info
    
    static var playbackStarted = false;
    // If playback has started, start at this time:
    static var playbackStartTime = Date().timeIntervalSince1970;
    //Otherwise we are stopped at this measure:
    static var stopMeasure = 0;
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // has not init'd the song yet
        if(Session.songParts == nil)
        {
            Session.songParts = MusicXMLPart.parseMusicXML(xml: Session.songXMLs[0])
            Session.getPartNumberDesired(view: self)
            let _ = MusicXMLPart.parseMusicXML(xml: Session.songXMLs[0])
        }
    }
    
    //curry magic
    static func assignPart (x: Int) -> (UIAlertAction?) -> Void
    {
        return {_ in Session.songPartIndexesToDisplay = [x]}
    }
    
    // sloppy, but works, for now.
    static func getPartNumberDesired(view: UIViewController)
    {        // create the alert
        let f = Session.songXMLs[0]["score-partwise"]
        let songname = Session.songXMLs[0]["score-partwise"]["work"]["work-title"][0].element!.text!
        let alert = UIAlertController(title: "Select primary part for: ", message: songname, preferredStyle: UIAlertControllerStyle.alert)

        for (index,element) in Session.songXMLs[0]["score-partwise"]["part-list"]["score-part"].all.enumerated()
        {
            
        let cl = assignPart(x: index)
        let action = UIAlertAction(title: element["part-name"][0].element!.text!, style: UIAlertActionStyle.default, handler: cl)
        alert.addAction(action)
        // show the alert
        }
        
        view.present(alert, animated: true, completion: nil)
    }
}
