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
Then initialize it with the appropriate `scrollView` and `direction`, and then assign the delegate:
```
paginationManager = PaginationManager(scrollView: tableView, direction: .vertical)
paginationManager?.delegate = self
```
You also need to implement the `PaginationManagerDelegate` method:
```
func paginationManagerDidExceedThreshold(manager: PaginationManager, threshold: CGFloat, reset: PaginationManagerResetBlock)
```

##Customization:
You can customize the behavior of the pagination manager by the following:

####PaginationManagerDirection : enum
You need to provide a scroll direction for the pagination manager during initialization. This **`cannot`** be modified later on as the core behavior of the pagination manager depends on it.

####thresholdPercentage : CGFloat
This property governs the threshold for the pagination manager. As the `contentOffset` in the given direction exceeds this threshold, the receiver is notified using the pagination manager delegate. The default value is `0.6`.

##Delegate callback
The `PaginationManagerDelegate` provides only one method:
```
func paginationManagerDidExceedThreshold(manager: PaginationManager, threshold: CGFloat, reset: PaginationManagerResetBlock)
```
This is a required method. At the end of your implementation for this, you **`must`** call the `reset` block. This block takes a `bool` value that tells the manager whether new items were loaded or not. An example could be loading async images and then calling `reset(true)` when new images are loaded. This system of calling the `reset` block is implemented to restrict the manager from notifiying the receiver multiple times. 
