//import SimilaritySearchKit
//import SimilaritySearchKitMiniLMMultiQA
//import SwiftUI
//
//class VectorObject {
//    private var currentSplitter: any TextSplitterProtocol = TokenSplitter(withTokenizer: BertTokenizer())
//    private var currentTokenizer: any TokenizerProtocol = BertTokenizer()
//    private var index: SimilarityIndex
//    
//    init() async {
//        index = await SimilarityIndex(model: MultiQAMiniLMEmbeddings(), metric: EuclideanDistance())
//    }
//    
//    func build() {
//        Task {
//            var chunkedFileInfoArray: [Files.FileTextContents] = []
//            var chunkTextArray: [String] = []
//            var chunkTokensArray: [[String]] = []
//            var chunkTextIds: [UUID] = []
//            var chunkTextMetadata: [[String: String]] = []
//            
//            //        let saveIndex = JsonStore()
//            if let txtURL = Bundle.main.url(forResource: "world192", withExtension: "txt") {
//                do {
//                    
//                    
//                    let data = try String(contentsOf: URL(string: txtURL.absoluteString)!, encoding: .utf8)
//                    let (chunks, tokens) = currentSplitter.split(text: data, chunkSize: 250, overlapSize: 125)
//                    for (idx, chunk) in chunks.enumerated() {
//                        // needs a fixed UUID every time
//                        let uuid = UUID()
//                        let newFileInfo = Files.FileTextContents(id: uuid, text: chunk, fileUrl: URL(string: txtURL.absoluteString)!)
//                        chunkedFileInfoArray.append(newFileInfo)
//                        chunkTextArray.append(chunk)
//                        chunkTokensArray.append(tokens?[idx] ?? currentTokenizer.tokenize(text: chunk))
//                        chunkTextIds.append(uuid)
//                        chunkTextMetadata.append(["source": URL(string: txtURL.absoluteString)!.absoluteString])
//                    }
//                } catch {
//                    print("ERROR: \(error)")
//                }
//            } else {
//                print("ERROR: File not found")
//            }
//            
//            let folderTextIds = chunkTextIds.map { $0.uuidString }
//            let folderTextChunks = chunkTextArray
//            let folderTextMetadata = chunkTextMetadata
//            
//            
//            await index.addItems(ids: folderTextIds, texts: folderTextChunks, metadata: folderTextMetadata) { _ in
//                
//            }
//            
//            print("Built index with \(index.indexItems.count) items")
//            
//            do {
//                try index.saveIndex(toDirectory:  Bundle.main.url(forResource: "world192", withExtension: "txt")?.deletingLastPathComponent(), name: "index")
//                try index.loadIndex(fromDirectory:  Bundle.main.url(forResource: "world192", withExtension: "txt")?.deletingLastPathComponent(), name: "index")
//            } catch {
//                print("ERROR: \(error)")
//            }
//        }
//    }
//    
//    func search(prompt: String) async -> String {
//        do {
//
//            let results = await index.search(prompt)
//            return results[0].text/*results[0].text " SPLIT " + results[1].text*/
//        } catch {
//            print("ERROR: \(error)")
//        }
//        return "ERROR: Message not working properly! OBJECT SIDE"
//    }
//}
import SimilaritySearchKit
import SimilaritySearchKitMiniLMMultiQA
import Foundation

class VectorObject {
    private var currentSplitter: any TextSplitterProtocol = TokenSplitter(withTokenizer: BertTokenizer())
    private var currentTokenizer: any TokenizerProtocol = BertTokenizer()
    private var index: SimilarityIndex
    private var chunkedFileInfoArray: [Files.FileTextContents] = []
    private var chunkTextArray: [String] = []
    private var chunkTokensArray: [[String]] = []
    private var chunkTextIds: [UUID] = []
    private var chunkTextMetadata: [[String: String]] = []
    
    init() async {
        index = await SimilarityIndex(model: MultiQAMiniLMEmbeddings(), metric: EuclideanDistance())
    }
    
    func build() async {
        let directoryURL = URL(fileURLWithPath: "/Users/at461f/Documents/SoftwareProject/RealmIngest/modify-data")
        do {
            let fileManager = FileManager.default
            let fileURLs = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                print(fileURL.absoluteString)
                if fileURL.pathExtension == "txt" {
                    do {
                        let fileContents = try String(contentsOf: fileURL, encoding: .utf8)
                        let (chunks, tokens) = currentSplitter.split(text: fileContents, chunkSize: 250, overlapSize: 125)
                        for (idx, chunk) in chunks.enumerated() {
                            // needs a fixed UUID every time
                            let uuid = UUID()
                            let newFileInfo = Files.FileTextContents(id: uuid, text: chunk, fileUrl: URL(string: fileURL.absoluteString)!)
                            chunkedFileInfoArray.append(newFileInfo)
                            chunkTextArray.append(chunk)
                            chunkTokensArray.append(tokens?[idx] ?? currentTokenizer.tokenize(text: chunk))
                            chunkTextIds.append(uuid)
                            chunkTextMetadata.append(["source": URL(string: fileURL.absoluteString)!.absoluteString])
                        }
                    } catch {
                        print("Error Reading File \(fileURL): \(error)")
                    }
                }
            }
        } catch {
            print("Error: Invalid Directory \(error)")
        }
        let folderTextIds = chunkTextIds.map { $0.uuidString }
        let folderTextChunks = chunkTextArray
        let folderTextMetadata = chunkTextMetadata

        await index.addItems(ids: folderTextIds, texts: folderTextChunks, metadata: folderTextMetadata) { _ in

        }
        print("Built index with \(index.indexItems.count) items")
        
        do {
            try index.saveIndex(toDirectory:  URL(fileURLWithPath: "/Users/at461f/Documents/SoftwareProject/RealmIngest/vector-data"), name: "index")
        } catch {
            print("ERROR: \(error)")
        }
        
    }
    
    func search(prompt: String) async -> String {
        do {

            let results = await index.search(prompt)
            if(results.count == 1) {
                return results[0].text
            } else if(results.count >= 2) {
                return results[0].text + " SPLIT " + results[1].text
            } else {
                return " "
            }
        } catch {
            print("ERROR: \(error)")
        }
        return "ERROR: Message not working properly! OBJECT SIDE"
    }
}
