// This class parses the musicXML into a usable data structure.
// Right now, there are two types of basic notes. TabNotes, and PercussionNotes.

// every note has a "rhythm" which consists of two parts
// the offset (which measures where the note is relative to the start of it's measure)
// and the duration (how long the note is)
// Both of these are measured in "divisions", a unit which will be described later.
class Rhythm
{
    let offset: Int
    let duration: Int
    init(offset: Int, duration: Int)
    {
        self.offset = offset;
        self.duration = duration;
    }
}

// If we are playing stringed instr., we have a "TabNote" which contains the string and fret
class TabNote
{
    let string: Int
    let fret: Int
    let rhythm: Rhythm

    init(string: Int, fret: Int, rhythm: Rhythm)
    {
        self.string = string;
        self.fret = fret;
        self.rhythm = rhythm
    }
}

// On a drum, we have an enum that says the type of the note to sound
class DrumNote
{
    enum NoteType {
        case bass, snare, hat_open, hat_close, hat_pedal, crash, ride, tom
    }
    let noteType: NoteType
    let rhythm: Rhythm
    
    init(noteType: NoteType, rhythm: Rhythm)
    {
        self.noteType = noteType;
        self.rhythm = rhythm
    }
}

// The notetype that sounds is based on the midi code.
// http://www.pjb.com.au/muscript/gm.html
// In our case, we want to group midi codes into the proper instrument.
// No drummer is going to have a 50-piece drum set as described in the midi spec,
// So we write a quick helper class that coverts a midi code into the proper drum code.
class MidiCodeConverter
{
    var codeMap : [Int: DrumNote.NoteType];
    init()
    {
        codeMap = [:]
        codeMap[35] = DrumNote.NoteType.bass;
        codeMap[36] = DrumNote.NoteType.bass;
        codeMap[38] = DrumNote.NoteType.snare;
    }
    
    public func doesDrumExist(midiCode: Int) -> Bool
    {
        return codeMap[midiCode] != nil
    }
    
    public func midiCodeToDrumNote(midiCode: Int) -> DrumNote.NoteType
    {
        return codeMap[midiCode]!
    }
}

// finally we have two types of measure containers, which store tab / drum notes.
class Measure
{
    //duration, in divisions.
    let duration: Int;
    let secondsPerDivision: Double;
    // How many seconds away is this measure from the start?
    var timeFromStart: Double;
    init(duration: Int, secondsPerDivision: Double, timeFromStart: Double)
    {
        self.duration = duration;
        self.secondsPerDivision = secondsPerDivision;
        self.timeFromStart = timeFromStart
    }
}

// measures to hold each kind of note.
class DrumMeasure : Measure
{
    var notes : [DrumNote]
    override init(duration: Int, secondsPerDivision: Double, timeFromStart: Double)
    {
        self.notes = []
        super.init(duration: duration,secondsPerDivision : secondsPerDivision,timeFromStart: timeFromStart)
    }
}

class TabMeasure : Measure
{
    var notes : [TabNote]
    override init(duration: Int, secondsPerDivision: Double, timeFromStart: Double)
    {
        self.notes = []
        super.init(duration: duration,secondsPerDivision : secondsPerDivision,timeFromStart: timeFromStart)
    }
}


// A MusicXML part has a list of measures, and a part name.
// By passing in an music XML, you get a list of parts.
// TODO: Will crash if there is any XML that does not follow the spec.
class MusicXMLPart
{
    let partName: String
    let measures: [Measure]
    
    public init(partName: String, measures: [Measure])
    {
        self.partName = partName;
        self.measures = measures;
    }
    
    // Give XML, get parts
    public static func parseMusicXML(xml: XMLIndexer) -> [MusicXMLPart]
    {
        var parts: [MusicXMLPart] = []
        
        // Iterate over every part.
        for (index,element) in Session.songXMLs[Session.currentSong]["score-partwise"]["part-list"]["score-part"].all.enumerated()
        {
            let partName = element["part-name"][0].element!.text!
            let midiChannel = element["midi-instrument"]["midi-channel"][0].element!.text!
            // We need to see if this is a percussion or a tabbed part.
            // Do this by checking the midi channel: 10 means percussion
            
            if(midiChannel == "10")
            {
                // this is a PERCUSSION part.
                let measures = MusicXMLDrumPart.parseMeasures(xml: Session.songXMLs[Session.currentSong]["score-partwise"]["part"][index])
                let part = MusicXMLDrumPart(partName: partName, measures: measures);
                parts.append(part)
            } else
            {
                // this is a TAB part.
                // we can get the string count in the first measure.
                let scoreAttrs = Session.songXMLs[Session.currentSong]["score-partwise"]["part"][index]["measure"][0]["attributes"]
                let stringCount = Int(scoreAttrs["staff-details"]["staff-lines"].element!.text!)
                let measures = MusicXMLTabPart.parseMeasures(xml: Session.songXMLs[Session.currentSong]["score-partwise"]["part"][index])
                let part = MusicXMLTabPart(partName: partName, strings: stringCount!, measures: measures);
                parts.append(part)
                
            }
        }
        return parts
    }
    
    //calcluate how many divisions are in a meaure
    public static func calculateMeasureDivisions(divisionsPerQuarter: Int, attribute : XMLIndexer) -> Int
    {
        // Find the time signature of the measure. (beats / beat type)
        let beats: Double = Double(attribute["beats"][0].element!.text!)!
        let beattype: Int = Int(attribute["beat-type"][0].element!.text!)!
        
        // Convert the time signature to find the quarter notes per beat.
        // beattype is 4 for quarter notes, and 8 for eighth notes, etc...
        let quarterNotesPerBeat: Double = 4.0 / Double(beattype)
        
        // Now, since we know the divisions per quarter note, we can find the total divisons
        return Int(beats * quarterNotesPerBeat * Double(divisionsPerQuarter))
        
    }
    
    struct MusicParameters
    {
        // divisions are given to us as divs per quarter
        var divisionsPerQuarter: Int = 0
        // How many divisions was in the last measure?
        // If this does not change, it carries over to the next measure.
        var lastMeasureDivisions: Int = 0;
        // Tempo is returned in BMP. This is like lastmeasure divisions. It can change based on the song.
        var tempo: Int = 0;
        // This measures the time from the end of the previous measure.
        // We need this because we need the timestamp for each measure.
        var totalTimeElapsed = 0.0;
    }
    
    public static func updateMusicParameters(mp : inout MusicParameters, event: XMLIndexer)
    {
        switch(event.element!.name)
        {
            case "attributes":
            //read any attributes that are relevant in this measure.
            for attribute in event.children
            {
                switch(attribute.element!.name)
                {
                    case "divisions":
                        mp.divisionsPerQuarter = Int(attribute[0].element!.text!)!
                    break;
                    case "time":
                        mp.lastMeasureDivisions = calculateMeasureDivisions(divisionsPerQuarter: mp.divisionsPerQuarter, attribute: attribute)
                    break;
                    default:
                        // read some attribute that did not matter to us, such as key sig.
                        //print("In measure attributes: Ignored " + attribute.element!.name)
                    break;
                }
            }
            break;
            // The only thing in direction is the tempo.
            case "direction":
                mp.tempo = Int((event["sound"][0].element?.attribute(by: "tempo")?.text)!)!
            break;
            default:break;
        }
    }
    
    public static func noteIsRest(xml: XMLIndexer) -> Bool
    {
        var rest = false;
        //TODO lookup vs iteration
        for noteattr in xml.children
        {
            switch(noteattr.element!.name)
            {
                case "rest":
                    rest = true
                break;
                default:break;
            }
        }
        return rest;
    }
    
    public static func noteIsChord(xml: XMLIndexer) -> Bool
    {
        var chord = false;
        //TODO lookup vs iteration
        for noteattr in xml.children
        {
            switch(noteattr.element!.name)
            {
            case "chord":
                chord = true
                break;
                default:break;
            }
        }
        return chord;
    }
    
    public static func getNoteDuration(xml: XMLIndexer) -> Int
    {
        var duration: Int = 0;
        for noteattr in xml.children
        {
            //TODO lookup vs iteration
            switch(noteattr.element!.name)
            {
            case "duration":
                duration = Int(noteattr[0].element!.text!)!
                break;
            default:
                break;
            }
        }
        return duration;
    }
    
    public static func getNoteString(xml: XMLIndexer) -> Int
    {
        var stringNumber: Int = 0;
        for noteattr in xml.children
        {
            //TODO lookup vs iteration
            switch(noteattr.element!.name)
            {
            case "notations":
                stringNumber = Int(noteattr["technical"]["string"][0].element!.text!)!
                break;
            default:
                break;
            }
        }
        return stringNumber;
    }
    
    public static func getNoteFret(xml: XMLIndexer) -> Int
    {
        var fretNumber: Int = 0;
        for noteattr in xml.children
        {
            //TODO lookup vs iteration
            switch(noteattr.element!.name)
            {
            case "notations":
                 fretNumber = Int(noteattr["technical"]["fret"][0].element!.text!)!
                break;
            default:
                break;
            }
        }
        return fretNumber;
    }
    
}

class MusicXMLDrumPart : MusicXMLPart
{
    public static func parseMeasures(xml: XMLIndexer) -> [Measure]
    {
        var mp = MusicParameters()
        var measures = [DrumMeasure]()
        
        for XMLmeasure in xml["measure"].all
        {
            // The playhead is responsible for keeping track of the division number of the end of the last note.
            var playhead: Int = 0;
            // need to keep track of where the playhead was last in case a chord is tacked on to some note.
            var playheadLast: Int = 0;
            var notes = [DrumNote]()
            for event in XMLmeasure.children
            {
                switch(event.element!.name)
                {
                // attributes and direction have general information about a measure (such as tempo change, etc)
                case "attributes","direction":
                    updateMusicParameters(mp: &mp, event: event)
                break;
                // Then we have notes. Pass these to the proper parser.
                case "note":
                    
                    //First, see if this is a rest. If it is, just push the playhead up.
                    if(noteIsRest(xml: event))
                    {
                        playheadLast = playhead
                        playhead += getNoteDuration(xml: event)
                        continue;
                    }
                    
                    let start = noteIsChord(xml: event) ? playheadLast : playhead
                    //Otherwise this is a real note.
                    let note = DrumNote(noteType: DrumNote.NoteType.bass, rhythm: Rhythm(offset: start, duration: getNoteDuration(xml: event)))
                    
                    //If the note is not part of a chord, push the playhead.
                    if(!noteIsChord(xml: event))
                    {
                        playheadLast = playhead
                        playhead += note.rhythm.duration
                    }
                    notes.append(note)
                break;
                default:
                    break;
                }
                
            }
            // finally, create measure of appropriate container type.
            // inverse of div / quarter * quater / min ... just trust me, this conversion works.
            let secondsPerDivision =  1.0 / (Double(mp.divisionsPerQuarter) * (Double(mp.tempo) / 60.0))
            let measure = DrumMeasure(duration: mp.lastMeasureDivisions, secondsPerDivision: secondsPerDivision, timeFromStart: mp.totalTimeElapsed)
            measure.notes = notes;

            mp.totalTimeElapsed += Double(measure.duration) * measure.secondsPerDivision;
            measures.append(measure)

        }
        return measures
    }

}

class MusicXMLTabPart : MusicXMLPart
{
    let strings : Int
    public init(partName: String, strings: Int, measures: [Measure])
    {
        self.strings = strings;
        super.init(partName: partName, measures: measures)
    }
    
    // more of this is copied than i'd like to admit but i cant figure out the polymorphism
    // I'm close, but it still could use some refactoring.
    public static func parseMeasures(xml: XMLIndexer) -> [Measure]
    {
        var mp = MusicParameters()
        var measures = [TabMeasure]()
        
        for XMLmeasure in xml["measure"].all
        {
            // The playhead is responsible for keeping track of the division number of the end of the last note.
            var playhead: Int = 0;
            // need to keep track of where the playhead was last in case a chord is tacked on to some note.
            var playheadLast: Int = 0;
            var notes = [TabNote]()
            for event in XMLmeasure.children
            {
                switch(event.element!.name)
                {
                // attributes and direction have general information about a measure (such as tempo change, etc)
                case "attributes","direction":
                    updateMusicParameters(mp: &mp, event: event)
                    break;
                // Then we have notes. Pass these to the proper parser.
                case "note":
                    
                    //First, see if this is a rest. If it is, just push the playhead up.
                    if(noteIsRest(xml: event))
                    {
                        playheadLast = playhead
                        playhead += getNoteDuration(xml: event)
                        continue;
                    }
                    
                    let start = noteIsChord(xml: event) ? playheadLast : playhead
                    //Otherwise this is a real note.
                    let note = TabNote(string: getNoteString(xml: event), fret: getNoteFret(xml: event), rhythm: Rhythm(offset: start, duration: getNoteDuration(xml: event)))
                    
                    //If the note is not part of a chord, push the playhead.
                    if(!noteIsChord(xml: event))
                    {
                        playheadLast = playhead
                        playhead += note.rhythm.duration
                    }
                    notes.append(note)
                    break;
                default:
                    break;
                }
                
            }
            // finally, create measure of appropriate container type.
            // inverse of div / quarter * quater / min ... just trust me, this conversion works.
            let secondsPerDivision =  1.0 / (Double(mp.divisionsPerQuarter) * (Double(mp.tempo) / 60.0))
            let measure = TabMeasure(duration: mp.lastMeasureDivisions, secondsPerDivision: secondsPerDivision, timeFromStart: mp.totalTimeElapsed)
            measure.notes = notes;
            
            mp.totalTimeElapsed += Double(measure.duration) * measure.secondsPerDivision;
            measures.append(measure)
        }
        return measures
    }
    
}


  
