//
//  ViewController.swift
//  ToDos
//
//  Created by Calwin on 04/09/24.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController{
    
    var tasks=[Task]()
    
    let context=(UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory: Category? {
        didSet{
            load()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task=tableView.dequeueReusableCell(withIdentifier: "Task", for: indexPath)
        task.textLabel?.text=tasks[indexPath.row].name
        if tasks[indexPath.row].isDone{
            task.accessoryType = .checkmark
        }
        else{
            task.accessoryType = .none
        }
        return task
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tasks[indexPath.row].isDone = !tasks[indexPath.row].isDone
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    @IBAction func addTaskBtnPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert=UIAlertController(title: "Add a new Task", message: "", preferredStyle: .alert)
        let action=UIAlertAction(title: "Add Task", style: .default){(action) in
            let newTask = Task(context: self.context)
            newTask.name=textField.text!
            newTask.parentCategory=self.selectedCategory
            self.tasks.append(newTask)
            self.saveItems()
        }
        alert.addTextField{(alertTextField) in
            alertTextField.placeholder="Enter a task"
            textField=alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    func saveItems() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func load(with request: NSFetchRequest<Task> = Task.fetchRequest(),predicate: NSPredicate? = nil)
    {
        let categoryPredicate=NSPredicate(format: "parentCategory.title MATCHES %@", (selectedCategory?.title)!)
        if let additinalPredicate=predicate{
            let compoundPredicate=NSCompoundPredicate(andPredicateWithSubpredicates: [additinalPredicate, categoryPredicate])
            request.predicate=compoundPredicate
        }
        else{
            request.predicate=categoryPredicate
        }
        do{
            tasks = try context.fetch(request)
        }catch{
            print(error)
        }
        tableView.reloadData()
    }
}

extension ToDoListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Task>=Task.fetchRequest()
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        load(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count==0{
            load()
            DispatchQueue.main.async{
                searchBar.resignFirstResponder()
            }
        }
    }
}
