//
//  ColorPickerViewController.swift
//  Notes
//
//  Created by VitalyP on 11/07/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import UIKit

// Представление выбора цвета
class ColorPickerViewController: UIViewController {
    
    // Вычесляемое поле получения и установки выбранного цвета
    var currentColor: UIColor? {
        set(color) {
            guard color != nil else {
                currentHue = -1.0
                currentSaturation = -1.0
                currentBrightness = 1.0
                return
            }
            color!.getHue(&currentHue,
                          saturation: &currentSaturation,
                          brightness: &currentBrightness,
                          alpha: nil)
        }
        get {
            guard currentHue >= 0.0 && currentSaturation >= 0.0 else {
                return nil
            }
            return UIColor(hue: currentHue,
                           saturation: currentSaturation,
                           brightness: currentBrightness,
                           alpha: 1.0)
        }
    }
    
    var setColor: UIColor?
    
    // Тон. Отрицательное, когда цвет не выбран
    private var currentHue: CGFloat = -1.0
    
    // Насыщенность. Отрицательое, когда цвет не выбран
    private var currentSaturation: CGFloat = -1.0
    
    private var currentBrightness: CGFloat = 1.0
    
    // Компоненты GUI
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var brightSlider: UISlider!
    @IBOutlet weak var colorPaletteView: UIView!
    @IBOutlet weak var blackMask: UIView!
    @IBOutlet weak var colorPointer: UIImageView!
    @IBOutlet weak var pointerXConstraint: NSLayoutConstraint!
    @IBOutlet weak var pointerYConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let borderWidth: CGFloat = 0.5
        let borderColor = UIColor.black.cgColor
        let cornerRadius: CGFloat = 10
        colorView.layer.borderColor = borderColor
        colorView.layer.borderWidth = borderWidth
        colorView.layer.cornerRadius = cornerRadius
        
        colorPaletteView.layer.borderWidth = borderWidth
        colorPaletteView.layer.borderColor = borderColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        brightSlider.value = Float(currentBrightness)
        updateColor()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        movePointer(animated: true)
    }
    
    // Обработчик изменения яркости
    @IBAction
    private func brightnessChanged() {
        currentBrightness = CGFloat(brightSlider.value)
        updateColor()
        movePointer(animated: false)
    }
    
    // Обработчик жестов на панеле выбора тона и насыщенности
    @IBAction
    private func colorPaletteGesture(gestureRecognizer: UIGestureRecognizer) {
        let location = gestureRecognizer.location(in: colorPaletteView)
        let x = max(0, min(location.x, colorPaletteView.bounds.width))
        let y = max(0, min(location.y, colorPaletteView.bounds.height))
        currentHue = x / colorPaletteView.bounds.width
        currentSaturation = 1.0 - y / colorPaletteView.bounds.height
        updateColor()
        movePointer(animated: false)
    }
    
    // Обновление представления текущего цвета
    private func updateColor() {
        let color = currentColor
        colorView.backgroundColor = color
        blackMask.alpha = 1 - currentBrightness
    }
    
    
    // Перемещение курсора
    private func movePointer(animated: Bool) {
        guard (currentSaturation >= 0.0 && currentHue >= 0.0) else {
            colorPointer.isHidden = true
            navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }
        colorPointer.isHidden = false
        navigationItem.rightBarButtonItem?.isEnabled = true
        pointerXConstraint.constant = currentHue * colorPaletteView.frame.width + colorPointer.frame.width / 2
        pointerYConstraint.constant = (1.0 - currentSaturation) * colorPaletteView.frame.height + colorPointer.frame.height / 2
        if animated {
            UIView.animate(withDuration: 0.5) {
                self.colorPaletteView.layoutIfNeeded()
            }
        }
    }
}
