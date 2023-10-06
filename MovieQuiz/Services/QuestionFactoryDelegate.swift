//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Dmitry Markovskiy on 26.09.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
