//
//  File.swift
//  
//
//  Created by Hasan Oztunc on 16.05.2021.
//

extension String {
    
    var bytes: [UInt8] {
        .init(self.utf8)
    }
}
