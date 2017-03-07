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

class JoinRequest : Request
{
    private var _name: String
    private var _group: String
    
    public init(name: String, group: String)
    {
        _name = name;
        _group = group;
    }
    
    public override func toJSONString() -> String
    {
        let jsonObject:NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(_name, forKey: "user name")
        jsonObject.setValue(_group, forKey: "group name")
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


