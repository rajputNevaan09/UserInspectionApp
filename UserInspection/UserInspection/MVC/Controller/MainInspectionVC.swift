//
//  MainInspectionVC.swift
//  UserInspection
//
//  Created by Bhagwan Rajput on 07/06/24.
//

import UIKit

class MainInspectionVC: UIViewController {
    
    var inspection: InspectionResponse?
    var answers: [Int: Int] = [:] // Dictionary to store question ID and selected answer ID
    let tableView = UITableView()
    
    @IBOutlet weak var vwMain: UIView!
    let customNavBar = UIView()
    let titleLabel = UILabel()
    let backButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupCustomNavBar()
        setupTableView()
        //loadPartialInspection()
        fetchInspectionData()
    }
    private func setupCustomNavBar() {
        customNavBar.backgroundColor = .white
        view.addSubview(customNavBar)
        
        customNavBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        titleLabel.text = "Inspection"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        customNavBar.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: customNavBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor)
        ])
        
        backButton.setTitle("<< Back", for: .normal)
        backButton.setTitleColor(.black, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        customNavBar.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: customNavBar.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor)
        ])
    }
    
    //MARK: on back asking for confrimation (Submit or Back)
    func presentAlert() {
        // Create the alert controller
        let alert = UIAlertController(title: "Inspection Alert", message: "Do you want to submit your response ?", preferredStyle: .alert)
        
        // Add the first action (Button 1)
        let action1 = UIAlertAction(title: "SUBMIT", style: .default) { (action) in
            // Code to execute when SUBMIT is tapped
            self.callSubmitAPI()
            print("SUBMIT Button tapped")
        }
        alert.addAction(action1)
        
        // Add the second action (Button 2)
        let action2 = UIAlertAction(title: "NO", style: .default) { (action) in
            // Code to execute when Button 2 is tapped
            self.navigationController?.popViewController(animated: true)
            print("Back Button tapped")
        }
        alert.addAction(action2)
        
        // Present the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: Action for back button to navigate on login and signup
    @objc private func backButtonTapped() {
        presentAlert()
    }
    
    
    func callSubmitAPI() {
        
        guard let inspection = inspection else {
            print("Inspection data is not available")
            return
        }
        
        let inspectionRequest = InspectionResponse(inspection: inspection.inspection)
        
        // Create an instance of NetworkManager
        let networkManager = NetworkManager()
        
        // Call the submitInspection method using the instance
        networkManager.submitInspection(inspectionRequest) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.showAlertMain(message: "Inspection submitted successfully")
                    self.coreDataSave()
                    print(response)
                case .failure(let error):
                    self.showAlertMain(message: "Failed to submit inspection")
                    print(error)
                }
            }
        }
    }
    
    func coreDataSave() {
        guard let inspection = inspection else {
                    print("Inspection data is not available")
                    return
                }
                
                // Save inspection as draft
                DataManager.shared.saveInspection(inspection: inspection, state: "draft")
                
                // Fetch and print all inspections
                let inspections = DataManager.shared.fetchInspections()
                for inspection in inspections {
                    print("Fetched Inspection: \(inspection)")
                }
    }
    
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Set custom table view background color
        let customColor = UIColor(red: 148.0/255.0, green: 33.0/255.0, blue: 147.0/255.0, alpha: 1.0)
        tableView.backgroundColor = customColor
        tableView.separatorInset = .zero
        tableView.separatorColor = .black
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(submitInspection))
    }
    
    private func fetchInspectionData() {
        NetworkManager.shared.fetchInspectionData { [weak self] result in
            switch result {
            case .success(let inspectionResponse):
                self?.inspection = inspectionResponse
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error fetching data: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func submitInspection() {
        // Calculate and display the final inspection score
        guard let inspection = inspection else { return }
        
        var totalScore: Double = 0
        var answeredQuestions = 0
        
        for category in inspection.inspection.survey.categories {
            for question in category.questions {
                if let selectedAnswerId = answers[question.id],
                   let answer = question.answerChoices.first(where: { $0.id == selectedAnswerId }) {
                    totalScore += answer.score
                    answeredQuestions += 1
                }
            }
        }
        
        let alert = UIAlertController(title: "Inspection Submitted", message: "Final Score: \(totalScore)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
        // Clear partial inspection after submission
        UserDefaults.standard.removeObject(forKey: "partialInspection")
    }
    // To show alert
    func showAlertMain(message: String) {
        let alertController = UIAlertController(title: "User Inspection", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
}
extension MainInspectionVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return inspection?.inspection.survey.categories.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inspection?.inspection.survey.categories[section].questions.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let customColor = UIColor(red: 148.0/255.0, green: 33.0/255.0, blue: 147.0/255.0, alpha: 1.0)
        cell.backgroundColor = customColor
        let question = inspection!.inspection.survey.categories[indexPath.section].questions[indexPath.row]
        cell.textLabel?.text = question.name
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.text = nil // Add this line if using .subtitle style
        if let selectedAnswerId = answers[question.id],
           let answer = question.answerChoices.first(where: { $0.id == selectedAnswerId }) {
            cell.detailTextLabel?.text = answer.name
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
}

extension MainInspectionVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let question = inspection!.inspection.survey.categories[indexPath.section].questions[indexPath.row]
        let alert = UIAlertController(title: question.name, message: nil, preferredStyle: .actionSheet)
        
        for choice in question.answerChoices {
            let action = UIAlertAction(title: choice.name, style: .default) { [weak self] _ in
                self?.answers[question.id] = choice.id
                tableView.reloadRows(at: [indexPath], with: .automatic)
                //                DataBaseHelper.saveInspection(question)
            }
            
            // Check if this choice is the selected answer and add a checkmark
            if answers[question.id] == choice.id {
                action.setValue(true, forKey: "checked")
            }
            
            alert.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
}

extension Dictionary {
    func mapKeys<TransformedKey>(_ transform: (Key) -> TransformedKey) -> [TransformedKey: Value] {
        return Dictionary<TransformedKey, Value>(uniqueKeysWithValues: map { (transform($0.key), $0.value) })
    }
}
