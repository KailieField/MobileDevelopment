import UIKit
import CoreData

class ProductViewController: UITableViewController, UISearchResultsUpdating {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let searchController = UISearchController(searchResultsController: nil)
    
    var products: [Product] = []
    var filteredProducts: [Product] = []
    
    var isFiltering: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Products"
        
        // --- [ NAV BAR ] --
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addProductTapped))
        // -- [ EDIT BUTTON ] --
        navigationItem.leftBarButtonItem = self.editButtonItem
        
        // -- [ SEARCH ] --
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Products (Name or Description)"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProducts()
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
    
    // -- [ ADD PRODUCT NAV ] --
    @objc func addProductTapped() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addVC = storyboard.instantiateViewController(withIdentifier: "AddProductVC") as! AddProductViewController
        navigationController?.pushViewController(addVC, animated: true)
    }
    
    
    // -- [ TABLE VIEW DATA SOURCE ] --
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return isFiltering ? filteredProducts.count: products.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath)
        let product = isFiltering ? filteredProducts[indexPath.row] : products[indexPath.row]
        cell.textLabel?.text = product.name
        cell.detailTextLabel?.text = product.prodDesc
        return cell
    }
    
    // -- [ ROW TAP NAVIGATION TO DETAIL VIEW ] --
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProduct = isFiltering ? filteredProducts[indexPath.row] : products[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "ProductDetailVC") as! ProductDetailViewController
        detailVC.product = selectedProduct
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // -- [ EDIT / SWIP TO DELETE ] --
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete {
            print("Swipe left to delete triggered.")
            let productToDelete = isFiltering ? filteredProducts[indexPath.row] : products[indexPath.row]
            context.delete(productToDelete)
            
            do {
                try context.save()
                
                if isFiltering {
                    if let index = products.firstIndex(of: productToDelete){
                        products.remove(at: index)
                    }
                    filteredProducts.remove(at: indexPath.row)
                } else{
                    products.remove(at: indexPath.row)
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    // -- [ UI SEARCH RESULTS UPDATING] --
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        filteredProducts = products.filter{
            ($0.name?.lowercased().contains(searchText.lowercased()) ?? false) ||
            ($0.prodDesc?.lowercased().contains(searchText.lowercased()) ?? false)
        }
        tableView.reloadData()
    }
}

