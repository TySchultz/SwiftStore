
![Logo](./SwiftStoreLogo@2x.png)

# SwiftStore



<p align="center">
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/swiftpm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
     <img src="https://img.shields.io/cocoapods/l/Cache.svg?style=flat" alt="platforms" />
     <img src="https://img.shields.io/cocoapods/p/Cache?style=flat-square" alt="platforms" />
  
</p>

Lightweight Caching Library for Swift. Inspired by [Swift By Sundell](https://www.swiftbysundell.com/articles/caching-in-swift/).

## Table of Contents

* [Why?](#why)
* [Features](#features)

## Why?

Making an app feel fast and responsive isn’t only about tweaking the way its UI is rendered, or improving the sheer execution speed of its operations and algorithms — it’s often just as much about efficiently managing its data and avoiding unnecessary work.

Many apps do not need an expansive database for managing the data. An efficent implementation that works easily with the Codable protocol is likely more than enough for your average application. The main goal of any software is to create quickly with readability and replaceability. This package is intended to do that, while allowing extensibility if needed. 


## Features

* 💪 Elegant caching API in Swift
* 🎯 Lightweight and easy to use.
* 🎨 Create Custom Modifiers.

## At a Glance

**Example** 😊

```swift
put example here 
```

## Installation

Publish is distributed using the [Swift Package Manager](https://swift.org/package-manager). To install it into a project, add it as a dependency within your `Package.swift` manifest:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/TySchultz/SwiftStore.git", from: "0.1.0")
    ],
    ...
)
```

Then import Publish wherever you’d like to use it:

```swift
import SwiftStore
```

For more information on how to use the Swift Package Manager, check out [this article](https://www.swiftbysundell.com/articles/managing-dependencies-using-the-swift-package-manager), or [its official documentation](https://swift.org/package-manager).
