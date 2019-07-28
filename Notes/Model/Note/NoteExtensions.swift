//
//  NoteExtensions.swift
//  
//
//  Created by VitalyP on 19/06/2019.
//
import UIKit
import CocoaLumberjack

// Расширение для преобразования заметки в JSON и обратно
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
        static let destroyDate = "destroy_date"
    }
    
    // Create Note instance from dictionary
    static func parse(json: [String: Any]) -> Note? {
        // Check json contains required fields: uid, title, content
        let requiredFields: Set = [JsonKeys.uid, JsonKeys.title, JsonKeys.content]
        guard requiredFields.isSubset(of: json.keys) else {
            DDLogInfo("Note parse failed: no reuired fields (uid, title, content)")
            return nil
        }
        
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
        // Parse destroyDate
        var destroyDate: Date?
        switch json[JsonKeys.destroyDate] {
        case let timeInterval as TimeInterval:
            destroyDate = Date(timeIntervalSince1970: timeInterval)
        default: break
        }
        let note = Note(uid: json[JsonKeys.uid] as! String,
                        title: json[JsonKeys.title] as! String,
                        content: json[JsonKeys.content] as! String,
                        color: color,
                        importance: importance,
                        destroyDate: destroyDate)
        DDLogInfo("Note parsed: \(note)")
        return note
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
        switch self.destroyDate {
        case let date?: dict[JsonKeys.destroyDate] = date.timeIntervalSince1970
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

// Расширение для стравнения заметок
extension Note: Equatable {
    public static func == (lhs: Note, rhs: Note) -> Bool {
        guard lhs.uid == rhs.uid else {
            return false
        }
        guard lhs.title == rhs.title else {
            return false
        }
        guard lhs.content == rhs.content else {
            return false
        }
        guard lhs.color.isEqual(rhs.color) else {
            return false
        }
        guard lhs.importance == rhs.importance else {
            return false
        }
        guard lhs.destroyDate == rhs.destroyDate else {
            return false
        }
        return true
    }
}
