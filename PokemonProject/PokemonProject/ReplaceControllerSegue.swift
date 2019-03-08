//
//  ReplaceControllerSegue.swift
//  PokemonProject
//
//  Created by user147489 on 12/8/18.
//  Copyright © 2018 Rathin Chopra. All rights reserved.
//

import UIKit

class ReplaceControllerSegue: UIStoryboardSegue {
    override func perform() {
        if let navigationController = source.navigationController as UINavigationController? {
            var controllers = navigationController.viewControllers
            controllers.removeLast()
            controllers.append(destination)
            navigationController.setViewControllers(controllers, animated: true)
        }
    }
}
