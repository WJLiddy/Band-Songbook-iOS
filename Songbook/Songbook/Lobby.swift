import Foundation
import UIKit

// Here is the lobby. In this UI View, the bandleader awaits people to join, and can also select songs to play.
class Lobby : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var AddSongs: UIButton!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var Quit: UIButton!
    
    public static var isBandLeader = false
    
    var updateTimer: Timer?

    override func viewDidLoad() {
        if(!Lobby.isBandLeader)
        {
            AddSongs.removeFromSuperview()
            Quit.removeFromSuperview()
        }
        
        updateTimer = Timer.scheduledTimer(timeInterval: 0.05, target:self, selector: #selector(checkForUpdatedGroupInfo), userInfo: nil, repeats: true)
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
    
    }
    

    
    func checkForUpdatedGroupInfo()
    {
        var recv: [String: Any]?
        do
        {
            recv = try SongSocket.socket!.recvJSON()
        } catch
        {
            UIErrorMessage.init(viewController: self, errorMessage: "There is an issue with the server. (CLIENT RECVD INVALID JSON)").show()
            return;
        }
        if(recv != nil)
        {
            print("RECVD MESSAGE")
            if (recv!["group members"] != nil)
            {
                Lobby.usernames = recv!["group members"] as! [String]
                tableView.reloadData()
            }
            
            if (recv!["session"] != nil && recv!["session"] as! String == "end")
            {
                UIErrorMessage.init(viewController: self, errorMessage: "The session is ending").show()
                //tear down socket and go back to main
                SongSocket.socket!.close()
                updateTimer?.invalidate()
                performSegue(withIdentifier: "ToMain", sender: nil)
            }
            
            if (recv!["session"] != nil && recv!["session"] as! String == "start")
            {
                Session.songXMLs = []
                // parse sent songXMLs.
                for song in recv!["songs"] as! [String]
                {
                    Session.songXMLs.append(SWXMLHash.parse(song))
                }
                
                updateTimer?.invalidate()
                performSegue(withIdentifier: "ToSession", sender: nil)
                //“songs”: [XML #0, XML #1, .... ]
            }
            
 
 

        }
    }
    
    @IBAction func onPressQuit(_ sender: UIButton)
    {
        //tear down socket and go back to main
        SongSocket.socket!.close()
        updateTimer?.invalidate()
        performSegue(withIdentifier: "ToMain", sender: nil)
    }
    
    @IBAction func onPressStart(_ sender: Any) {
        print("Sending " + String(FileBrowser.songsToPlay.count) + " songs")
        Session.songXMLs = []
        var songXMLStrings: [String] = []
        print("parsing...")
        for fname in FileBrowser.songsToPlay
        {
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            {
                let path = dir.appendingPathComponent(fname)
                
                //reading
                do {
                    let text2 = try String(contentsOf: path, encoding: String.Encoding.utf8)
                    songXMLStrings.append(text2)
                    Session.songXMLs.append(SWXMLHash.parse(text2))
                }
                catch {/* error handling here */}
            }
        }
        // send JSONs over the network and await an "ok"
         SongSocket.socket!.sendRequest(request : StartSessionRequest(songList: songXMLStrings))
        print("proceeding to session")
        //Done! Proceed to the session.
        updateTimer?.invalidate()
        performSegue(withIdentifier: "ToSession", sender: nil)
        
        
    }
    
    @IBAction func onPressAddSongs(_ sender: Any) {
        let fileBrowser = FileBrowser()
        present(fileBrowser, animated: true, completion: nil)
    }
    

    
    // Data model: These strings will be the data for the table view cells
    static var usernames: [String] = [""]
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"


    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Lobby.usernames.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        // set the text from the data model
        cell.textLabel?.text = Lobby.usernames[indexPath.row]
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }

    
}
