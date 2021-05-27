## [6.5.12] - 2021-05-27
### Added
- Ad insertion type

## [6.5.11] - 2020-11-13
### Removed
- Arm64 arch from simulators 

## [6.5.10] - 2020-10-30
### Fixed
- Podspec dependencies

## [6.5.9] - 2020-10-27
### Changed
- Google Ima Ads SDK minimum version to 3.13.x
- GoogleAds-IMA-iOS-SDK minimum version to 4.3.x
- Increases the minimum runtime version to tvOS 10 

## [6.5.8] - 2020-10-20
### Fixed
- Fix a memory leak in IMA adapter

## [6.5.7] - 2020-09-28
### Fixed
- Don't trigger new views when post-roll starts on IMA

## [6.5.6] - 2020-09-14
### Changed
- Google Ima Ads SDK minimum version to 3.12.1

## [6.5.5] - 2020-06-09
### Changed
- Google Ima Ads SDK minimum version to 3.11.4

### Removed
- IOS_RUNTIME_TOO_OLD error code that's no longer supported by google ima

## [6.5.4] - 2020-05-06
### Added
- Send start and pause events when ad break start and stop

## [6.5.3] - 2020-02-24
### Added
- Dai and Ima Dai support to tvOS
- README.md

### Deprecated
- YBIMADAIAdapterSwiftWrapper
- YBIMAAdapterSwiftWrapper

## [6.5.2] - 2020-02-06
### Updated
- Add tranformers to make adapter compatible with Swift

## [6.5.1] - 2020-02-05
### Fixed
- Youbora lib imports

## [6.3.1] - 2019-02-01
### Fixed
- Wrong display version number

## [6.3.0] - 2019-02-01
### Updated
- Update all dependencies to last YouboraLib 6.3
- Minimum version required now is iOS 9.0

### Fixed
- Remove allAdsCompleted from DAI too

## [6.0.10] - 2019-01-22
### Fixed
- It is posible that the pings stopped when all ads finished, now it's imposible

## [6.0.9] - 2018-06-20
### Fixed
- No need to call initAdapterIfNecessary on the wrappers

## [6.0.8] - 2018-05-24
### Fixed
- Ad positions for live
- Posible crash when ad completed on live
- Join time always before first adStart

## [6.0.7] - 2018-04-23
### Remove
- Remove ad pause and resume

## [6.0.6] - 2018-04-17
### Add
- DAI support

## [6.0.5] - 2017-12-22
### Added
- Ad served metric

## [6.0.4] - 2017-12-04
### Added
- FireAllAdsCompleted
- RemoveAdapter method
- Multicast support
- Wrapper for swift applications

## [6.0.3] - 2017-11-14
 - Update to YouboraLib 6.0.3
 
## [6.0.2] - 2017-11-07
- Update to YouboraLib 6.0.1
 
## [6.0.1] - 2017-11-06
- Cocoapods files cleanup

## [6.0.0] - 2017-11-03
- Release version
