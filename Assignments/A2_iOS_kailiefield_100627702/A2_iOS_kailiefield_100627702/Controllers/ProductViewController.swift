import UIKit
import CoreData

class ProductViewController: UITableViewController {
    
//    var products = ["Milk", "Cheese", "Bread", "Eggs", "Apples", "Bananas", "Oranges", "Potatoes", "Onions", "Tomatoes"]
    
    var products: [Product] = []
    var filteredProducts: [Product] = []

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Products"
        
        // --- [ NAV BAR ] --
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addProductTapped))
        navigationItem.leftBarButtonItem = self.editButtonItem
        
        // -- [ SEARCH ] --
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Products"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProducts()
    }
    
    // -- [ ADD PRODUCT ] --
    @objc func addProductTapped() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addVC = storyboard.instantiateViewController(withIdentifier: "AddProductVC") as! AddProductViewController
        navigationController?.pushViewController(addVC, animated: true)
    }
    
    // -- [ CORE DATA FETCH ] --
    func fetchProducts() {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        do {
            products = try context.fetch(request)
            tableView.reloadData()
        } catch {
            
            print("Error: \(error)")
        }
    }
    
    // -- [ TABLE VIEW DATA SOURCE ] --
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return products.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath)
        let product = products[indexPath.row]
        cell.textLabel?.text = product.name
        cell.detailTextLabel?.text = product.prodDesc
        return cell
    }
    
    // -- [ ROW TAP NAVIGATION TO DETAIL VIEW ] --
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProduct = isFiltering ? filteredProducts[indexPath.row] : products[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "ProductDetailVC") as! ProductDetailViewController
        
        detailVC.product = selectedProduct //<--- will fix soon with real product data
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // -- [ EDIT / SWIP TO DELETE ] --
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete {
            print("Swipe left to delete triggered.")
            let productToDelete = products[indexPath.row]
            context.delete(productToDelete)
            
            do {
                try context.save()
                products.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    // -- [ UI SEARCH RESULTS UPDATING] --
    extension ProductViewController: UISearchResultsUpdating {
        func updateSearchResults(for searchController: UISearchController) {
            let searchText = searchController.searchBar.text ?? ""
            filteredProducts = products.filter{
                ($0.name?.lowercased().contains(searchText.lowercased()) ?? false) ||
                ($0.prodDesc?.lowercased().contains(searchText.lowercased()) ?? false)
            }
            tableView.reloadData()
        }
    }

}
