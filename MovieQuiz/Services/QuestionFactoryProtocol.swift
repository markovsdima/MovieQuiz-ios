//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Dmitry Markovskiy on 26.09.2023.
//

import Foundation

protocol QuestionFactoryProtocol {
    var delegate: QuestionFactoryDelegate? {set get}
    func requestNextQuestion()
}
