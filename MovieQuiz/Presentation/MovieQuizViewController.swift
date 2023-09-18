import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    
    private struct QuizQuestion {
        // строка с названием фильма,
        // совпадает с названием картинки афиши фильма в Assets
        let image: String
        // строка с вопросом о рейтинге фильма
        let text: String
        // булевое значение (true, false), правильный ответ на вопрос
        let isAnswerCorrect: Bool
    }
    
    // вью модель для состояния "Вопрос показан"
    struct QuizStepViewModel {
        // картинка с афишей фильма с типом UIImage
        let image: UIImage
        // вопрос о рейтинге квиза
        let question: String
        // строка с порядковым номером этого вопроса (ex. "1/10")
        let questionNumber: String
    }
    
    // для состояния "Результат квиза"
    struct QuizResultsViewModel {
        // строка с заголовком алерта
        let title: String
        // строка с текстом о количестве набранных очков
        let text: String
        // текст для кнопки алерта
        let buttonText: String
    }
    
    // переменная с индексом текущего вопроса, начальное значение 0
    // (по этому индексу будем искать вопрос в массиве, где индекс первого элемента 0, а не 1)
    private var currentQuestionIndex = 0
    
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    
    // массив вопросов
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            isAnswerCorrect: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            isAnswerCorrect: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            isAnswerCorrect: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            isAnswerCorrect: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            isAnswerCorrect: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            isAnswerCorrect: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            isAnswerCorrect: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            isAnswerCorrect: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            isAnswerCorrect: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            isAnswerCorrect: false)
    ]
    
    //IBOutlets
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // берём текущий вопрос из массива вопросов по индексу текущего вопроса
        let currentQuestion = questions[currentQuestionIndex]
        show(quiz: convert(model: currentQuestion))
        imageView.layer.cornerRadius = 20
    }
    
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
        return questionStep
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        textLabel.text = step.question
        imageView.image = step.image
        counterLabel.text = step.questionNumber
    }
    
    // приватный
    private func showAnswerResult(isCorrect: Bool) {
        // Блокируем повторные нажатия на кнопки выбора ответа
        noButton.isEnabled = false
        yesButton.isEnabled = false
        // метод красит рамку
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        if isCorrect == true {
            correctAnswers += 1
        }
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // скрываем рамку и показываем следующий вопрос
            self.imageView.layer.borderWidth = 0
            self.showNextQuestionOrResults()
            // снимаем блок после показа следующего вопроса
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true
        }
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 { // 1
            let resultViewModel = QuizResultsViewModel(
                title: "Раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(questions.count)",
                buttonText: "Сыграть еще раз")
            show(quiz: resultViewModel)
        } else { // 2
            currentQuestionIndex += 1
            // идём в состояние "Вопрос показан"
            let nextQuestion = questions[currentQuestionIndex]
            show(quiz: convert(model: nextQuestion))
        }
        
    }
    
    // приватный метод для показа результатов раунда квиза
    // принимает вью модель QuizResultsViewModel и ничего не возвращает
    private func show(quiz result: QuizResultsViewModel) {
        
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            // код, который сбрасывает игру и показывает первый вопрос
            self.correctAnswers = 0
            self.currentQuestionIndex = 0
            let startQuestion = self.questions[0]
            self.show(quiz: self.convert(model: startQuestion))
        }
        
        // добавляем в алерт кнопку
        alert.addAction(action)
        
        // показываем всплывающее окно
        self.present(alert, animated: true, completion: nil)
    }
    
    // IBActions
    @IBAction private func clickedYesButton(_ sender: Any) {
        showAnswerResult(isCorrect: questions[currentQuestionIndex].isAnswerCorrect)
    }
    
    @IBAction private func clickedNoButton(_ sender: Any) {
        showAnswerResult(isCorrect: !questions[currentQuestionIndex].isAnswerCorrect)
    }
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
