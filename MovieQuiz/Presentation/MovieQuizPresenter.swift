//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Dmitry Markovskiy on 29.10.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private let statisticService: StatisticService!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var alertPresenter: AlertPresenter?
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var currentQuestion: QuizQuestion?
    private var correctAnswers: Int = 0
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImpl()
        
        questionFactory = QuestionFactoryImpl(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func restartAndReload() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.loadData()
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func clickedYesButton() {
        didAnswer(isYes: true)
    }
    
    func clickedNoButton() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        self.showAnswerResult(isCorrect: givenAnswer == currentQuestion.isAnswerCorrect)
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: self.makeResultMessage(),
                buttonText: "Сыграть еще раз")
            
            viewController?.showFinalResults(result: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
        
    }
    
    func showAnswerResult(isCorrect: Bool) {
        // Блокируем повторные нажатия на кнопки выбора ответа
        viewController?.blockYesAndNo(buttons: true)
        
        didAnswer(isCorrectAnswer: isCorrect)
        // метод красит рамку
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            // скрываем рамку и показываем следующий вопрос
            self.viewController?.dehighlightImageBorder()
            self.showNextQuestionOrResults()
            // снимаем блок после показа следующего вопроса
            viewController?.blockYesAndNo(buttons: false)
        }
    }
    
    private func makeResultMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        guard let bestGame = statisticService.bestGame else {
            assertionFailure("error")
            return ""
        }
        
        let resultMessage =
        """
        Ваш результат: \(correctAnswers)/\(self.questionsAmount)
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
        """
        
        return resultMessage
    }
    
}
