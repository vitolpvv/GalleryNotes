//
//  NoteExtensions.swift
//  
//
//  Created by VitalyP on 19/06/2019.
//
import UIKit

public extension Note {
    // String constants
    enum JsonKeys {
        static let uid = "uid"
        static let title = "title"
        static let content = "content"
        static let color = "color"
        static let colorRed = "r"
        static let colorGreen = "g"
        static let colorBlue = "b"
        static let colorAlpha = "a"
        static let importance = "importance"
        static let liveTill = "live_till"
    }
    
    // Create Note instance from dictionary
    static func parse(json: [String: Any]) -> Note? {
        // Check json contains required fields: uid, title, content
        let requiredFields: Set = [JsonKeys.uid, JsonKeys.title, JsonKeys.content]
        guard requiredFields.isSubset(of: json.keys) else {return nil}
        
        // Parse color
        var color: UIColor
        switch json[JsonKeys.color] {
        case let rgba as [String: CGFloat]:
            color = UIColor(red: rgba[JsonKeys.colorRed]!,
                            green: rgba[JsonKeys.colorGreen]!,
                            blue: rgba[JsonKeys.colorBlue]!,
                            alpha: rgba[JsonKeys.colorAlpha]!)
        default: color = UIColor.white
        }
        // Parse importance
        var importance: Importance
        switch json[JsonKeys.importance] {
        case let importanceRaw as String:
            importance = Importance(rawValue: importanceRaw) ?? Importance.normal
        default: importance = Importance.normal
        }
        // Parse liveTill
        var liveTill: Date?
        switch json[JsonKeys.liveTill] {
        case let timeInterval as TimeInterval:
            liveTill = Date(timeIntervalSince1970: timeInterval)
        default: break
        }
        
        return Note(uid: json[JsonKeys.uid] as! String,
                    title: json[JsonKeys.title] as! String,
                    content: json[JsonKeys.content] as! String,
                    color: color,
                    importance: importance,
                    liveTill: liveTill)
    }
    
    // Create dictionary of this Note instance
    var json: [String: Any] {
        // Result dict initialization with uid, title, content fields
        var dict: [String: Any] = [JsonKeys.uid: self.uid,
                                   JsonKeys.title: self.title,
                                   JsonKeys.content: self.content]
        // Add importance if low or high
        switch self.importance {
        case .high, .low: dict[JsonKeys.importance] = self.importance.rawValue
        default: break
        }
        // Add date if not nil
        switch self.liveTill {
        case let date?: dict[JsonKeys.liveTill] = date.timeIntervalSince1970
        default: break
        }
        // Add color if not white
        switch self.color {
        case UIColor.white: break
        default: do {
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            self.color.getRed(&r, green: &g, blue: &b, alpha: &a)
            dict[JsonKeys.color] = [JsonKeys.colorRed: r,
                               JsonKeys.colorGreen: g,
                               JsonKeys.colorBlue: b,
                               JsonKeys.colorAlpha: a]
            }
        }
        return dict
    }
}
