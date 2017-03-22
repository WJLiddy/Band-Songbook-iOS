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

    @IBAction func onPressQuit(_ sender: UIButton)
    {
        //tear down socket and go back to main
        SongSocket.socket!.close()
        performSegue(withIdentifier: "ToMain", sender: nil)
    }
    
    @IBAction func onPressStart(_ sender: Any) {
        let fileBrowser = FileBrowser()
        present(fileBrowser, animated: true, completion: nil)
    }
    
}
