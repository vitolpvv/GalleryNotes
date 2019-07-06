//
//  NullableDatePicker.swift
//  Notes
//
//  Created by VitalyP on 03/07/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import UIKit

@IBDesignable
class NullableDatePicker: UIView {
    private let verticalSpacing: CGFloat = 8
    private let horizontalSpacing: CGFloat = 8
    private let dateFormatter = DateFormatter()
    
    private let switchLabel = UILabel()
    private let switcher = UISwitch()
    private let datePicker = UIDatePicker()
    
    var heightConstraint: NSLayoutConstraint?
    var date: Date? {
        set {
            switch newValue {
            case let newDate?:
                datePicker.setDate(newDate, animated: false)
                switcher.setOn(true, animated: true)
            default:
                switcher.setOn(false, animated: true)
            }
        }
        get {
            switch switcher.isOn {
            case true: return datePicker.date
            default: return nil
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    override var intrinsicContentSize: CGSize{
        let switchSize = switcher.intrinsicContentSize
        let switchLabelSize = switchLabel.intrinsicContentSize
        let datePickerSize = datePicker.intrinsicContentSize
        
        let width: CGFloat
        let height: CGFloat
        
        switch switcher.isOn {
        case true:
            width = max(switchLabelSize.width + switchSize.width + horizontalSpacing, datePickerSize.width)
            height = switchLabelSize.height + verticalSpacing + datePickerSize.height
        default:
            width = switchLabelSize.width + switchSize.width + horizontalSpacing
            height = switchSize.height
        }
        
        return CGSize(width: width, height: height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let switchSize = switcher.intrinsicContentSize
        let switchLabelSize = switchLabel.intrinsicContentSize
        let datePickerSize = datePicker.intrinsicContentSize
        
        switcher.frame = CGRect(origin: CGPoint(x: bounds.maxX - switchSize.width - 2, y: bounds.minY),
                                size: switchSize)
        switchLabel.frame = CGRect(origin: CGPoint(x: bounds.minX, y: bounds.minY + (switchSize.height - switchLabelSize.height) / 2),
                                   size: switchLabelSize)
        
        switch switcher.isOn {
        case true:
            datePicker.frame = CGRect(origin: CGPoint(x: bounds.midX - bounds.width * 0.75 / 2, y: bounds.minY + switchLabelSize.height + verticalSpacing),
                                      size: CGSize(width: bounds.width * 0.75,height: datePickerSize.height))
        default:
            datePicker.frame = .zero
        }
        
        heightConstraint?.constant = intrinsicContentSize.height
    }
    
    private func setupViews() {
        addSubview(switcher)
        addSubview(switchLabel)
        addSubview(datePicker)
        
        switcher.translatesAutoresizingMaskIntoConstraints = true
        switchLabel.translatesAutoresizingMaskIntoConstraints = true
        datePicker.translatesAutoresizingMaskIntoConstraints = true
        
        switchLabel.text = "Use Destroy Date"
        dateFormatter.dateStyle = DateFormatter.Style.medium
        datePicker.datePickerMode = UIDatePicker.Mode.date
        switcher.addTarget(self, action: #selector(switchToggle), for: .valueChanged)
    }
    
    @objc private func switchToggle() {
        setNeedsLayout()
    }
}
