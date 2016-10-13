![PaginationManager](https://github.com/TaimurAyaz/PaginationManager/blob/master/PaginationManager.png)

**PaginationManager** makes it easy to add paging functionality to any kind of scrollView. 

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
####Declaration
You need to create a `PaginationManager` property (you need a strong reference):
```
var paginationManager: PaginationManager?
```

####Initialization
`PaginationManager` provides two initializers:

--

**`init(scrollView:direction:thresholdType:)`**

* `scrollView` 
The scrollView for the pagination manager

* `direction`
The direction of the scrollView

* `thresholdType`
The thresholdType for the pagination manager. This has a default value of `.constant(value: PaginationManagerConstantThresholdScreenDimension)`. See `Types of threshold` below.

Use the first initializer if you want to hook into the `scrollView`'s delegate methods. This will set the `PaginationManager` as the delegate of the `scrollView` and pass the delegate methods to the original delegate. 

--

**`init(direction:thresholdType:)`**

* `direction`
The direction of the scrollView

* `thresholdType`
The thresholdType for the pagination manager. This has a default value of `.constant(value: PaginationManagerConstantThresholdScreenDimension)`. See `Customization` below.

If you use the this initializer, you need to explicitly call `scrollViewDidScroll:` on the `PaginationManager` at your `scrollView`'s `scrollViewDidScroll:` delegate callback.

--

`PaginationManager` also includes the following static initializers for objective-c interoperability. 

**`constantThresholdManager(forScrollView:direction:constant:)`**
**`constantThresholdManager(withDirection:constant:)`**
**`percentageThresholdManager(forScrollView:direction:percentage:)`** 
**`percentageThresholdManager(withDirection:percentage:)`**

####Delegation

You also need to assign the delegate of the `PaginationManager`, like so:
```
paginationManager?.delegate = self
```

Also make sure to conform to the `PaginationManagerDelegate`:
```
func paginationManagerDidExceedThreshold(manager: PaginationManager, reset: PaginationManagerResetBlock)
```
See `Delegate callback` below.

##Customization:
You can customize the behavior of the pagination manager by the following:

####PaginationManagerDirection : enum
You need to provide a scroll direction for the pagination manager during initialization. This **`cannot`** be modified later on as the core behavior of the pagination manager depends on it.

####PaginationManagerThresholdType : enum
This property governs the threshold type for the `PaginationManager`. It provides the following types of thresholds:

* **percentage(value:)**

This type defines a threshold based on the percentage scrolled. It takes in a percentage value. This value should be between `0.0` and `1.0`.

* **constant(value:)**

This type defines a threshold based on a constant amount from the end of the `scrollView`'s content. It requires a constant value. This value should be greater than `0.0`. This is the default type for the `PaginationManager` and its default value is defined as `PaginationManagerConstantThresholdScreenDimension` which takes the maximum device screen dimension based on the `direction` of the `PaginationManager`.


##Delegate callback:
The `PaginationManagerDelegate` provides only one method:
```
func paginationManagerDidExceedThreshold(manager: PaginationManager, reset: PaginationManagerResetBlock)
```
This is a required method. At the end of your implementation for this, you **`must`** call the `reset` block. This block takes a `bool` value that tells the manager whether new items were loaded or not. An example could be loading async images and then calling `reset(true)` when new images are loaded. This system of calling the `reset` block is implemented to restrict the manager from notifiying the receiver multiple times. 

##Example:
An example project has been included. It contains a basic implementation of the `PaginationManager`

-
**Issues / PRs welcome :)**

##License

MIT License

Copyright (c) 2016 Taimur Ayaz

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

