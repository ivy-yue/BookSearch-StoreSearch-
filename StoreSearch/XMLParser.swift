//
//  XMLParser.swift
//  StoreSearch
//
//  Created by wangyue on 2016/11/6.
//  Copyright © 2016年 Razeware. All rights reserved.
//

import Foundation
import UIKit

func testXML() {
    //获取xml文件路径
    let url = iTunesURL()
    let xmlData = try! Data(contentsOf: url)
    
    //可以转换为字符串输出查看
    print(String(data:xmlData, encoding:String.Encoding.utf8))
    
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
        print("User: uid:\(uid!),uisbn:\(uisbn!),uisbn13:\(uisbn13!),uname:\(uname!),author:\(author!)")
    }
}

func iTunesURL() -> URL {
    let url1:String = "http://isbndb.com/api/books.xml?access_key=66QFN6TP&index1=title&value1=the+little+princess"
    let url = URL(string: url1)
    print("URL: \(url!)")
    return url!
}













