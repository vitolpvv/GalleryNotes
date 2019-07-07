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

// Расширение контроллера. Прячет клавиатуру при тапе в свободной области.
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// Расширение кнопки. Рисует отметку на выбраной кнопке.
extension UIButton {
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        if isSelected {
            let path = UIBezierPath()
            path.lineWidth = 2
            path.addArc(withCenter: CGPoint(x: rect.midX + rect.width / 4,y: rect.minY + rect.width / 4),
                        radius: rect.width / 5,
                        startAngle: 0.0,
                        endAngle: 7 * CGFloat.pi / 4,
                        clockwise: true)
            path.addLine(to: CGPoint(x: rect.midX + rect.width / 4,
                                     y: rect.minY + rect.width / 3))
            path.addLine(to: CGPoint(x: rect.maxX - rect.width / 3,
                                     y: rect.minY + rect.width / 5))
            UIColor.black.setStroke()
            path.stroke()
        }
    }
}

class EditNoteViewController: UIViewController {
    
    // Компоненты GUI
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var whiteColorButton: UIButton!
    @IBOutlet weak var redColorButton: UIButton!
    @IBOutlet weak var greenColorButton: UIButton!
    @IBOutlet weak var customColorButton: UIButton!
    @IBOutlet weak var colorPickerView: ColorPickerView!
    
    // Ограничения
    @IBOutlet weak var datePickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var colorPickerViewBottomConstraint: NSLayoutConstraint!
    
    // Массив цветных кнопок
    private var colorButtons = [UIButton]()
    
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
        
        colorButtons.append(whiteColorButton)
        colorButtons.append(redColorButton)
        colorButtons.append(greenColorButton)
        colorButtons.append(customColorButton)
        
        // При загрузке выбран белый цвет
        whiteColorButton.isSelected = true
        
        // Привязка обработчика завершения выбора цвета
        colorPickerView.doneButtonHandler = colorPickerDoneHandler
        
        // Настройка видимых границ
        setBorders()
        
        // Установка обработчиков событий клавиатуры
        setKeyboardNotificationObservers()
        hideKeyboardWhenTappedAround()
    }
    
    // Обработка переключателя UseDestroyDate
    @IBAction func destroyDateSwitchToggled(_ sender: UISwitch) {
        view.endEditing(true)
        switch sender.isOn {
        case true: datePickerHeightConstraint.constant = datePicker.intrinsicContentSize.height
        default: datePickerHeightConstraint.constant = 0
        }
    }
    
    // Установка видимых границ компонентов
    private func setBorders() {
        let borderColor = UIColor.black.cgColor
        let borderWidth: CGFloat = 1.0
        let cornerRadius: CGFloat = 5.0
        
        titleTextField.layer.borderWidth = borderWidth
        titleTextField.layer.borderColor = borderColor
        titleTextField.layer.cornerRadius = cornerRadius
        
        contentTextView.layer.borderWidth = borderWidth
        contentTextView.layer.borderColor = borderColor
        contentTextView.layer.cornerRadius = cornerRadius
        
        whiteColorButton.layer.borderWidth = borderWidth
        whiteColorButton.layer.borderColor = borderColor
        redColorButton.layer.borderWidth = borderWidth
        redColorButton.layer.borderColor = borderColor
        greenColorButton.layer.borderWidth = borderWidth
        greenColorButton.layer.borderColor = borderColor
        customColorButton.layer.borderWidth = borderWidth
        customColorButton.layer.borderColor = borderColor
    }
    
    // Обработчик нажатия на цветные кнопки
    @IBAction
    private func colorButtonTapped(_ sender: UIButton) {
        // Исключение выбора последней кнопки, если цвет не выбран
        guard sender != customColorButton || colorPickerView.currentColor != nil else {
            return
        }
        colorButtons.filter({button in button != sender}).forEach({button in button.isSelected = false})
        sender.isSelected = true
    }
    
    // Показать ColorPicker
    @IBAction
    private func showColorPicker() {
        view.endEditing(true)
        scrollView.isHidden = true
        colorPickerView.isHidden = false
    }
    
    // Обработчик завершения выбора цвета
    private func colorPickerDoneHandler() {
        colorPickerView.isHidden = true
        scrollView.isHidden = false
        guard colorPickerView.currentColor != nil else {
            return
        }
        customColorButton.setBackgroundImage(nil, for: .normal)
        customColorButton.backgroundColor = colorPickerView.currentColor
        colorButtonTapped(customColorButton)
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
            colorPickerViewBottomConstraint.constant = keyboardFrame.height - self.view.safeAreaInsets.bottom
        }
    }
    
    // Обработчик скрытия клавиатуры
    @objc private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset.bottom = .zero
        colorPickerViewBottomConstraint.constant = 8
    }
}
