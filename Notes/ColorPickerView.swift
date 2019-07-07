//
//  ColorPickerViewController.swift
//
//  Класс представления выбора цвета. Цветовая модель HSB (Hue, Saturation, Brightness).
//  Содержит представление выбранного цвета, слайдер для управления яркостью и панель для выбора тона и насыщенности.
//  Выбор подтверждается кнопкой Done.
//  Параметр doneButtonHandler позволяет передать внещний метод, который будет вызван при нажатии на кнопку Done.
//  Параметр colorMap позволяет в InterfaceBuilder задать изображение для панели выбора тона и насыщенности.
//
//  Created by VitalyP on 02/07/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import UIKit

@IBDesignable
class ColorPickerView: UIView {
    
    // Изображение для панели тона и насыщенности
    @IBInspectable
    var colorMap: UIImage? {
        didSet{
            colorPaletteView.image = colorMap
        }
    }
    
    // Вычесляемое поле получения и установки выбранного цвета
    var currentColor: UIColor? {
        set(color) {
            guard color != nil else {
                currentHue = -1.0
                currentSaturation = -1.0
                return
            }
            var brightness: CGFloat = 0.0
            color!.getHue(&currentHue, saturation: &currentSaturation, brightness: &brightness, alpha: nil)
            brightSlider.value = Float(brightness)
        }
        get {
            guard currentHue >= 0.0 && currentSaturation >= 0.0 else {
                return nil
            }
            return UIColor(hue: currentHue, saturation: currentSaturation, brightness: CGFloat(brightSlider.value), alpha: 1.0)
        }
    }
    
    // Внешний обработчик завершения выбора цвета
    var doneButtonHandler: (()->Void)?
    
    // Тон. Отрицательное, когда цвет не выбран
    private var currentHue: CGFloat = -1.0
    // Насыщенность. Отрицательое, когда цвет не выбран
    private var currentSaturation: CGFloat = -1.0 {
        didSet{
            updateColor()
        }
    }
    
    // Зазоры между компонентами GUI
    private let verticalSpace: CGFloat = 8.0
    private let horizontalSpace: CGFloat = 8.0
    
    // Компоненты GUI
    private let blackMask = UIView()
    private let colorView = UIView()
    private let brightLabel = UILabel()
    private let brightSlider = UISlider()
    private let colorPaletteView = UIImageView()
    private let doneButton = UIButton()
    
    // Инициализация представления
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    // Инициализация представления
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    // Отрисовка компонентов
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let brightLabelSize = brightLabel.intrinsicContentSize
        let brightSliderSize = brightSlider.intrinsicContentSize
        let doneButtonSize = doneButton.intrinsicContentSize
        
        colorView.frame = CGRect(origin: CGPoint(x: bounds.minX, y: bounds.minY),
                                 size: CGSize(width: (bounds.width - horizontalSpace) / 3, height: brightLabelSize.height + brightSliderSize.height + verticalSpace))
        brightLabel.frame = CGRect(origin: CGPoint(x: bounds.maxX - (bounds.width - horizontalSpace) / 3 - brightLabelSize.width / 2, y: bounds.minY),
                                size: brightLabelSize)
        brightSlider.frame = CGRect(origin: CGPoint(x: bounds.maxX - (bounds.width - horizontalSpace) / 3 * 2, y: bounds.minY + brightLabelSize.height + verticalSpace),
                                 size: CGSize(width: (bounds.width - horizontalSpace) / 3 * 2, height: brightSliderSize.height))
        let paletteRect = CGRect(origin: CGPoint(x: bounds.minX, y: bounds.minY + colorView.bounds.height + verticalSpace),
                                 size: CGSize(width: bounds.width, height: bounds.height - colorView.bounds.height - doneButtonSize.height - verticalSpace))
        colorPaletteView.frame = paletteRect
        blackMask.frame = paletteRect
        doneButton.frame = CGRect(origin: CGPoint(x: bounds.midX - doneButtonSize.width / 2, y: bounds.maxY - doneButtonSize.height), size: doneButtonSize)
    }
    
    // Инициализация компонентов
    private func setupViews() {
        addSubview(colorView)
        addSubview(brightLabel)
        addSubview(brightSlider)
        addSubview(colorPaletteView)
        addSubview(blackMask)
        addSubview(doneButton)
        
        colorView.translatesAutoresizingMaskIntoConstraints = true
        brightLabel.translatesAutoresizingMaskIntoConstraints = true
        brightSlider.translatesAutoresizingMaskIntoConstraints = true
        colorPaletteView.translatesAutoresizingMaskIntoConstraints = true
        blackMask.translatesAutoresizingMaskIntoConstraints = true
        doneButton.translatesAutoresizingMaskIntoConstraints = true
        
        // Установка видимых границ
        colorView.layer.borderWidth = 1
        colorView.layer.borderColor = UIColor.black.cgColor
        colorView.layer.cornerRadius = 10
        colorPaletteView.layer.borderColor = UIColor.black.cgColor
        colorPaletteView.layer.borderWidth = 1
        
        // Настройка слайдера и заголовка
        brightLabel.text = "Brightness"
        brightSlider.maximumValue = 1.0
        brightSlider.minimumValue = 0.0
        brightSlider.value = 1.0
        brightSlider.addTarget(self, action: #selector(brightnessChanged), for: .valueChanged)
        
        // Создание обработчика жестов
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(colorPaletteGesture(gestureRecognizer:)))
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        let touchGesture = UITapGestureRecognizer(target: self, action: #selector(colorPaletteGesture(gestureRecognizer:)))
        colorPaletteView.addGestureRecognizer(touchGesture)
        colorPaletteView.addGestureRecognizer(panGesture)
        colorPaletteView.isUserInteractionEnabled = true
        
        // Настройка маски затемнения
        blackMask.backgroundColor = UIColor.black
        blackMask.alpha = CGFloat(1 - brightSlider.value)
        blackMask.isUserInteractionEnabled = false
        
        // Настройка кнопки Done
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(doneButton.tintColor, for: .normal)
        doneButton.addTarget(self, action: #selector(onDoneTapped), for: .touchUpInside)
        
        updateColor()
    }
    
    // Обработчик изменения яркости
    @objc private func brightnessChanged() {
        blackMask.alpha = CGFloat(1 - brightSlider.value)
        updateColor()
    }
    
    // Обработчик жестов на панеле выбора тона и насыщенности
    @objc private func colorPaletteGesture(gestureRecognizer: UIGestureRecognizer) {
        let location = gestureRecognizer.location(in: colorPaletteView)
        let x = max(0, min(location.x, colorPaletteView.bounds.width))
        let y = max(0, min(location.y, colorPaletteView.bounds.height))
        currentHue = x / colorPaletteView.bounds.width
        currentSaturation = 1.0 - y / colorPaletteView.bounds.height
    }
    
    // Обновление представления текущего цвета
    @objc private func updateColor() {
        colorView.backgroundColor = currentColor
    }
    
    // Обработчик завершения выбора цвета
    @objc private func onDoneTapped() {
        doneButtonHandler?()
    }
}
