//
//  InstructionsViewController.swift
//  KAJU
//
//  Created by Duhan Boblanlı on 22.02.2023.
//

import UIKit
import CoreData

class InstructionsViewController: UIViewController {
    
    let ColorHardDarkGreen = UIColor( red: 26/255, green: 47/255, blue: 75/255, alpha: 1) //rgb(26, 47, 75)
    let ColorDarkGreen = UIColor( red: 40/255, green: 71/255, blue: 92/255, alpha: 1) //rgb(40, 71, 92)
    let ColorGreen = UIColor( red: 47/255, green: 136/255, blue: 134/255, alpha: 1) //rgb(47, 136, 134)
    let ColorLightGreen = UIColor( red: 132/255, green: 198/255, blue: 155/255, alpha: 1) //rgb(132, 198, 155)
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let tableView = UITableView()
    var recipe: Recipe!
    var foodRecipe: FoodRecipe!
    var isSavedRecipe = false
    var instructions = [Instruction]()
    var instructionsArray = [String]()
    let instructionsButton = UIButton()
    
    let recipeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 27.0)
        label.textAlignment = .center
        label.backgroundColor = UIColor( red: 26/255, green: 47/255, blue: 75/255, alpha: 1)
        label.textColor = .white
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    //MARK: - Core Data setup
    override func viewDidLoad() {
        if foodRecipe != nil {
            isSavedRecipe = true
            setupFetchRequest()
            return
        }
        if let instructions = recipe.instructions {
            self.instructionsArray = instructions
        } else {
            presentAlert(title: "Instructions Unavailable", message: "")
        }
    }
    
    private func setupFetchRequest() {
        let fetchRequest: NSFetchRequest<Instruction> = Instruction.fetchRequest()
        let predicate = NSPredicate(format: "foodRecipe == %@", foodRecipe)
        let sortDescriptor = NSSortDescriptor(key: "stepNumber", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        if let result = try? appDelegate.persistentContainer.viewContext.fetch(fetchRequest) {
            instructions = result
            tableView.reloadData()
        }
    }
    
    //MARK: - Setup View
    override func loadView() {
        super.loadView()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = ColorHardDarkGreen
        setupInstructionButton()
        setupTableView()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        // Default cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        // Constraints
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: instructionsButton.topAnchor, constant: 0).isActive = true
        tableView.backgroundColor = ColorHardDarkGreen
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        tableView.separatorColor = ColorLightGreen
    }
    
    private func setupInstructionButton() {
        view.addSubview(instructionsButton)
        instructionsButton.translatesAutoresizingMaskIntoConstraints = false
        instructionsButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0).isActive = true
        instructionsButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 0).isActive = true
        instructionsButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor,constant: -4).isActive = true
        instructionsButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        instructionsButton.layer.cornerRadius = 11
        instructionsButton.layer.borderWidth = 0.3
        instructionsButton.setTitle("Visit Website for More", for: .normal)
        instructionsButton.setTitleColor(.white, for: .normal)
        instructionsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.5)
        instructionsButton.backgroundColor = ColorGreen
        instructionsButton.addTarget(self, action: #selector(showInstructionsAction), for: .touchUpInside)
    }
    
    // Instruction buttona basıldığında oluşacak action
    @objc func showInstructionsAction() {
        if let url = URL(string: recipe.sourceURL ?? "") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                self.presentAlert(title: "Instructions Unavailable", message: "")
            }
        } else {
            self.presentAlert(title: "Instructions Unavailable", message: "")
        }
    }
}

//MARK: - Setup TableView
extension InstructionsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSavedRecipe {
            return instructions.count
        } else {
            return instructionsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if isSavedRecipe == false {
            let instruction = instructionsArray[indexPath.row]
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont(name: "Verdana", size: 16)
            cell.textLabel?.text = "\(indexPath.row + 1). \(instruction)"
        } else {
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont(name: "Verdana", size: 16)
            cell.textLabel?.text = "\(indexPath.row + 1). \(instructions[indexPath.row].instruction!)"
        }
        cell.backgroundColor = ColorHardDarkGreen
        cell.textLabel?.textColor = .lightGray
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = InstructionsHeaderCell()
        if isSavedRecipe == false {
            headerView.ingredientsLabel.text = "☑️Instructions (\(instructionsArray.count) items)" }
        else {
            headerView.ingredientsLabel.text = "☑️Instructions (\(foodRecipe.instructions!.count) items)"
        }
        return headerView
    }
}

