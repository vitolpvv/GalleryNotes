//
//  EditNoteViewController.swift
//  Notes
//
//  Created by VitalyP on 02/07/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import UIKit

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

class EditNoteViewController: UIViewController {
    
    // Компоненты GUI
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var colorPickerButton: UIImageView!
    @IBOutlet weak var colorPickerView: ColorPickerView!
    
    // Ограничения
    @IBOutlet weak var datePickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var colorPickerViewBottomConstraint: NSLayoutConstraint!
    
    // Инициализация контроллера
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setKeyboardNotificationObservers()
        hideKeyboardWhenTappedAround()
    }
    
    // Инициализация контроллера
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setKeyboardNotificationObservers()
        hideKeyboardWhenTappedAround()
    }
    
    // Деинициализация контроллера
    deinit {
        removeKeyboardNotificationObservers()
    }
    
    // Выполняется после загрузки представления
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBorders()
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(showColorPicker))
        longGesture.minimumPressDuration = 1
        colorPickerButton.isUserInteractionEnabled = true
        colorPickerButton.addGestureRecognizer(longGesture)
//        colorPickerButton.isSelected = true
        
        colorPickerView.doneButtonHandler = colorPickerDoneHandler
    }
    
    // Обработка переключателя UseDestroyDate
    @IBAction func destroyDateSwitchToggled(_ sender: UISwitch) {
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
        
        colorPickerButton.layer.borderWidth = borderWidth
        colorPickerButton.layer.borderColor = borderColor
    }
    
    // Обработка появления/скрытия клавиатуры
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
    
    // Показать выбор цвета
    @objc private func showColorPicker() {
        colorPickerView.isHidden = false
    }
    
    // Обработчик завершения выбора цвета
    private func colorPickerDoneHandler() {
        colorPickerView.isHidden = true
        colorPickerButton.image = nil
        colorPickerButton.backgroundColor = colorPickerView.currentColor
    }
}

//@IBDesignable
//class SelectableView: UIImageView{
//    
//    var isSelected: Bool = false {
//        didSet{
//            setNeedsDisplay()
//        }
//    }
//    
//    override func draw(_ rect: CGRect) {
//        if isSelected {
//            let context = UIGraphicsGetCurrentContext()!
//            context.setStrokeColor(UIColor.white.cgColor)
//            context.setFillColor(UIColor.black.cgColor)
//            context.addArc(center: CGPoint(x: rect.midX + rect.width / 4, y: rect.minY + rect.width / 4), radius: rect.width / 4, startAngle: 0, endAngle: 315, clockwise: true)
//            context.addLine(to: CGPoint(x: rect.midX + rect.width / 4, y: rect.minY + rect.width / 4))
//        }
//    }
//}
