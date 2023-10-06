//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Dmitry Markovskiy on 27.09.2023.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let buttonAction: () -> Void
}
