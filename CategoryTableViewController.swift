//
//  CategoryTableViewController.swift
//  What To Do
//
//  Created by Calwin on 05/09/24.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    
    var categories = [Category]()
    
    let context=(UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        category.textLabel?.text=categories[indexPath.row].title
        return category
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToToDo", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC=segue.destination as! ToDoListViewController
        if let indexpath=tableView.indexPathForSelectedRow{
            destVC.selectedCategory=categories[indexpath.row]
        }
    }
    
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        var textField=UITextField()
        let alert=UIAlertController(title: "Add a new category", message: "", preferredStyle: .alert)
        let action=UIAlertAction(title: "Add category", style: .default){(action) in
            let newCategory = Category(context: self.context)
            newCategory.title=textField.text!
            self.categories.append(newCategory)
            self.save()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder="Enter a category"
            textField=alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func save(){
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    
    func load(with request: NSFetchRequest<Category> = Category.fetchRequest()){
        do{
            categories = try context.fetch(request)
        }catch{
            print(error)
        }
        tableView.reloadData()
    }
}
