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
    static var currentSong : Int = 0
    static var currentSession : Session? = nil
    
    //playback info
    
    static var playbackStarted = false;
    // If playback has started, start at this time:
    static var playbackStartTime = Date().timeIntervalSince1970;
    //Otherwise we are stopped at this measure:
    static var stopMeasure = 0;
    
    static var playbackSpeed = 100;
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Session.currentSession = self
        // has not init'd the song yet
        if(Session.songParts == nil)
        {
            Session.songParts = MusicXMLPart.parseMusicXML(xml: Session.songXMLs[Session.currentSong])
            Session.getPartNumberDesired(view: self)
            let _ = MusicXMLPart.parseMusicXML(xml: Session.songXMLs[Session.currentSong])
        }
    }
    
    //curry magic
    static func assignPart (x: Int) -> (UIAlertAction?) -> Void
    {
        return {_ in Session.songPartIndexesToDisplay = [x]}
    }
    
    //curry magic
    static func assignSecondPart (x: Int) -> (UIAlertAction?) -> Void
    {
        return {_ in Session.songPartIndexesToDisplay[1] = x}
    }
    
    // sloppy, but works, for now.
    static func getPartNumberDesired(view: UIViewController)
    {        // create the alert
        let parts = Session.songXMLs[Session.currentSong]["score-partwise"]
        let songname = parts["work"]["work-title"][0].element!.text!
        let alert = UIAlertController(title: "Select primary part for: ", message: songname, preferredStyle: UIAlertControllerStyle.alert)

        for (index,element) in parts["part-list"]["score-part"].all.enumerated()
        {
            
        let cl = assignPart(x: index)
        let action = UIAlertAction(title: element["part-name"][0].element!.text!, style: UIAlertActionStyle.default, handler: cl)
        alert.addAction(action)
        // show the alert
        }
        
        view.present(alert, animated: true, completion: nil)
    }
    
    // sloppy, but works, for now.
    static func getSecondaryPartNumberDesired(view: UIViewController)
    {
        if(Session.songPartIndexesToDisplay.count == 1)
        {
            Session.songPartIndexesToDisplay.append(0)
        }
    
        
        // create the alert
        let parts = Session.songXMLs[Session.currentSong]["score-partwise"]
        let songname = parts["work"]["work-title"][0].element!.text!
        let alert = UIAlertController(title: "Select secondary part for: ", message: songname, preferredStyle: UIAlertControllerStyle.alert)
        
        for (index,element) in parts["part-list"]["score-part"].all.enumerated()
        {
            let cl = assignSecondPart(x: index)
            let action = UIAlertAction(title: element["part-name"][0].element!.text!, style: UIAlertActionStyle.default, handler: cl)
            alert.addAction(action)
            // show the alert
        }
        
        view.present(alert, animated: true, completion: nil)
    }
}
