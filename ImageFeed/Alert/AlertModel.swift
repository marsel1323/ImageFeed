//
//  AlertModel.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 20.12.2024.
//

import Foundation

public struct AlertModel {
    let title: String
    let message: String?
    let buttons: [(title: String, completion: (() -> Void)?)]
}
