# Brainfood 
![Swift version](https://img.shields.io/badge/swift-5.0-orange.svg)
![Platforms](https://img.shields.io/badge/platforms-iOS%20-lightgrey.svg)

****

Brainfood is an online food ordering system for people that need special dietary care.. (Continually updating)

## Demo

<img src=https://media.giphy.com/media/d8tprMnunZi2QEXedZ/giphy.gif width="250"> <img src=https://media.giphy.com/media/KbeKvWft1z6sN4ick0/giphy.gif width="250">

<img src=https://mononster.github.io/doordash_demo/11.png width="200"> <img src=https://mononster.github.io/doordash_demo/13.png width="200"> <img src=https://mononster.github.io/doordash_demo/12.png width="200"> <img src=https://mononster.github.io/doordash_demo/14.png width="200">

## Getting Started

```bash
$ cd Brainfood/
$ pod install
$ open .
Open Brainfood.xcworkspace
```

## Architecure 

[Coordinator](http://khanlou.com/2015/10/coordinators-redux/) + [VIP (Clean Swift Archtecture)](https://hackernoon.com/introducing-clean-swift-architecture-vip-770a639ad7bf) + MVVM

* ApplicationEnvironment to handle app's different environments, i.e. staging, localhost, production.
* ApplicationDependency to handle things that uses in the lifecyle of the app
* AppCoordinator to handle the top navigation logic of the app.
* ApplicationSettings to store client controlled feature flags.
* CoreData + Keychain to store user info.
* Alamofire + Moya for network layer.

## Implemented components

* Parallax scrolling -> See item detail page.
* Fixed point customized slider -> See rating at delivery page.
* Page scroll menu. -> See store detail page.
* IGListKit - Embeded section controllers -> See delivery page, entirely based on embeded controllers.
* Add Stripe Card -> See add payment page.
* Search with different states -> See search address page.
* MapKit, pin appear/selected animations. -> See pickup map page.

## Anything else I can do with this clone?

* Use existing models and make orders from command line.
* Remove the features you don't like and build your completely customized brainfood experience.
* More and more...

## Feature Check List
- [x] Delivery Page
- [x] Pickup Map
- [x] Account Page
- [x] Onboarding
- [x] Add/Change/Select Delivery Address
- [x] Add Payments
- [x] CRUD Order Cart 
- [x] Store Detail Page
- [x] Item Detail Page
- [x] Login/Logout
- [ ] Group Order
- [ ] In Order View
- [ ] Search Restaurant
- [ ] View My Orders

## License

Brainfood is [BSD 3-Clause Licensed](https://opensource.org/licenses/BSD-3-Clause)

Copyright (c) 2019, the respective contributors, as shown by the AUTHORS file.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

