//
//  DataService.swift
//  IOS_Pokemon
//
//  Created by Hannah on 6/18/18.
//  Copyright © 2018 Hannah. All rights reserved.
//

import Foundation
import UIKit

class DataService {
    var baseUrl = "http://pokeapi.co/api/v2/pokemon/"
    var pokemons: [PokemonObject] = []
  
private func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
    DispatchQueue.main.async {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    URLSession.shared.dataTask(with: url) { data, response, error in
        completion(data, response, error)
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        }.resume()
}
    
func getPokemon(id: Int, urlString: String, completion: @escaping (PokemonObject?) -> ()) {
    let newUrlString = (urlString == "") ? urlString : self.baseUrl;
    getDataFromUrl(url: URL(string: newUrlString + String(id))!) { (data, res, err) in
        guard let pokemon = try? JSONDecoder().decode(PokemonObject.self, from: data!) else {

            print("Error: Couldn't decode data into pokemon")
            return
        }
        completion(pokemon)
    }
}

public func getPokemons(page: Int, completion: @escaping (PokemonObject?) -> ()) {
    let offset = 20 * page - 20 + 1
    let url = (baseUrl + "?offset=" + String(offset))
    var _: [PokemonObject] = []
    for index in offset...(offset+19) {
        self.getPokemon(id: index, urlString: url) { (pokemon) in
            self.pokemons.append(pokemon!)
            completion(pokemon)
        }
    }
}
    

    
func getImage(url: String, completion: @escaping(UIImage?) -> ()) {
    getDataFromUrl(url: URL(string: url)!) { (data, res, err) in
        completion(UIImage(data: data!))
    }
}

}
