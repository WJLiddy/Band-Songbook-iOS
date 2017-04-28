//
//  SongSelect.swift
//  Songbook
//
//  Created by William Liddy on 4/27/17.
//  Copyright © 2017 NeutralSpace. All rights reserved.
//

import Foundation

import UIKit

class SongSelect: UITableViewController
{
    
    var songs : [String] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        for song in Session.songXMLs
        {
            songs.append(song["score-partwise"]["work"]["work-title"][0].element!.text!)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        cell.textLabel?.text = songs [indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell number: \(indexPath.row)!")
        // trasmit message that we are switching songs.
        SongSocket.socket!.sendRequest(request : SwitchSongRequest(songNo: indexPath.row))
        // reset song state
        Session.songParts = nil
        //playback info
        Session.playbackStarted = false;
        Session.playbackStartTime = Date().timeIntervalSince1970;
        Session.stopMeasure = 0;
        Session.playbackSpeed = 100;
        Session.songPartIndexesToDisplay = [0];
        // segue back with new song in mind.
        Session.currentSong = indexPath.row
        self.performSegue(withIdentifier: "toSession", sender: self)
    }
}
