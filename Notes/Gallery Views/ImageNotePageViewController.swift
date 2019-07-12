//
//  ImageNotePageViewController.swift
//  Notes
//
//  Created by VitalyP on 12/07/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import UIKit

// Листалка
class ImageNotePageViewController: UIPageViewController {
    
    var gallery: FileGallery?
    var index: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        setViewControllers([viewController(for: index)], direction: .forward, animated: true, completion: nil)
    }
    
    
    // Создает представление для элемента коллекции
    private func viewController(for index: Int) -> UIViewController {
        let controller = ImageNoteViewController(nibName: "ImageNoteViewController", bundle: nil)
        controller.index = index
        controller.image = gallery?.imageNotes[index].image()
        return controller
    }
}

// Расширение для организации перелистования по коллекции
extension ImageNotePageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let controller = viewController as! ImageNoteViewController
        guard controller.index > 0 else {
            return nil
        }
        return self.viewController(for: controller.index - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let controller = viewController as! ImageNoteViewController
        guard controller.index < (gallery?.imageNotes.count)! - 1 else {
            return nil
        }
        return self.viewController(for: controller.index + 1)
    }
}
