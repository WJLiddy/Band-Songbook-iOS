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
    private static var _serverIP: String = "34.197.242.214"
    private static var _port: Int = 54106
    
    private var _client: TCPClient
    private var _recvBuffer : String
    
    //We will only have one song socket-- this will be referenced everywhere
    public static var socket: SongSocket?;
    
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
    
    
    // Reads data from the socket. returns a JSON if it reads one.
    // Otherwise, returns nil if packet is not ready.
    // Throws error if server connection dies.
    public func recvJSON() throws -> [String: Any]?
    {
        let newline = NSCharacterSet(charactersIn: "\n")
        //Convert microseconds to 10 msec
        let data=_client.read(1024*100, timeout: 10000)
        if let d=data{
            if let str=String(bytes: d, encoding: String.Encoding.ascii)
            {
                _recvBuffer = _recvBuffer + str
            }
        }
        print("IN RECV BUFFER IS" + _recvBuffer)
        //outstanding message to be sent
        if(_recvBuffer.rangeOfCharacter(from: newline as CharacterSet) != nil)
        {
            // split the buffer
            let lineArray = _recvBuffer.components(separatedBy: "\n")
            _recvBuffer = ""
            for i in 1..<lineArray.count
            {
                _recvBuffer += lineArray[i] + (i == lineArray.count - 1 ? "" : "\n");
            }
            //Convert String to utf8datastream
            let jsondata = lineArray[0].data(using: .utf8)!
            return try (JSONSerialization.jsonObject(with: jsondata) as? [String: Any]);
        }
        return nil;
    }
    
    public func sendRequest(request : Request) 
    {
        let _ = _client.send(str: request.toJSONString() + "\n")
    }
    
    public func close()
    {
        let _ =  _client.close()
    }
}
