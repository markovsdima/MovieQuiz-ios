//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Dmitry Markovskiy on 30.10.2023.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showFinalResults(result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    func dehighlightImageBorder()
    func blockYesAndNo(buttons: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}
