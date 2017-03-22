//
//  MainMenu.swift
//  Songbook
//
//  Created by William Liddy on 3/21/17.
//  Copyright © 2017 NeutralSpace. All rights reserved.
//

import Foundation
import UIKit
class MainMenu : UIViewController
{
    override func viewDidLoad() {

    }

    @IBAction func joinGroupPressed(_ sender: AnyObject) {
        print("join")
        if(setSocket() && joinRequestOK())
        {
            performSegue(withIdentifier: "ToLobby", sender: nil)
        }
    }
    @IBAction func createGroupPressed(_ sender: AnyObject) {
        if(setSocket() && createRequestOK())
        {
            performSegue(withIdentifier: "ToLobby", sender: nil)
        }
    }
    
    // return true if connection was init'd, throws error and displays err message if not.
    public func setSocket() -> Bool
    {
        // Make sure we can connect to the server. If we cannot, throw an error message, and close the app.
        do
        {
            try SongSocket.socket = SongSocket();
        } catch
        {
            UIErrorMessage.init(viewController: self, errorMessage: "Server is offline").show()
            return false;
        }
        return true;
    }

        // return true if connection was init'd, throws error and displays err message if not.
        public func joinRequestOK() -> Bool
        {
            return true;
        }
        
        // return true if connection was init'd, throws error and displays err message if not.
        public func createRequestOK() -> Bool
        {
            return true;
        }

}
