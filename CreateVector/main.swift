//
//  main.swift
//  CreateVector
//
//  Created by Kevin Nguyen on 11/1/23.
//

import Foundation
import SimilaritySearchKit

var obj = await VectorObject()
await obj.build()
await obj.search(prompt: "What did Jesus say to John?")
