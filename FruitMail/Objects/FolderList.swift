//
//  FolderList.swift
//  FruitMail
//
//  Created by Florian Hermouet-Joscht on 12/2/18.
//  Copyright © 2018 Florian Hermouet-Joscht. All rights reserved.
//

import Foundation

class FolderList : Codable {
    var new: [Folder]
    var read: [Folder]
    var done: [Folder]
}
