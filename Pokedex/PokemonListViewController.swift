import UIKit

class PokemonListViewController: UITableViewController, UISearchBarDelegate {
    var pokemon: [PokemonListResult] = []
    var searchedPokemon: [PokemonListResult] = []
    
    @IBOutlet var searchBar: UISearchBar!
    
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            do {
                let entries = try JSONDecoder().decode(PokemonListResults.self, from: data)
                self.pokemon = entries.results
                self.searchedPokemon = self.pokemon
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == "" {
            searchedPokemon = pokemon
            tableView.reloadData()
            return
        }
        
        searchedPokemon.removeAll()
        
        for pokemon in pokemon {
            if pokemon.name.lowercased().contains(searchText.lowercased()) {
                searchedPokemon.append(pokemon)
                tableView.reloadData()
            }
        }
        
        tableView.reloadData()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedPokemon.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath)
        cell.textLabel?.text = capitalize(text: searchedPokemon[indexPath.row].name)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPokemonSegue",
                let destination = segue.destination as? PokemonViewController,
                let index = tableView.indexPathForSelectedRow?.row {
            destination.url = searchedPokemon[index].url
        }
    }
}
