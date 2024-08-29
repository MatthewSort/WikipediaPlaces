//
//  CustomAlert.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 29/08/2024.
//

import SwiftUI

struct CustomAlertContent {
    var title: String
    var message: String?
    var primaryButton: Alert.Button
    var secondaryButton: Alert.Button?
    
    static let empty = CustomAlertContent(title: "", primaryButton: .default(.init("")))
}

extension View {
    func customAlert(
        alertContent: Binding<CustomAlertContent>,
        isPresented: Binding<Bool>
    ) -> some View {
        self.alert(
            isPresented: isPresented,
            content: {
                let alert = alertContent.wrappedValue
                let message = alert.message != nil ? Text(alert.message ?? "") : nil
                
                if let secondaryButton = alert.secondaryButton {
                    return Alert(
                        title: Text(alert.title),
                        message: message,
                        primaryButton: alert.primaryButton,
                        secondaryButton: secondaryButton
                    )
                } else {
                    return Alert(
                        title: Text(alert.title),
                        message: message,
                        dismissButton: alert.primaryButton
                    )
                }
            }
        )
    }
}
