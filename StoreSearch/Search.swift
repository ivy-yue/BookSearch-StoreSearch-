//  BookSearch
//
//  Created by wangyue on 2016/11/4.
//  Copyright © 2016年 Razeware. All rights reserved.
//
import Foundation
import UIKit

typealias SearchComplete = (Bool) -> Void

class Search {

  enum Category: Int {
    case Chart = 0
    case Basic = 1
    case Book = 2
    case ebooks = 3
    
    var entityName: String {
      switch self {
      case .Chart: return "Chart"
      case .Basic: return "Basic"
      case .Book: return "Book"
      case .ebooks: return "ebook"
      }
    }
  }

  enum State {
    case notSearchedYet
    case loading
    case noResults
    case results([SearchResult])
  }

  private(set) var state: State = .notSearchedYet
  
  private var dataTask: URLSessionDataTask? = nil
  
  func performSearch(for text: String, category: Category, completion: @escaping SearchComplete) {
    if !text.isEmpty {
      dataTask?.cancel()
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
      
      state = .loading
      //..
      let url = iTunesURL(searchText: text, category: category)
      if category.entityName == "Basic" {
        //testXML(url: url)
        
        //BBBBBBIIIIIIGGGGGGG PPPPRRRROOO
        let xmlData = try! Data(contentsOf: url)
        let doc:GDataXMLDocument = try! GDataXMLDocument(data:xmlData, options : 0)
        let users = try! doc.nodes(forXPath: "//BookData", namespaces:nil) as! [GDataXMLElement]
        var searchResults: [SearchResult] = []
        for user in users {
            var searchResult: SearchResult?
            searchResult = parseXML(user: user)
                
            if let result = searchResult {
                searchResults.append(result)
            }
            
        }
        if searchResults.isEmpty {
            self.state = .noResults
        } else {
            //searchResults.sort(by: <)
            self.state = .results(searchResults)
        }
      }
        
      else {
        let session = URLSession.shared
        dataTask = session.dataTask(with: url, completionHandler: {
        data, response, error in
        
        //self.state = .notSearchedYet
        var success = false

        if let error = error as? NSError, error.code == -999 {
          return   // Search was cancelled
        }
        //..
        if category.entityName == "ebook" {
            if let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200,
                let jsonData = data,
                let jsonDictionary = self.parse(json: jsonData) {
          
                var searchResults = self.parse(dictionary: jsonDictionary)
                if searchResults.isEmpty {
                    self.state = .noResults
                } else {
                    searchResults.sort(by: <)
                    self.state = .results(searchResults)
                }
                success = true
            }
        }
        else if category.entityName == "Chart" {
            if let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200,
                let jsonData = data,
                let jsonDictionary = self.parseChart(json: jsonData) {
                
                var searchResults = self.parseChart(dictionary: jsonDictionary)
                if searchResults.isEmpty {
                    self.state = .noResults
                } else {
                    //searchResults.sort(by: <)
                    self.state = .results(searchResults)
                }
                success = true
            }
            
        }
        
        else if category.entityName == "Book" {
            if let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200,
                let jsonData = data,
                let jsonDictionary = self.parseBook(json: jsonData) {
                var searchResults = self.parseBook(dictionary: jsonDictionary)
                if searchResults.isEmpty {
                    self.state = .noResults
                } else {
                    //searchResults.sort(by: <)
                    self.state = .results(searchResults)
                }
                success = true
            }

        }
        
        DispatchQueue.main.async {
          UIApplication.shared.isNetworkActivityIndicatorVisible = false
          completion(success)
        }
      })}
      dataTask?.resume()
    }
  }

  private func iTunesURL(searchText: String, category: Category) -> URL {
    let entityName = category.entityName
    let locale = Locale.autoupdatingCurrent
    let language = locale.identifier
    let countryCode = locale.regionCode ?? "en_US"
    
    let escapedSearchText = searchText.addingPercentEncoding(
      withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    
    let urlString:String
    
    if entityName == "ebook" {
        //success
        urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@&lang=%@&country=%@", escapedSearchText, entityName, language, countryCode)
    }
    else if entityName == "Chart" {
        //
        urlString = String(format:"http://usatoday30.usatoday.com/api/books/ThisWeek")
    }
    else if entityName == "Book" {
        //how tp get data from its title
        urlString = String(format:"https://api.douban.com/v2/book/isbn/%@",escapedSearchText)
    }
    else  {
        //get isbn info
        //XML
        urlString = String(format:"http://isbndb.com/api/books.xml?access_key=66QFN6TP&index1=title&value1=%@",escapedSearchText)
    }

    
    let url = URL(string: urlString)
    print("URL: \(url!)")
    return url!
  }
    
    
  //ebook
  private func parse(json data: Data) -> [String: Any]? {
    do {
      return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    } catch {
      print("JSON Error: \(error)")
      return nil
    }
  }
  
  private func parse(dictionary: [String: Any]) -> [SearchResult] {
    
    guard let array = dictionary["results"] as? [Any] else {
      print("Expected 'results' array")
      return []
    }
    
    var searchResults: [SearchResult] = []
    
    for resultDict in array {
      if let resultDict = resultDict as? [String: Any] {
        
        var searchResult: SearchResult?

        searchResult = parse(ebook: resultDict)
        
        if let result = searchResult {
          searchResults.append(result)
        }
      }
    }
    
    return searchResults
  }

  private func parse(ebook dictionary: [String: Any]) -> SearchResult {
    let searchResult = SearchResult()
    searchResult.name = dictionary["trackName"] as! String
    searchResult.artistName = dictionary["artistName"] as! String
    searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
    searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
    searchResult.storeURL = dictionary["trackViewUrl"] as! String
    searchResult.kind = dictionary["kind"] as! String
    searchResult.currency = dictionary["currency"] as! String
    searchResult.tagNameLabel = "Tags:"
    searchResult.typeNameLabel = "Type:"
    
    if let price = dictionary["price"] as? Double {
      searchResult.price = price
    }
    if let genres: Any = dictionary["genres"] {
      searchResult.genre = (genres as! [String]).joined(separator: ", ")
    }
    return searchResult
  }
    
    //Chart
    private func parseChart(json data: Data) -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }
    }
    
    private func parseChart(dictionary: [String: Any]) -> [SearchResult] {
        guard let array = ( ( dictionary["BookLists"] as? [Any] )?[0] as? NSDictionary)?["BookListEntries"] as? NSArray
        else {
            print("Expected 'results' array")
            return []
        }
        
        var searchResults: [SearchResult] = []

        for temp in 0 ... 20 {
            if let resultDict = array[temp] as? [String: Any] {
                
                var searchResult: SearchResult?
                searchResult = parseChart(chart: resultDict)
                
                if let result = searchResult {
                    searchResults.append(result)
                }
            }
        }
        return searchResults

    }
    
    private func parseChart(chart dictionary:[String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["Title"] as! String
        searchResult.artistName = dictionary["Author"] as! String
        searchResult.genre = dictionary["BriefDescription"] as! String
        searchResult.tagNameLabel = "Brief:"
        searchResult.typeNameLabel = "ISBN:"
        searchResult.kind = dictionary["ISBN"] as! String
        //searchResult.artworkSmallURL = dictionary["TitleAPIUrl"] as! String
        
        return searchResult
    }
    
   
    //Book
    private func parseBook(json data: Data) -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }
    }
    
    private func parseBook(dictionary: [String: Any]) -> [SearchResult] {

        var searchResults: [SearchResult] = []
        var searchResult: SearchResult?
        searchResult = parseBook(chart: dictionary)
        if let result = searchResult {
            searchResults.append(result)
        }
        return searchResults
        
    }
    
    private func parseBook(chart dictionary:[String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["title"] as! String
        searchResult.artistName = (dictionary["author"] as? NSArray)?[0] as! String
        searchResult.genre = dictionary["summary"] as! String
        searchResult.tagNameLabel = "介绍:"
        searchResult.typeNameLabel = "评分:"
        searchResult.kind = (dictionary["rating"] as? NSDictionary)?["average"] as! String
        searchResult.artworkSmallURL = dictionary["image"] as! String
        searchResult.artworkLargeURL = dictionary["image"] as! String
        searchResult.storeURL = dictionary["alt"] as! String
        return searchResult
    }
    
    //XML get isbn
    //Basic
    func testXML(url:URL) -> SearchResult {
        //获取xml文件路径
        let searchResult = SearchResult()
        let xmlData = try! Data(contentsOf: url)
        
        //可以转换为字符串输出查看
        //print(String(data:xmlData, encoding:String.Encoding.utf8))
        
        //使用NSData对象初始化文档对象
        //这里的语法已经把OC的初始化函数直接转换过来了
        let doc:GDataXMLDocument = try! GDataXMLDocument(data:xmlData, options : 0)
        
        //获取Users节点下的所有User节点，显式转换为element类型编译器就不会警告了
        //let users = doc.rootElement().elements(forName: "User") as! [GDataXMLElement]
        
        //通过XPath方式获取Users节点下的所有User节点，在路径复杂时特别方便
        let users = try! doc.nodes(forXPath: "//BookData", namespaces:nil) as! [GDataXMLElement]
        
        for user in users {
            //User节点的id属性
            let uid = user.attribute(forName: "book_id").stringValue()
            let uisbn = user.attribute(forName: "isbn").stringValue()
            let uisbn13 = user.attribute(forName: "isbn13").stringValue()
            //获取name节点元素  -> 获取 title
            let nameElement = user.elements(forName: "Title")[0] as! GDataXMLElement
            //获取元素的值 -> 获取title下的元素
            let uname =  nameElement.stringValue()
            
            //获取name节点元素  -> 获取 title
            let authorElement = user.elements(forName: "AuthorsText")[0] as! GDataXMLElement
            //获取元素的值 -> 获取title下的元素
            let author =  authorElement.stringValue()
            //输出调试信息
            //print("User: uid:\(uid!),uisbn:\(uisbn!),uisbn13:\(uisbn13!),uname:\(uname!),author:\(author!)")
            searchResult.name = uname!
            searchResult.artistName = author!
            searchResult.genre = uisbn!
            searchResult.tagNameLabel = "isbn:"
            searchResult.typeNameLabel = "isbn13:"
            searchResult.kind = uisbn13!
            
        }
        return searchResult
    }
    private func parseXML( user: GDataXMLElement) -> SearchResult {
        let searchResult = SearchResult()
        //User节点的id属性
        let uid = user.attribute(forName: "book_id").stringValue()
        let uisbn = user.attribute(forName: "isbn").stringValue()
        let uisbn13 = user.attribute(forName: "isbn13").stringValue()
        //获取name节点元素  -> 获取 title
        let nameElement = user.elements(forName: "Title")[0] as! GDataXMLElement
        //获取元素的值 -> 获取title下的元素
        let uname =  nameElement.stringValue()
        
        //获取name节点元素  -> 获取 title
        let authorElement = user.elements(forName: "AuthorsText")[0] as! GDataXMLElement
        //获取元素的值 -> 获取title下的元素
        let author =  authorElement.stringValue()
        //输出调试信息
        //print("User: uid:\(uid!),uisbn:\(uisbn!),uisbn13:\(uisbn13!),uname:\(uname!),author:\(author!)")
        searchResult.name = uname!
        searchResult.artistName = author!
        searchResult.genre = uisbn!
        searchResult.tagNameLabel = "isbn:"
        searchResult.typeNameLabel = "isbn13:"
        searchResult.kind = uisbn13!
        return searchResult
    }

    
}








