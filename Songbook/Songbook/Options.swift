//
//  Options.swift
//  Songbook
//
//  Created by William Liddy on 4/27/17.
//  Copyright © 2017 NeutralSpace. All rights reserved.
//

import Foundation
import UIKit

class OptionMenu : UIViewController
{
    @IBOutlet weak var PrimaryPartButton: UIButton!
    @IBOutlet weak var SecondayPartButton: UIButton!
  
    @IBOutlet weak var speedDisplay: UILabel!
    @IBOutlet weak var speedStepper: UIStepper!
    
    override func viewDidLoad() {
        PrimaryPartButton.setTitle(Session.songParts?[Session.songPartIndexesToDisplay[0]].partName, for: UIControlState.normal)
        PrimaryPartButton.setNeedsDisplay()
        speedStepper.value = Double(Session.playbackSpeed)
        speedDisplay.text = String("Speed: ") + String(Session.playbackSpeed) + "%"
    }
    @IBAction func onEndSession(_ sender: AnyObject) {
        performSegue(withIdentifier: "Quit", sender: nil)
    }
    
    @IBAction func stepperChanged(_ sender: AnyObject) {
        Session.playbackSpeed = Int(speedStepper.value)
        speedDisplay.text = String("Speed: ") + String(Session.playbackSpeed) + "%"
    }
    
    @IBAction func primaryPartPress(_ sender: AnyObject) {
        Session.getPartNumberDesired(view: self)
        PrimaryPartButton.setTitle(Session.songParts?[Session.songPartIndexesToDisplay[0]].partName, for: UIControlState.normal)
        PrimaryPartButton.setTitle(Session.songParts?[Session.songPartIndexesToDisplay[0]].partName, for: UIControlState.highlighted)
        PrimaryPartButton.setTitle(Session.songParts?[Session.songPartIndexesToDisplay[0]].partName, for: UIControlState.selected)
    }
    @IBAction func secondaryPartPress(_ sender: AnyObject) {
        Session.getPartNumberDesired(view: self)
    }
}
