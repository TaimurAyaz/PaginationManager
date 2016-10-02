![PaginationManager](https://github.com/TaimurAyaz/PaginationManager/blob/master/PaginationManager.png)

**PaginationManager** makes it easy to add paging functionality to any kind of scrollViews. 

-
##Compatibility:
`PaginationManager` is only compatible with **Swift 2.3**. Swift 3.0 support comming soon. 

##Installation:
####CocoaPods
* Add the following to your `Podfile`
```
  pod 'PaginationManager'
```
* Run `pod install`

####Manual
* Copy `PaginationManager.swift` into your project

##Usage:
If you are using `CocoaPods`, you need to import `PaginationManager` as a module to your class by adding the following:
```
import PaginationManager
```

Usage is fairly simple. You need to create a `PaginationManager` property (you need a strong reference):
```
var paginationManager: PaginationManager?
```
Then initialize it with the appropriate `scrollView` and assign the delegate:
```
paginationManager = PaginationManager(scrollView: tableView, direction: .vertical)
paginationManager?.delegate = self
```
You also need to implement the `PaginationManagerDelegate` method:
```
func paginationManagerDidExceedThreshold(manager: PaginationManager, threshold: CGFloat, reset: PaginationManagerResetBlock)
```
