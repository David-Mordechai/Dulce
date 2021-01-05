//
//  CustomTabBarControllerViewController.swift
//  Test
//
//  Created by admin on 11/12/2020.
//  Copyright © 2020 colman. All rights reserved.
//

import UIKit

class CustomTabBarControllerViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setText()
    }
    
    @objc func setText() {
        
        tabBar.items?[0].title = "Favorites"
        tabBar.items?[1].title = "Profile"
        tabBar.items?[2].title = "Home"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        self.selectedIndex = 4
    }
}
