import UIKit

class PokemonViewController: UIViewController {
    var url: String!
    var speciesUrl: String!
    var pokemonIsCatched: Bool!

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var type1Label: UILabel!
    @IBOutlet var type2Label: UILabel!
    @IBOutlet var catchButton: UIButton!
    @IBOutlet var pokemonImage: UIImageView!
    @IBOutlet var pokemonDesc: UILabel!
    
    // Initialization when view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Initiallize the labels
        nameLabel.text = ""
        numberLabel.text = ""
        type1Label.text = ""
        type2Label.text = ""
        pokemonDesc.text = ""
        toggleCatchText()

        // Fetch pokemon data
        loadPokemon()
    }
    
    // To toggle catch and save to UserDefaults
    @IBAction func toggleCatch() {
        self.pokemonIsCatched = !self.pokemonIsCatched
        UserDefaults.standard.set(self.pokemonIsCatched, forKey: self.nameLabel.text!.lowercased())
        toggleCatchText()
    }
    
    // Toggle catch button text
    func toggleCatchText() {
        if pokemonIsCatched {
            catchButton.setTitle("Release", for: UIControl.State.normal)
            catchButton.setTitleColor(UIColor.systemBlue, for: UIControl.State.normal)
        }
        else {
            catchButton.setTitle("Catch", for: UIControl.State.normal)
            catchButton.setTitleColor(UIColor.systemRed, for: UIControl.State.normal)
        }
    }

    // Capitalize the first character
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }

    // Fetch Pokemon info from URL given
    func loadPokemon() {
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data else {
                return
            }

            do {
                let result = try JSONDecoder().decode(PokemonResult.self, from: data)
                DispatchQueue.main.async {
                    self.navigationItem.title = self.capitalize(text: result.name)
                    self.nameLabel.text = self.capitalize(text: result.name)
                    self.numberLabel.text = String(format: "#%03d", result.id)

                    for typeEntry in result.types {
                        if typeEntry.slot == 1 {
                            self.type1Label.text = typeEntry.type.name
                        }
                        else if typeEntry.slot == 2 {
                            self.type2Label.text = typeEntry.type.name
                        }
                    }
                    
                    // Fetch image
                    do {
                        let imageData = try Data(contentsOf: URL(string: result.sprites.front_default)!)
                        self.pokemonImage.image = UIImage(data: imageData)
                    }
                    catch let error {
                        print(error)
                    }
                    
                    self.speciesUrl = "https://pokeapi.co/api/v2/pokemon-species/" + String(result.id)
                    
                    let fetchDescription = URLSession.shared.dataTask(with: URL(string: self.speciesUrl)!) { (data, response, error) in
                        guard let data = data else {
                            return
                        }
                        
                        do {
                            let result = try JSONDecoder().decode(PokemonSpecies.self, from: data)
                            DispatchQueue.main.async {
                                self.pokemonDesc.text = result.flavor_text_entries[0].flavor_text
                            }
                        }
                        catch let error {
                            print(error)
                        }
                    }
                    
                    fetchDescription.resume()
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
}
