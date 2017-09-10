//
//  Proteins.swift
//  NCBI
//
//  Created by Nikhil D'Souza on 9/5/17.
//  Copyright © 2017 Nikhil D'Souza. All rights reserved.
//

import Foundation

func getProtein(abbreviation: Character) -> String {
    switch abbreviation {
        case "F":
            return "Phe"
        case "L":
            return "Leu"
        case "I":
            return "Ile"
        case "M":
            return "Met"
        case "V":
            return "Val"
        case "S":
            return "Ser"
        case "P":
            return "Pro"
        case "T":
            return "Thr"
        case "A":
            return "Ala"
        case "Y":
            return "Tyr"
        case "H":
            return "His"
        case "Q":
            return "Gln"
        case "N":
            return "Asn"
        case "K":
            return "Lys"
        case "D":
            return "Asp"
        case "E":
            return "Glu"
        case "C":
            return "Cys"
        case "W":
            return "Trp"
        case "R":
            return "Arg"
        case "G":
            return "Gly"
        case "*":
            return "Stop"
        default:
            return "?"
    }
}
