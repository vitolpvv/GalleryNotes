//
//  EditNoteViewController.swift
//  Класс контроллера редактора заметки.
//
//  Работа с CoreGraphics реализована в расширении UIButton.
//
//  Created by VitalyP on 02/07/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import UIKit
import CocoaLumberjack

class EditNoteViewController: UIViewController {
    
    // Компоненты GUI
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var datePickerSwitch: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var whiteColorButton: UIButton!
    @IBOutlet weak var redColorButton: UIButton!
    @IBOutlet weak var greenColorButton: UIButton!
    @IBOutlet weak var customColorButton: UIButton!
    @IBOutlet weak var importanceSegmentedControl: UISegmentedControl!
    
    // Ограничения
    @IBOutlet weak var datePickerHeightConstraint: NSLayoutConstraint!
    
    // Заметка
    var note: Note?
    
    // Массив цветных кнопок
    private var colorButtons = [UIColor?: UIButton]()
    
    // Инициализация контроллера
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // Инициализация контроллера
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Деинициализация контроллера
    deinit {
        removeKeyboardNotificationObservers()
    }
    
    // Выполняется после загрузки представления
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorButtons[UIColor.white] = whiteColorButton
        colorButtons[UIColor.red] = redColorButton
        colorButtons[UIColor.green] = greenColorButton
        colorButtons[nil] = customColorButton
        
        // Настройка видимых границ
        setBorders()
        
        // Заполнение полей данными
        setFields()
        
        // Установка обработчиков событий клавиатуры
        setKeyboardNotificationObservers()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleTextField.becomeFirstResponder()
    }
    
    
    // Выполняется перед отображением представления
    private func setFields() {
        switch note {
        case .none: title = "New note"
        default: title = "Edit note"
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        titleTextField.text = note?.title
        contentTextView.text = note?.content
        
        if let date = note?.destroyDate {
            datePickerSwitch.isOn = true
            datePicker.date = date
            datePicker(show: true)
        }
        switch note?.color.cgColor {
        case .none, UIColor.white.cgColor: colorButtonTapped(whiteColorButton)
        case UIColor.red.cgColor: colorButtonTapped(redColorButton)
        case UIColor.green.cgColor: colorButtonTapped(greenColorButton)
        default:
            setCustomColorButtonColor((note?.color)!)
        }
        
        let importance = note?.importance ?? Note.Importance.normal
        switch importance {
        case .low: importanceSegmentedControl.selectedSegmentIndex = 0
        case .normal: importanceSegmentedControl.selectedSegmentIndex = 1
        case .high: importanceSegmentedControl.selectedSegmentIndex = 2
        }
    }
    
    // Проверка заполнения полей заголовка и содержимого заметки
    @IBAction func validateTitleAndContent(_ sender: Any) {
        if titleTextField.text?.isEmpty ?? true || contentTextView.text.isEmpty {
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    // Обработка переключателя UseDestroyDate
    @IBAction func destroyDateSwitchToggled(_ sender: UISwitch) {
        view.endEditing(true)
        datePicker(show: sender.isOn)
    }
    
    // Обработчик нажатия на цветные кнопки
    @IBAction
    private func colorButtonTapped(_ sender: UIButton) {
        // Исключение выбора последней кнопки, если цвет не выбран
        guard sender != customColorButton || customColorButton.backgroundColor != nil else {
            return
        }
        view.endEditing(true)
        colorButtons.values.filter({button in button != sender}).forEach({button in button.isSelected = false})
        sender.isSelected = true
    }
    
    // Показать ColorPicker
    @IBAction
    private func showColorPicker(_ sender: UILongPressGestureRecognizer?) {
        if sender?.state == .began {
            view.endEditing(true)
            sender?.state = .ended
            performSegue(withIdentifier: "ColorPickerSegue", sender: nil)
        }
    }
    
    // Возврат к редактору заметок
    @IBAction func unwindToEditNote(_ unwindSegue: UIStoryboardSegue) {
        if let sourceController = unwindSegue.source as? ColorPickerViewController, let color = sourceController.currentColor {
            setCustomColorButtonColor(color)
        }
    }
    
    // Подготовка данных перед сохранением заметки
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let button = sender as? UIBarButtonItem, button === saveButton {
            let uid = note?.uid
            let title = titleTextField.text ?? ""
            let content = contentTextView.text ?? ""
            let importance: Note.Importance
            switch importanceSegmentedControl.selectedSegmentIndex {
            case 0: importance = .low
            case 2: importance = .high
            default: importance = .normal
            }
            var date: Date? = nil
            if datePickerSwitch.isOn {
                date = datePicker.date
            }
            var color = colorButtons.first(where: {$1.isSelected})?.key
            if color == nil {
                color = customColorButton.backgroundColor
            }
            switch uid {
            case .none:
                note = Note(title: title,
                            content: content,
                            color: color!,
                            importance: importance,
                            destroyDate: date)
            default:
                note = Note(uid: uid!,
                            title: title,
                            content: content,
                            color: color!,
                            importance: importance,
                            destroyDate: date)
            }
        } else if segue.identifier == "ColorPickerSegue" {
            (segue.destination as! ColorPickerViewController).currentColor = customColorButton.backgroundColor
        }
    }
    
    // Установка видимых границ компонентов
    private func setBorders() {
        var borderColor = UIColor.lightGray.cgColor
        let borderWidth: CGFloat = 0.5
        let cornerRadius: CGFloat = 5.0
        
        titleTextField.layer.borderWidth = borderWidth
        titleTextField.layer.borderColor = borderColor
        titleTextField.layer.cornerRadius = cornerRadius
        
        contentTextView.layer.borderWidth = borderWidth
        contentTextView.layer.borderColor = borderColor
        contentTextView.layer.cornerRadius = cornerRadius
        
        borderColor = UIColor.black.cgColor
        
        whiteColorButton.layer.borderWidth = borderWidth
        whiteColorButton.layer.borderColor = borderColor
        redColorButton.layer.borderWidth = borderWidth
        redColorButton.layer.borderColor = borderColor
        greenColorButton.layer.borderWidth = borderWidth
        greenColorButton.layer.borderColor = borderColor
        customColorButton.layer.borderWidth = borderWidth
        customColorButton.layer.borderColor = borderColor
    }
    
    // Показать/скрыть DatePicker
    private func datePicker(show: Bool) {
        switch show {
        case true:
            datePickerHeightConstraint.constant = datePicker.intrinsicContentSize.height
        default:
            datePickerHeightConstraint.constant = 0.0
        }
        UIView.animate(withDuration: 0.5) {
            self.scrollView.layoutIfNeeded()
        }
    }
    
    // Установка цвета на кнопку выбора цвета
    private func setCustomColorButtonColor(_ color: UIColor) {
        customColorButton.backgroundColor = color
        customColorButton.setBackgroundImage(nil, for: .normal)
        colorButtonTapped(customColorButton)
    }
}

// Обработчики ввода текста
extension EditNoteViewController: UITextViewDelegate, UITextFieldDelegate {
    func textViewDidChange(_ textView: UITextView) {
        validateTitleAndContent(self)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contentTextView.becomeFirstResponder()
        return false
    }
}

// Расширение контроллера. Работа с клавиатурой.
extension EditNoteViewController {
    
    // Установка обработки тапа по пустой оласти экрана
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // Установка обработки появления/скрытия клавиатуры
    private func setKeyboardNotificationObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    // Удаление обработки появления/скрытия клавиатуры
    private func removeKeyboardNotificationObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardDidShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardDidHideNotification,
                                                  object: nil)
    }
    
    // Прячет клавиатуру
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Обработчик появления клавиатуры
    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo  else {
            return
        }
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue?)?.cgRectValue else {
            return
        }
        if(scrollView.contentInset.bottom != keyboardFrame.height) {
            scrollView.contentInset.bottom = keyboardFrame.height
        }
    }
    
    // Обработчик скрытия клавиатуры
    @objc private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset.bottom = .zero
    }
}

// Цветные кнопки.
class ColorButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if isSelected {
            let path = UIBezierPath()
            path.lineWidth = 2
            path.addArc(withCenter: CGPoint(x: rect.maxX - rect.height / 4,y: rect.minY + rect.height / 4),
                        radius: rect.height / 5,
                        startAngle: deg2rad(320),
                        endAngle: deg2rad(319),
                        clockwise: true)
            path.addLine(to: CGPoint(x: rect.maxX - rect.height / 4,
                                     y: rect.minY + rect.height / 3))
            path.addLine(to: CGPoint(x: rect.maxX - rect.height / 3,
                                     y: rect.minY + rect.height / 5))
            UIColor.black.setStroke()
            path.stroke()
        }
    }
    
    private func deg2rad(_ number: CGFloat) -> CGFloat {
        return number * .pi / 180
    }
}
