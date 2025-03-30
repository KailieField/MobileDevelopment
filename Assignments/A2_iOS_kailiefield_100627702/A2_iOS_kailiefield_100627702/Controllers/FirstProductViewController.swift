
import UIKit
import CoreData

class FirstProductViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var providerLabel: UILabel!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        seedDummyProducts()
        loadFirstProduct()
    }
    func loadFirstProduct(){
        let request:NSFetchRequest<Product> = Product.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            if let product = results.first{
                
                nameLabel.text = product.name ?? "Un-named."
                descLabel.text = product.prodDesc ?? "No description."
                priceLabel.text = "$\(product.price)"
                providerLabel.text = product.provider ?? "Unknown"
                
            } else {
                nameLabel.text = "No product found."
                descLabel.text = ""
                priceLabel.text = ""
                providerLabel.text = ""
            }
            
        } catch {
            print("error: \(error)")
        }
    }
    
    func seedDummyProducts() {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        
        do {
            let count = try context.count(for: request)
            if count == 0 {
                print("🌱 No products found -- seeding dummy data...")
                
                let dummyList = [
                    ("Milk", "Fresh Dair Product", 7.09, "Canada"),
                    ("Cheese", "Aged Jalapeno Cheddar", 11.00, "Paris"),
                    ("Bread", "Sourdough Loaf", 2.99, "Netherlands"),
                    ("Eggs", "Free Range", 3.49, "Canada"),
                    ("Apples", "Red Delicious", 2.49, "New Zealand"),
                    ("Bananas", "Cavendish", 1.99, "Ecuador"),
                    ("Oranges", "Navel", 1.69, "Brazil"),
                    ("Potatoes", "Russet Burbank", 1.29, "Canada"),
                    ("Onions", "Red", 0.99, "Mexico"),
                    ("Tomatoes", "Cherry", 1.49, "Italy")
                ]
                
                for (name, desc, price, provider) in dummyList {
                    let product = Product(context: context)
                    product.id = UUID()
                    product.name = name
                    product.prodDesc = desc
                    product.price = price
                    product.provider = provider
                }
                try context.save()
            }
        } catch {
            print("Failed to seed: \(error)")
        }
    }
    
    @IBAction func viewAllTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let listVC = storyboard.instantiateViewController(withIdentifier: "ProductListVC") as! ProductViewController
        navigationController?.pushViewController(listVC, animated: true)
        
    }
}

