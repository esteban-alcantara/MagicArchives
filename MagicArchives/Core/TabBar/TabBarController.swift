//
//  TabBarController.swift
//  MagicArchives
//
//  Created by Daniel Esteban Alcantara on 19/11/26.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    func setUpViews(){
        
        //MARK: Records View
        //Instanciamos El viewController
        let recordsViewController = RecordsViewController()
        //Embebemos el viewController en un navigation Controller
        let recordsNavigation = UINavigationController(rootViewController: recordsViewController)
        recordsNavigation.tabBarItem.title = "Expedientes"
        recordsNavigation.tabBarItem.image = UIImage(systemName: "person.text.rectangle")
        recordsNavigation.tabBarItem.selectedImage = UIImage(systemName: "person.text.rectangle.fill")
        
        
        //MARK: Archive View
        //Instanciamos El viewController
        let archiveViewController = ArchiveViewController()
        //Embebemos el viewController en un navigation Controller
        let archiveNavigation = UINavigationController(rootViewController: archiveViewController)
        archiveNavigation.tabBarItem.title = "Archivo"
        archiveNavigation.tabBarItem.image = UIImage(systemName: "archivebox")
        archiveNavigation.tabBarItem.selectedImage = UIImage(systemName: "archivebox.fill")
        
        //MARK: Saves View
        //Instanciamos El viewController
        let savesViewController = SavesViewController()
        //Embebemos el viewController en un navigation Controller
        let savesNavigation = UINavigationController(rootViewController: savesViewController)
        savesNavigation.tabBarItem.title = "Guardados"
        savesNavigation.tabBarItem.image = UIImage(systemName: "wand.and.sparkles")
        savesNavigation.tabBarItem.selectedImage = UIImage(systemName: "wand.and.sparkles.inverse")
        
        
        //MARK: ViewControllers ARRAY
        let viewControllers: [UIViewController] = [recordsNavigation, archiveNavigation, savesNavigation]
        self.viewControllers = viewControllers
        self.selectedIndex = 0
    }
    
    

}
