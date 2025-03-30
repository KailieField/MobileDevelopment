
import UIKit
import CoreData

class ProductDetailViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var providerLabel: UILabel!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadFirstProduct()
       
    }
    
    func loadFirstProduct() {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            if let product = results.first {
                nameLabel.text = product.name
                descriptionLabel.text = product.description
                priceLabel.text = "$\(product.price)"
                providerLabel.text = product.provider
            } else {
                nameLabel.text = "No product found"
            }
        } catch {
            print("Error: \(error)")
        }
    }
}
