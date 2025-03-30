
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
        loadFirstProduct()
    }
    func loadFirstProduct(){
        let request:NSFetchRequest<Product> = Product.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            if let product = results.first{
                
                nameLabel.text = product.name ?? "Unamed."
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
    
    @IBAction func viewAllTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let listVC = storyboard.instantiateViewController(withIdentifier: "ProductListVC") as! ProductViewController
        navigationController?.pushViewController(listVC, animated: true)
        
    }
}

