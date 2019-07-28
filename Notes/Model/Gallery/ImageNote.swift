//
//  ImageNote.swift
//  Notes
//
//  Created by VitalyP on 12/07/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import UIKit
import CocoaLumberjack

// Заметка-картинка
struct ImageNote {
    let uid: String
    let imagePath: String
    
    init(uid: String = UUID().uuidString, imagePath: String) {
        self.uid = uid
        self.imagePath = imagePath
    }
    
    public func image() -> UIImage? {
        return UIImage(contentsOfFile: imagePath)
    }
    
    public var description: String {
        return "ImageNote[uid:'\(uid)', imagePath:'\(imagePath)']"
    }
}

// Расширение для преобразование json<->ImageNote
extension ImageNote {
    enum JsonKeys {
        static let uid = "uid"
        static let imagePath = "image_path"
    }
    
    static func parse(json: [String: Any]) -> ImageNote? {
        let requiredFields: Set = [JsonKeys.uid, JsonKeys.imagePath]
        guard requiredFields.isSubset(of: json.keys) else {
            DDLogInfo("Image Note parse failed: no required fields \(requiredFields)")
            return nil
        }
        let note = ImageNote(uid: json[JsonKeys.uid] as! String,
                             imagePath: json[JsonKeys.imagePath] as! String)
        DDLogInfo("Image Note parsed: \(note)")
        return note
    }
    
    var json: [String: Any] {
        return [JsonKeys.uid: uid, JsonKeys.imagePath: imagePath]
    }
}

extension ImageNote: Equatable {
    
}
