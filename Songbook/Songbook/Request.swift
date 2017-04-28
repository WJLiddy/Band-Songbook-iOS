//
//  Request.swift
//  Songbook
//
//  Created by William Liddy on 3/7/17.
//  Copyright © 2017 NeutralSpace. All rights reserved.
//

import Foundation

class Request
{
    // Swift has no notion of abstract classes
    // So I do this
    public func toJSONString() -> String
    {
        return "subclass this"
    }
}

class StartRequest : Request
{
    private var _name: String
    private var _group: String
    private var _join: Bool
    
    public init(name: String, group: String, join: Bool)
    {
        _name = name;
        _group = group;
        _join = join;
    }
    
    public override func toJSONString() -> String
    {
        let jsonObject:NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(_name, forKey: "user name")
        jsonObject.setValue(_group, forKey: "group name")
        if(_join)
        {
            jsonObject.setValue("join group", forKey: "request")
        } else
        {
            jsonObject.setValue("create group", forKey: "request")
        }
        let jsonData: NSData
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) as NSData
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) as! String
            print("json string = \(jsonString)")
            return jsonString
        } catch _ {
            print ("JSON Failure")
        }
        // Parsing will never fail
        return ""
    }
}

class StartSessionRequest : Request
{
    private var _songList: [String]
    
    public init(songList: [String])
    {
        _songList = songList;
    }
    
    public override func toJSONString() -> String
    {
        let jsonObject:NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(_songList, forKey: "songs")
        jsonObject.setValue("begin session", forKey: "request")
        let jsonData: NSData
        do {
            jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) as NSData
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) as! String
            return jsonString
        } catch _ {
            print ("JSON Failure")
        }
        // Parsing will never fail
        return ""
    }
}

class StartPlaybackRequest : Request
{
    private var _time: Int
    private var _tempo: Double
    private var _measure: Int
    
    public init(time: Int, tempo: Double, measure: Int)
    {
        _time = time
        _tempo = tempo
        _measure = measure
    }
    
    public override func toJSONString() -> String
    {
        let jsonObject:NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue("begin playback", forKey: "request")
        jsonObject.setValue(_time, forKey: "time")
        jsonObject.setValue(_tempo, forKey: "tempo")
        jsonObject.setValue(_measure, forKey: "measure")
        let jsonData: NSData
        do {
            jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) as NSData
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) as! String
            return jsonString
        } catch _ {
            print ("JSON Failure")
        }
        // Parsing will never fail
        return ""
    }
}

class StopPlaybackRequest : Request
{

    public override func toJSONString() -> String
    {
        let jsonObject:NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue("stop playback", forKey: "request")
        let jsonData: NSData
        do {
            jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) as NSData
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) as! String
            return jsonString
        } catch _ {
            print ("JSON Failure")
        }
        // Parsing will never fail
        return ""
    }
}

class SwitchSongRequest : Request
{
    private var _songNo: Int
    
    public init(songNo: Int)
    {
        _songNo = songNo
    }
    
    public override func toJSONString() -> String
    {
        let jsonObject:NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(_songNo, forKey: "switch song")
        
        let jsonData: NSData
        do {
            jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) as NSData
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) as! String
            return jsonString
        } catch _ {
            print ("JSON Failure")
        }
        // Parsing will never fail
        return ""
    }
}




