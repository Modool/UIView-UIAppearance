# UIView+UIAppearance

[![](https://img.shields.io/travis/rust-lang/rust.svg?style=flat)](https://github.com/Modool)
[![](https://img.shields.io/badge/language-Object--C-1eafeb.svg?style=flat)](https://developer.apple.com/Objective-C)
[![](https://img.shields.io/badge/license-MIT-353535.svg?style=flat)](https://developer.apple.com/iphone/index.action)
[![](https://img.shields.io/badge/platform-iOS-lightgrey.svg?style=flat)](https://github.com/Modool)
[![](https://img.shields.io/badge/QQ群-662988771-red.svg)](http://wpa.qq.com/msgrd?v=3&uin=662988771&site=qq&menu=yes)

## Introduction

- This framework base on <a href="https://github.com/Modool/UIView-UIAppearance-Private"> UIView+UIAppearance+Private </a>.
- It's dedicated to implementing multi-theme solutions with the implementation of the system.
- The system solution is flawed, which can't synchronous theme for these views is being displayed.
- It's an extension for UIAppearance protocol.

## How To Get Started

* Download `UIView+UIAppearance` and try run example app

## Installation


* Installation with CocoaPods

```
source 'https://github.com/Modool/cocoapods-specs.git'
platform :ios, '8.0'

target 'TargetName' do
pod 'UIView+UIAppearance', '~> 1.0'
end
```

* Installation with Carthage

```
github "Modool/UIView-UIAppearance" ~> 1.0
```

* Manual Import

```
drag “UIView+UIAppearance” directory into your project

```

## Requirements
- Requires ARC

## Architecture
### UIView (UIAppearance)
* `hook methods`
	* `allocWithZone:` 
	* `appearance`

### UIAppearanceHooker
* `properties`
	* `appearance` storage of current instance of _UIAppearance
	* `appearanceViewClass` storage of current view class
	* `appearanceInvocations` storage of invocations of appearance properties of view class 
	* `mutableInstances` storage of instances of view class 
* `methods`
	* `methodForSelector:`  transmition of method implementation
	* `forwardInvocation:` 	transmition of invocation
	* `forwardingTargetForSelector:` transmition of forwarding target
	* `methodSignatureForSelector:` transmition of method signature
	* `respondsToSelector:` 

## Usage

* Demo FYI 

## License
`UIView+UIAppearance` is released under the MIT license. See LICENSE for details.

## Communication

<img src="./images/qq_1000.png" width=200><img style="margin:0px 50px 0px 50px" src="./images/wechat_1000.png" width=200><img src="./images/github_1000.png" width=200>
