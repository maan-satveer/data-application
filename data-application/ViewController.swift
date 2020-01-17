//
//  ViewController.swift
//  data-application
//
//  Created by MacStudent on 2020-01-16.
//  Copyright © 2020 MacStudent. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    var books:[Book]?
    @IBOutlet var textfield: [UITextField]!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
      //  loaddata()
        loadCoreData()
     
       NotificationCenter.default.addObserver(self, selector: #selector(saveCoreData), name: UIApplication.willResignActiveNotification, object: nil)
        
    }
    func getFilePath() -> String{
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if documentPath.count > 0 {
            let documentDirectory = documentPath[0]
            let filePath = documentDirectory.appending("/data.txt")
            return filePath
        }
        return ""
    }
    func  loaddata(){
        let filepath = getFilePath()
        books = [Book]()
        if FileManager.default.fileExists(atPath: filepath){
            do {
                // extract data
                let fileContents = try String(contentsOfFile: filepath)
                let contentArray = fileContents.components(separatedBy: "\n")
                for content in contentArray{
                    let bookContent = content.components(separatedBy: ",")
                    if bookContent.count == 4{
                        let book = Book(title: bookContent[0], author: bookContent[1], pages: Int(bookContent[2])!, year: Int(bookContent[3])!)
                        books?.append(book)
                    }
                }
                
            }catch {
                print("error")
            }
        }
    }
    
   @IBAction func addbook(_ sender: UIBarButtonItem) {
        let title = textfield[0].text ?? ""
          let author = textfield[1].text ?? ""
           let pages = Int(textfield[2].text ?? "0") ?? 0
           let year = Int(textfield[3].text ?? "2020") ?? 2020
        let book = Book(title: title, author: author, pages: pages, year: year)
        books?.append(book)
        for textfield in textfield{
            textfield.text = ""
            textfield.resignFirstResponder()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let BookTable = segue.destination as? BookTableViewController{
            BookTable.books = self.books
        }
    }
  @objc  func saveData(){
        let filePath = getFilePath()
        var saveString = ""
        for book in books!{
            saveString = "\(saveString)\(book.title),\(book.author),\(book.pages),\(book.year)\n"
        }
        // write to path
        do{
            try saveString.write(toFile: filePath, atomically: true, encoding: .utf8)
        }catch{
            print("error")
        }
    }
  @objc   func saveCoreData(){
        //call clear core data
        clearCoreData()
        // create an instance of app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // second step is context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        for book in books! {
            let bookEntity = NSEntityDescription.insertNewObject(forEntityName: "Bookmodel", into: managedContext)
            bookEntity.setValue(book.title, forKey: "title")
            bookEntity.setValue(book.author, forKey: "author")
            bookEntity.setValue(book.pages, forKey: "pages")
            bookEntity.setValue(book.year, forKey: "year")
            // save data
            do{
                try managedContext.save()
            }
            catch{
                print("error")
            }
        }
        
    }
    func loadCoreData(){
        books = [Book]()
        // create an instance of app delegate
               let appDelegate = UIApplication.shared.delegate as! AppDelegate
               // second step is context
               let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bookmodel")
        do{
            let results = try  managedContext.fetch(fetchRequest)
            if results is [NSManagedObject]{
                for result in results as! [NSManagedObject]{
                    let title = result.value(forKey: "title") as! String
                    let author = result.value(forKey: "author") as! String
                    let pages = result.value(forKey: "pages") as! Int
                    let year = result.value(forKey: "year") as! Int
                    books?.append(Book(title: title, author: author, pages: pages, year: year))
                }
            }
            
        }catch{
            print("error")
        }
        
    }
    func clearCoreData(){
        // create an instance of app delegate
                      let appDelegate = UIApplication.shared.delegate as! AppDelegate
                      // second step is context
                      let managedContext = appDelegate.persistentContainer.viewContext
        //  create fetch request
               let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bookmodel")
        fetchRequest.returnsObjectsAsFaults = false
        do{
            let results = try managedContext.fetch(fetchRequest)
            for managedObjects in results {
                if let managedObjectData = managedObjects as? NSManagedObject{
                    managedContext.delete(managedObjectData)
                }
                
            }
            
        }catch {
            print("error")
        }
        
    }
    
}

