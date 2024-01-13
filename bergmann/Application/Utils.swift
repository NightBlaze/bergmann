//
//  Utils.swift
//  bergmann
//
//  Created by Alexander Timonenkov on 13.01.2024.
//

import Foundation

func mainAsync(_ block: @escaping () -> Void) {
    DispatchQueue.main.async { block() }
}
