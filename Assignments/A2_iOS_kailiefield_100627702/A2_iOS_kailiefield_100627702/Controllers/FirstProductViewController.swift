
import UIKit
import CoreData

class FirstProductViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var providerLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var products: [Product] = []
    var filteredProducts: [Product] = []
    var currentIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        seedDummyProducts()
        fetchProducts()
        showProduct(at: currentIndex)
//        loadFirstProduct()
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
    func fetchProducts(){
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        do{
            products = try context.fetch(request)
            filteredProducts = products
        } catch {
            print("Error fetching products: \(error)")
        }
    }
    
    func showProduct(at index: Int) {
        guard filteredProducts.indices.contains(index) else {
            nameLabel.text = "Index out of bounds."
            descLabel.text = ""
            priceLabel.text = ""
            providerLabel.text = ""
            return
        }
        
        let product = filteredProducts[index]
        nameLabel.text = product.name ?? "Un-named."
        descLabel.text = product.prodDesc ?? "No Description."
        priceLabel.text = ("$\(product.price)")
        providerLabel.text = product.provider ?? "Unknown"
        
        prevButton.isEnabled = index > 0
        nextButton.isEnabled = index < filteredProducts.count - 1
    }
    
    @IBAction func previousTapped(_ sender: UIButton) {
        if currentIndex > 0 {
            currentIndex -= 1
            showProduct(at: currentIndex)
        }
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        if currentIndex < filteredProducts.count - 1 {
            currentIndex += 1
            showProduct(at: currentIndex)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if searchText.isEmpty {
            filteredProducts = products
        } else {
            filteredProducts = products.filter {
                ($0.name?.lowercased().contains(searchText.lowercased()) ?? false) || ($0.prodDesc?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
        
        currentIndex = 0
        showProduct(at: currentIndex)
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

