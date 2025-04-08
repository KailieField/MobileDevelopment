import UIKit
import CoreData

class AddProductViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var providerField: UITextField!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBAction func saveButtonTapped(_ sender: UIButton){
        let newProduct = Product(context: context)
        newProduct.id = UUID()
        newProduct.name = nameField.text
        newProduct.prodDesc = descriptionField.text
        newProduct.price = Double(priceField.text ?? "") ?? 0.0
        newProduct.provider = providerField.text
        
        do {
            try context.save()
            
            navigationController?.popViewController(animated: true)
        } catch {
            
            print("Error: \(error)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    



}
