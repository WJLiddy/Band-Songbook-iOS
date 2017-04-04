//
//  MusicXMLPart.swift
//  Songbook
//
//  Created by William Liddy on 3/22/17.
//  Copyright © 2017 NeutralSpace. All rights reserved.
//

// Could use inheritence but this is fine. for now.
struct TabNote {
    let rest: Bool
    var offset: Int
    let duration: Int
    let stringNumber: Int
    let fret: Int
    let chordal: Bool
}

struct Measure
{
    var tabNotes: [TabNote] = []
    var duration: Int = 0
    //hardcoded for now: 960
    var secondsPerDuration: Double = 0.0005
}

import Foundation
class MusicXMLPart
{
    public var partName: String
    public var stringCount: Int
    public var measures: [Measure]
    
    // should use a builder here.
    private init(pname: String, strings: Int, allMeasures: [Measure])
    {
        partName = pname
        stringCount = strings
        measures = allMeasures
    }
    
    public static func parseNote(xml: XMLIndexer) -> TabNote
    {
        var duration: Int = 0;
        var stringNumber: Int = 0;
        var fretNumber: Int = 0;
        var isRest: Bool = false;
        var isChordal: Bool = false
        for noteattr in xml.children
        {
            switch(noteattr.element!.name)
            {
                case "duration":
                    duration = Int(noteattr[0].element!.text!)!
                    break;
                case "rest":
                    isRest = true
                    break;
                case "chord":
                    isChordal = true
                    break;
                case "notations":
                    stringNumber = Int(noteattr["technical"]["string"][0].element!.text!)!
                    fretNumber = Int(noteattr["technical"]["fret"][0].element!.text!)!
                    break;
                default:
                    break;
            }
        }
        let tabnote: TabNote =  TabNote(rest: isRest, offset: 0, duration: duration, stringNumber: stringNumber, fret: fretNumber, chordal: isChordal)
        return tabnote
    }
    
    public static func parseMeasures(xml: XMLIndexer) -> [Measure]
    {
        var measures: [Measure] = []
        var divisions: Int = 0
        var lastMeasureDuration: Int = 0;
        for XMLmeasure in xml["measure"].all
        {
            var measure: Measure = Measure()
            var playhead: Int = 0;
            var playheadLast: Int = 0;

            
            for event in XMLmeasure.children
            {
                switch(event.element!.name)
                {
                    case "attributes":
                        //read any attributes passed that are relevant
                        // We care about divisions, and time.
                        for attribute in event.children
                        {
                            switch(attribute.element!.name)
                            {
                                case "divisions":
                                    divisions = Int(attribute[0].element!.text!)!
                                    break;
                                case "time":
                                    // Find duration, in divisions.
                                    let beats: Double = Double(attribute["beats"][0].element!.text!)!
                                    let beattype: Int = Int(attribute["beat-type"][0].element!.text!)!
                                    // beattype is 4 for quarter notes, and 8 for eighth notes, etc...
                                    // so, let's find quater notes per beat.
                                    let quarterNotesPerBeat: Double = 4.0 / Double(beattype)
                                    
                                    //careful-- might lose some precision here
                                    let totalDurationInDivisions: Int = Int(beats * quarterNotesPerBeat * Double(divisions))
                                    
                                    lastMeasureDuration = totalDurationInDivisions
                                    break;
                                default:
                                    print("In measure attributes: Ignored " + attribute.element!.name)
                                    break;
                            }
                        }
                        break;
                    
                    case "note":
                        var tabNote:TabNote = parseNote(xml: event)
                        if(!tabNote.rest)
                        {
                            tabNote.offset = tabNote.chordal ? playheadLast : playhead
                            measure.tabNotes.append(tabNote)
                        }
                        
                        if(!tabNote.chordal)
                        {
                            playheadLast = playhead
                            playhead += tabNote.duration
                        }
                        break;
                    default:
                        break;
                }
                
            }
            measure.duration = lastMeasureDuration;
        measures.append(measure)
        }
        return measures
    }
    
    public static func parseMusicXML(xml: XMLIndexer) -> [MusicXMLPart]
    {
        var parts: [MusicXMLPart] = []
        
        for (index,element) in Session.songXMLs[0]["score-partwise"]["part-list"]["score-part"].all.enumerated()
        {
            let partName = element["part-name"][0].element!.text!
            // we can get the string count in the first measure.
            let scoreAttrs = Session.songXMLs[0]["score-partwise"]["part"][index]["measure"][0]["attributes"]
            
            let stringCount = Int(scoreAttrs["staff-details"]["staff-lines"].element!.text!)
            let measures = parseMeasures(xml: Session.songXMLs[0]["score-partwise"]["part"][index])
            let part = MusicXMLPart(pname: partName, strings: stringCount!, allMeasures: measures)
            parts.append(part)
            
        }
        return parts
    }
    
}
