//
//  UIApplicationServing.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 29/08/2024.
//

import UIKit

protocol UIApplicationServing {
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: ((Bool) -> Void)?)
}

extension UIApplication: UIApplicationServing {}
