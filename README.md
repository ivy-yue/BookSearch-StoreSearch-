# BookSearch-StoreSearch-

Introduction

BookSearch — An individual project to build up an application which mashup at least 4 web apis.


I got this inspiration when I was looking up original books Pitifully, there has no specified website or application providing such sources especially e-books or simply recommendation.  So I aim to develop a simple app called “Book Search”. It combines both English-version book-info and Chinese-version, and it enable you the convenience to get the e-books available.

To begin with, in this app, you can get access to the latest chart of best-selling books in this week  post on USAToday ( which, app will automatically get your present date and fetch the latest data for you ). In the book detail, you’ll get the book name, author name, together with its isbn*. Then you can search it on the search bar with keywords or isbn. If you just want to search a book rather than look for the chart, jump to next step.

Also, BookSearch also provide function for you in case you have no idea what’s the isbn of the book you want to search for. Choose “ISBN” segment and enter the key word, in the results, it’ll list out top20 most closest results to the keyword and will display its isbn.

Last thing you need to know: if you want to get the Chinese summary of a book, choose “books”, and the price button will link you to more reviews over the book; while you want to get info in English or want to get info about e-book, choose”e-book”, also the price button will link you to the more detailed pages over the book.

Hope you enjoy it!

#Public APIs

  i.  DOUBAN Book V2: A free API includes information such as book author, rating and summary. But it should be given the isbn or Douban’s own book_id.

	ii. ISBNdb API V2: ISBNdb's v2 API is a RESTful API that offers a simple mechanism for querying much of the information stored in our database.

	iii. ITUNES API: An API allows developers to access and integrate information of ebook by given keywords or isbn.

	iv. USA Today Best-selling Books API: An free-key API displays USA TODAY's Best-Selling Books list ranking the 150 top-selling titles each week based on an analysis of sales from U.S. booksellers.

#Open Source Library

i. GDataXML:  Parsing XML format in Swift. ( a tree-based structure )

#Configuration and Deployment Description

i. Development environment:
	Xcode 8.0
	Swift 3.0
	iOS Simulator 10.1 

ii. Configurations:
	- Download from github
 	  $ git clone https://github.com/ivy-yue/BookSearch-StoreSearch-/projects
	
	- Open   StoreSearch.xcworkspace    and Run
  
  
