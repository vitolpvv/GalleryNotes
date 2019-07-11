//
//  StaticNotebook.swift
//  Notes
//
//  Created by VitalyP on 10/07/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import Foundation

class StaticNotebook {
    public private(set) var notes = [Note]()
    
    init() {
        notes.append(Note(uid: "1", title: "Note 1", content: "При старте приложения видим экран, в котором можно ввести имя пользователя и кнопка «Log in».\nПосле нажатия кнопки показать экран с двумя закладками. В основе экрана UITabBarController.\nНа первой закладке выводится «Привет, <имя>» (UILabel).\nВторая закладка позволяет редактировать это имя через клавиатуру (UITextField). Кнопкой «Return» на клавиатуре подтверждаем изменение имени и прячем клавиатуру. Отредактированное имя автоматически обновляется на первой закладке", color: .red, importance: .normal, destroyDate: Date()))
        notes.append(Note(title: "Note2", content: "Content 2", importance: .normal, destroyDate: nil))
        notes.append(Note(title: "Note 3", content: "Content 3", importance: .normal, destroyDate: nil))
        notes.append(Note(title: "Note 4", content: "Content 4", importance: .normal, destroyDate: nil))
        notes.append(Note(title: "Note 5", content: "Content 5", importance: .normal, destroyDate: nil))
        notes.append(Note(title: "Note 6", content: "Content 6", importance: .normal, destroyDate: nil))
        notes.append(Note(title: "Note 7", content: "Content 7", importance: .normal, destroyDate: nil))
    }
    
    public func add(_ note: Note) {
        switch (notes.firstIndex(where: { $0.uid == note.uid })) {
        case let index?:
            notes[index] = note
        case .none:
            notes.append(note)
        }
    }
    
    public func index(of note: Note) -> Int? {
        return notes.firstIndex(where: { $0.uid == note.uid })
    }
    
    public func remove(with uid: String) {
        notes.removeAll(where: { $0.uid == uid })
    }
    
    public func remove(with index: Int) {
        notes.remove(at: index)
    }
}
