//
//  TabBarController.swift
//  iTunesAPITest
//
//  Created by Илья Москалев on 25.09.2021.
//

import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let viewController1 = ModuleBuilder.createSearchModule()
        let viewController2 = ModuleBuilder.createHistoryModule()

        viewControllers = [
            createTabBarItem(tabBarTitle: "Search", tabBarImage: "magnifyingglass",
                             navBarTitle: "Search", viewController: viewController1),
            createTabBarItem(tabBarTitle: "History", tabBarImage: "book.circle",
                             navBarTitle: "History", viewController: viewController2)
        ]
        setupTabBarColors()
    }

    private func setupTabBarColors() {
        tabBar.isTranslucent = true
    }

    private func createTabBarItem(tabBarTitle: String, tabBarImage: String,
                                  navBarTitle: String, viewController: UIViewController) -> UINavigationController {

        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.title = tabBarTitle
        navController.tabBarItem.image = UIImage(systemName: tabBarImage)

        // Nav Bar Customisation
        navController.navigationBar.isTranslucent = true
        viewController.title = navBarTitle
        return navController
    }
}
