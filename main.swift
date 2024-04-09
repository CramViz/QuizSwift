//
//  main.swift
//  QuizSwift
//
//  Created by Vicram  on 07/04/2024.
//

import Foundation

//structure des questions du quiz
struct Question: Codable {
    var question: String
    var responses: [String]
    var correctAnswer: Int
    var category: String
    var difficulty: String
    var comment: String
}
// structure de l'utilisateur
struct UserScore: Codable {
    var userName: String
    var score: Int
    var difficultyLevel: String
}
//structure du quiz
struct QuizGame {
    var questions: [Question] = []
    var currentScore: Int = 0
    var userName: String?
    var difficultyLevel: String?
    
    init() {
        self.questions = loadQuestions() ?? []
    }
    
    //fonctions pour charger les questions
    func loadQuestions() -> [Question]? {
        let fileURL = URL(fileURLWithPath: "/Users/vicram/QuizSwift/QuizSwift/questions.json")
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let questions = try decoder.decode([Question].self, from: data)
            return questions
        } catch {
            print("Erreur lors du chargement des questions: \(error)")
            return nil
        }
    }
    
    //fonctions pour charger le score
    func loadScores() -> [UserScore] {
        let fileURL = URL(fileURLWithPath: "/Users/vicram/QuizSwift/QuizSwift/scores.json")
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let scores = try decoder.decode([UserScore].self, from: data)
            return scores
        } catch {
            print("Erreur lors du chargement des scores: \(error)")
            return []
        }
    }
    
    mutating func updateScores() {
        var scores = loadScores()
        
        // Mettre à jour ou ajouter le score de l'utilisateur actuel
        if let index = scores.firstIndex(where: { $0.userName == self.userName }) {
            scores[index].score = max(scores[index].score, currentScore) // Optionnellement, garder le meilleur score
        } else {
            scores.append(UserScore(userName: userName ?? "Anonyme", score: currentScore, difficultyLevel: difficultyLevel ?? "Inconnu"))
        }
        
        // Trier les scores par ordre décroissant
        scores.sort(by: { $0.score > $1.score })
        
        // Sauvegarder les scores mis à jour
        let fileURL = URL(fileURLWithPath: "/Users/vicram/QuizSwift/QuizSwift/scores.json")
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(scores)
            try data.write(to: fileURL)
        } catch {
            print("Erreur lors de la sauvegarde des scores: \(error)")
        }
    }
    
    mutating func displayRanking() {
        let allScores = loadScores()
        // Filtrer les scores par le niveau de difficulté choisi pour ce jeu, si votre logique de score le nécessite.
        let filteredScores = allScores.filter { $0.difficultyLevel == self.difficultyLevel }.sorted { $0.score > $1.score }
        
        print("\nClassement pour le niveau de difficulté \(self.difficultyLevel ?? "inconnu"):")
        for (index, score) in filteredScores.enumerated() {
            print("\(index + 1). \(score.userName) : \(score.score) points")
        }
        
        // Trouver le classement de l'utilisateur actuel
        if let userRank = filteredScores.firstIndex(where: { $0.userName == self.userName }) {
            let userScore = filteredScores[userRank]
            print("\nVotre classement : \(userRank + 1) / \(filteredScores.count). Score : \(userScore.score) points.")
        } else {
            print("Votre score n'a pas été trouvé dans le classement.")
        }
    }
    //fonctions pour le menu de gestions des questions
    mutating func manageQuestions() {
        var shouldContinue = true
        while shouldContinue {
            print("\nGestionnaire de Banque de Questions")
            print("1. Ajouter une question")
            print("2. Modifier une question")
            print("3. Supprimer une question")
            print("4. Revenir au menu principal")
            print("Entrez votre choix :", terminator: " ")

            if let choice = readLine(), let option = Int(choice) {
                switch option {
                    case 1:
                        addQuestion()
                    case 2:
                        modifyQuestion()
                    case 3:
                        deleteQuestion()
                    case 4:
                        shouldContinue = false
                    default:
                        print("Option invalide. Veuillez réessayer.")
                }
            }
        }
    }
    mutating func addQuestion() {
        //fonction pour ajouter des questions
        print("Entrer la nouvelle question :")
        let questionText = readLine() ?? ""
        print("Entrer les options de réponse séparées par une virgule :")
        let responses = readLine()?.split(separator: ",").map(String.init) ?? []
        print("Indiquer l'index de la bonne réponse (commençant à 0) :")
        let correctAnswer = Int(readLine() ?? "") ?? 0
        print("Catégorie :")
        let category = readLine() ?? ""
        print("Difficulté (Facile, Moyen, Difficile) :")
        let difficulty = readLine() ?? ""
        print("Commentaire sur la question :")
        let comment = readLine() ?? ""

        let newQuestion = Question(question: questionText, responses: responses, correctAnswer: correctAnswer, category: category, difficulty: difficulty, comment: comment)
        questions.append(newQuestion)
        saveQuestions()
    }
    mutating func deleteQuestion() {
        //fonctions pour supprimer des questions
        print("Voici les questions disponibles :")
        for (index, question) in questions.enumerated() {
            print("\(index): \(question.question)")
        }
        print("Quelle question souhaitez-vous supprimer ? (Indiquer l'index) :")
        let index = Int(readLine() ?? "") ?? -1
        if index >= 0 && index < questions.count {
            questions.remove(at: index)
            saveQuestions()
            print("Question supprimée.")
        } else {
            print("Index invalide.")
        }
    }

    func saveQuestions() {
        //fonction pour sauvegarder les changements
        let fileURL = URL(fileURLWithPath: "/Users/vicram/QuizSwift/QuizSwift/questions.json")
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(questions)
            try data.write(to: fileURL)
        } catch {
            print("Erreur lors de la sauvegarde des questions: \(error)")
        }
    }
    
    mutating func modifyQuestion() {
        //fonction pour modifier les questions
        print("Voici les questions disponibles :")
        for (index, question) in questions.enumerated() {
            print("\(index): \(question.question)")
        }
        print("Entrez l'index de la question à modifier :", terminator: " ")
        guard let indexStr = readLine(), let index = Int(indexStr), questions.indices.contains(index) else {
            print("Index invalide.")
            return
        }
        
        let question = questions[index]
        print("Question actuelle: \(question.question)")
        print("Entrez la nouvelle question (appuyez sur Entrée pour conserver l'ancienne) :")
        let newQuestionText = readLine()
        let finalQuestionText = newQuestionText!.isEmpty ? question.question : newQuestionText!
        
        print("Réponses actuelles: \(question.responses.joined(separator: ", "))")
        print("Entrez les nouvelles réponses séparées par une virgule (appuyez sur Entrée pour conserver les anciennes) :")
        let newResponsesStr = readLine()
        let finalResponses = newResponsesStr!.isEmpty ? question.responses : newResponsesStr!.split(separator: ",").map(String.init)
        
        print("Réponse correcte actuelle (index): \(question.correctAnswer)")
        print("Indiquez l'index de la nouvelle réponse correcte (appuyez sur Entrée pour conserver l'ancienne) :")
        let newCorrectAnswerStr = readLine()
        let finalCorrectAnswer = newCorrectAnswerStr!.isEmpty ? question.correctAnswer : Int(newCorrectAnswerStr!) ?? question.correctAnswer
        
        print("Catégorie actuelle: \(question.category)")
        print("Entrez la nouvelle catégorie (appuyez sur Entrée pour conserver l'ancienne) :")
        let newCategory = readLine()
        let finalCategory = newCategory!.isEmpty ? question.category : newCategory!
        
        print("Difficulté actuelle: \(question.difficulty)")
        print("Entrez la nouvelle difficulté (Facile, Moyen, Difficile) (appuyez sur Entrée pour conserver l'ancienne) :")
        let newDifficulty = readLine()
        let finalDifficulty = newDifficulty!.isEmpty ? question.difficulty : newDifficulty!
        
        print("Commentaire actuel: \(question.comment)")
        print("Entrez le nouveau commentaire (appuyez sur Entrée pour conserver l'ancien) :")
        let newComment = readLine()
        let finalComment = newComment!.isEmpty ? question.comment : newComment!
        
        // Mise à jour de la question
        questions[index] = Question(question: finalQuestionText, responses: finalResponses, correctAnswer: finalCorrectAnswer, category: finalCategory, difficulty: finalDifficulty, comment: finalComment)
        
        // Sauvegarde des modifications
        saveQuestions()
        print("Question modifiée avec succès.")
    }
    
    mutating func showMainMenu() {
        //fonction pour afficher le menu principal
        var shouldContinue = true
        while shouldContinue {
            print("\nMenu Principal")
            print("1. Jouer au Quiz")
            print("2. Gérer les Questions")
            print("3. Quitter")
            print("Entrez votre choix :", terminator: " ")
            
            if let choice = readLine(), let option = Int(choice) {
                switch option {
                case 1:
                    start()
                case 2:
                    manageQuestions()
                case 3:
                    shouldContinue = false
                    print("Merci d'avoir utilisé QuizSwift. À bientôt !")
                default:
                    print("Option invalide. Veuillez réessayer.")
                }
            }
        }
    }
    
    mutating func start() {
        //fonction pour lancer le jeu
        currentScore = 0
        print("Bienvenue dans le CarQuiz! Connaissez-vous autant l'automobile que vous le croyez?")
        
        // Saisie du nom de l'utilisateur
        print("Veuillez entrer votre nom :", terminator: " ")
        userName = readLine()
        
        // Sélection du niveau de difficulté
        var isValidDifficulty = false
        while !isValidDifficulty {
            print("Choisissez un niveau de difficulté - Facile, Moyen, Difficile :", terminator: " ")
            if let input = readLine(), ["facile", "moyen", "difficile"].contains(input.lowercased()) {
                difficultyLevel = input
                isValidDifficulty = true
            } else {
                print("Entrée invalide. Veuillez choisir entre Facile, Moyen, Difficile.")
            }
        }
        
        // Filtrer et mélanger les questions en fonction du niveau de difficulté
        let filteredQuestions = questions.filter { $0.difficulty.lowercased() == difficultyLevel?.lowercased() }.shuffled()
        
        guard !filteredQuestions.isEmpty else {
            print("Aucune question disponible pour le niveau de difficulté choisi.")
            return
        }
        
        for (index, question) in filteredQuestions.enumerated() {
            print("\nQuestion \(index + 1)/\(filteredQuestions.count): \(question.question)")
            for (i, response) in question.responses.enumerated() {
                print("  \(i+1). \(response)")
            }

            let startTime = Date()
            var userAnswer: Int? = nil
            var answerTime: TimeInterval = 0
            let timeout: TimeInterval = 30 // 30 secondes pour répondre
            
            print("Vous avez 30 secondes pour répondre.")
            print("Entrez le numéro de votre réponse (1-4) :", terminator: " ")
            
            while userAnswer == nil && answerTime < timeout {
                if let userInput = readLine(strippingNewline: true) {
                    let endTime = Date()
                    answerTime = endTime.timeIntervalSince(startTime)
                    
                    if let userAnswerInput = Int(userInput), userAnswerInput >= 1, userAnswerInput <= question.responses.count {
                        userAnswer = userAnswerInput - 1 // Ajuster pour l'index basé sur zéro
                        break // Sortir de la boucle après avoir reçu une réponse valide
                    } else {
                        print("Réponse invalide. Veuillez entrer un nombre entre 1 et \(question.responses.count).")
                    }
                }
                
                let currentTime = Date()
                answerTime = currentTime.timeIntervalSince(startTime)
            }

            // Gérer la réponse ou le timeout
            if answerTime >= timeout {
                print("Temps écoulé ! La réponse correcte était \(question.responses[question.correctAnswer]).")
            } else if userAnswer == question.correctAnswer {
                print("Bonne réponse!")
                currentScore += 1
                if answerTime <= 5 {
                    print("Réponse rapide ! Vous recevez un point bonus.")
                    currentScore += 1 // Accorder un point bonus
                }
            } else {
                print("Mauvaise réponse! La bonne réponse était \(question.responses[question.correctAnswer]).")
            }
            
            print("À savoir : \(question.comment)\n")
            print("Votre score actuel est de \(currentScore) sur \(index + 1).")
        }
        
        print("\nJeu terminé, \(userName ?? "Joueur")! Votre score final est de \(currentScore)/\(filteredQuestions.count).")
        if currentScore == filteredQuestions.count {
            print("Incroyable ! Vous avez répondu correctement à toutes les questions !")
        } else if currentScore > filteredQuestions.count / 2 {
            print("Bien joué ! Vous avez plus de la moitié des réponses correctes.")
        } else {
            print("Pas mal, mais vous pouvez faire mieux. Pourquoi ne pas essayer à nouveau ?")
        }
        updateScores()
        displayRanking()
    }
}
    
var game = QuizGame()
game.showMainMenu()

