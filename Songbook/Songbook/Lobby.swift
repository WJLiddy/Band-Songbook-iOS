//
//  Lobby.swift
//  Songbook
//
//  Created by William Liddy on 3/21/17.
//  Copyright © 2017 NeutralSpace. All rights reserved.
//

import Foundation
import UIKit

class Lobby : UIViewController
{
    @IBOutlet weak var AddSongs: UIButton!
    
    @IBOutlet weak var Quit: UIButton!
    
    public static var isBandLeader = false

    override func viewDidLoad() {
        if(!Lobby.isBandLeader)
        {
            AddSongs.removeFromSuperview()
            Quit.removeFromSuperview()
        }
    }
    
    @IBAction func onPressQuit(_ sender: UIButton)
    {
        //tear down socket and go back to main
        SongSocket.socket!.close()
        performSegue(withIdentifier: "ToMain", sender: nil)
    }
    
    @IBAction func onPressStart(_ sender: Any) {
        print("Sending " + String(FileBrowser.songsToPlay.count) + " songs")
        // Don't send yet. I just want to show parsing almost work.
        Session.songXMLs = []
        print("parsing...")
        for fname in FileBrowser.songsToPlay
        {
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            {
                let path = dir.appendingPathComponent(fname)
                
                //reading
                do {
                    let text2 = try String(contentsOf: path, encoding: String.Encoding.utf8)
                    Session.songXMLs.append(SWXMLHash.parse(text2))
                }
                catch {/* error handling here */}
            }
        }
        print("proceeding to session")
        //Done! Proceed to the session.
            performSegue(withIdentifier: "ToSession", sender: nil)
        
        
    }
    
    @IBAction func onPressAddSongs(_ sender: Any) {
        let fileBrowser = FileBrowser()
        present(fileBrowser, animated: true, completion: nil)
    }
}
