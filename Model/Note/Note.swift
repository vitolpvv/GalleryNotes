//
//  Note.swift
//  
//
//  Created by VitalyP on 18/06/2019.
//

import UIKit

public struct Note {
    public enum Importance: String {
        case low = "low"
        case normal = "normal"
        case high = "high"
    }
    
    let uid: String
    let title: String
    let content: String
    let color: UIColor
    let importance: Importance
    let destroyDate: Date?
    
    public init(uid: String = UUID().uuidString, title: String, content: String, color:UIColor = UIColor.white, importance: Importance, destroyDate: Date?) {
        self.uid = uid
        self.title = title
        self.content = content
        self.color = color
        self.importance = importance
        self.destroyDate = destroyDate
    }
    
    public var description: String {
        return "Note[uid:'\(uid)', title:'\(title)', content:'\(content)', color:\(color), importance:'\(importance)', destroyDate:\(String(describing: destroyDate))]"
    }
}
