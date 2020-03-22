<img src="https://user-images.githubusercontent.com/121827/76558431-5e747900-64ae-11ea-9168-2091a431773a.png" width="127">

# Corona Tracker 
Coronavirus tracker app for iOS & macOS with map &amp; charts.

![iOS](https://img.shields.io/badge/iOS-10%20-blue)
![macOS](https://img.shields.io/badge/macOS-10.15-blue)
![Swift](https://img.shields.io/badge/Swift-5-orange?logo=Swift&logoColor=white)

![image](https://user-images.githubusercontent.com/121827/77246699-e25efb80-6c3a-11ea-8a49-30bd87ff33c0.png)

## Features
* __Live data__: Shows the most recent data, and updates automatically.
* __Distribution map__ with two levels of details:
  * __Countries__: When the user zooms out. Fewer details and reduced clutter.
  * __Cities__: When the user zooms in. More details.
* __Charts__:
   * __Current state chart__ for all countries (and cities).
   * __Timeline chart__ for all countries (and cities).
   * __Top affected countries__ chart with info about every country.
  * Option for using a __logarithmic__ scale.
* __Search__ for countries & cities.
* __Share__ stats & charts as images.
* __Today widget__ for worldwide stats (Contributed by [Piotr Ożóg](https://github.com/pbeo)).
* __Red color scale__: Reflects the number of confirmed cases. In addition to increasing circle size.
* __Statistics__: Including the number of confirmed, recovered, and deaths, in addition to percents.
* __iPad__ & __macOS__ support.

![image](https://user-images.githubusercontent.com/121827/77246980-a6796580-6c3d-11ea-80dd-57833a7c386a.png)
![image](https://user-images.githubusercontent.com/121827/77247007-03751b80-6c3e-11ea-91fc-b3d535fda6a2.png)

## How to Use
### 1. iOS App
#### Build from source code
1. Clone/Download the repo.
2. Open `Corona.xcodeproj` in Xcode.
3. Choose the right target (iOS or macOS).
4. Build & run!

### 2. macOS App
[Download the latest release](https://github.com/MhdHejazi/CoronaTracker/releases/latest) for macOS.

Or install via [brew](http://brew.sh):

  ```bash
  brew cask install corona-tracker
  ```

## Contribute
Please feel free to contribute pull requests or create issues for bugs and feature requests.

## License
The app is available for personal/non-commercial use. It's not allowed to publish, distribute, or use the app in a commercial way.

## Author
Mhd Hejazi (contact@samabox.com)

## Credits
### Data
Data is provided by JHU CSSE (https://github.com/CSSEGISandData/COVID-19).

### Libraries
* [CSV.swift](https://github.com/yaslab/CSV.swift): For parsing the CSV data file.
* [Charts](https://github.com/danielgindi/Charts): Beautiful and powerful charts.
* [FloatingPanel](https://github.com/SCENEE/FloatingPanel): For the bottom sheet.
* [Disk](https://github.com/saoudrizwan/Disk): Simplifies loading/saving files.
