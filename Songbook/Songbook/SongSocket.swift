//
//  SongSocket.swift
//  Songbook
//
//  Created by William Liddy on 2/23/17.
//  Copyright © 2017 NeutralSpace. All rights reserved.
//

import Foundation

class SongSocket
{
    
    enum ServerError: Error { case Offline}
    
    private static var _serverIP: String = ""
    private static var _port: Int = 1337
    
    private var _client: TCPClient
    private var _recvBuffer : String
    
    public init() throws
    {
        _recvBuffer = "";
        _client = TCPClient(addr: SongSocket._serverIP, port: SongSocket._port)
        let (success,_)=_client.connect(timeout: 1)
        if (!success)
        {
            throw ServerError.Offline
        }
    }
    
    // Reads data from the socket. Sets JSON_READY flag to TRUE if it reads a new packet.
    // Otherwise, returns false if packet is not ready.
    // Throws error if server connection dies.
    public func recvJSON() throws -> [String: Any]?
    {
        let newline = NSCharacterSet(charactersIn: "\n")
        let data=_client.read(1024*100)
        if let d=data{
            if let str=String(bytes: d, encoding: String.Encoding.ascii)
            {
                _recvBuffer = _recvBuffer + str
                if(str.rangeOfCharacter(from: newline as CharacterSet) != nil)
                {
                    //let idx = str.characters.index(of: "\n")
                    // let pos = str.characters.distance(from: str.startIndex, to: idx!) as Int
                    print("Response Finish!")
                    
                    // split the buffer
                    let lineArray = _recvBuffer.characters.split(separator: "\n").map(String.init)
                    _recvBuffer = lineArray[1];
                    //Convert String to utf8datastream
                    let jsondata = lineArray[0].data(using: .utf8)!
                    return try (JSONSerialization.jsonObject(with: jsondata) as? [String: Any]);
                }
            }
        }
        return nil;
    }
}
