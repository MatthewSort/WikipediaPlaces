//
//  MockUIApplication.swift
//  WikipediaPlacesTests
//
//  Created by Mattia Capasso on 29/08/2024.
//

import UIKit
import Foundation
@testable import WikipediaPlaces

final class MockUIApplication: UIApplicationServing {
    var openedURL: URL?
    var shouldOpenURL: Bool = true
    
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: ((Bool) -> Void)?) {
        self.openedURL = url
        completion?(shouldOpenURL)
    }
}
