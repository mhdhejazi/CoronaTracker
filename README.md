<img src="https://user-images.githubusercontent.com/121827/76558431-5e747900-64ae-11ea-9168-2091a431773a.png" width="127">

# Corona Tracker 
Coronavirus tracker app for iOS & macOS with map &amp; charts.

![iOS](https://img.shields.io/badge/iOS-10%20-blue)
![macOS](https://img.shields.io/badge/macOS-10.15-blue)
![Swift](https://img.shields.io/badge/Swift-5-orange?logo=Swift&logoColor=white)
![image](https://user-images.githubusercontent.com/121827/76356430-fe06ff80-6326-11ea-8107-60f900a73016.png)

## Features
* __Live data__: Shows the most recent data, and updates automatically.
* __Distribution map__ with two levels of details:
  * __Countries__: When the user zooms out. Fewer details and reduced clutter.
  * __Cities__: When the user zooms in. More details.
* __Red color scale__: Reflects the number of confirmed cases. In addition to increasing circle size.
* __Statistics__: Including the number of confirmed, recovered, and deaths, in addition to percents.
* __Current state chart__ for all countries (and cities).
* __Timeline chart__ for all countries (and cities).
* __Top affected countries__ chart with info about every country.
  * Option for using a __logarithmic__ scale.
* __iPad__ support (portrait & landscape).
* __macOS__ support.
* Works on old devices that still run __iOS 10__.

<details>
  <summary><b>Screenshots</b></summary> 
  <img src="https://user-images.githubusercontent.com/121827/76356895-bd5bb600-6327-11ea-8433-06bede40a799.png" />
  <img src="https://user-images.githubusercontent.com/121827/76235095-af306b80-623b-11ea-89df-5e5942318935.png" />
</details>

## How to Use
1. Clone/Download the repo.
2. Open `Corona.xcodeproj` in Xcode.
3. Choose the right target (iOS or macOS).
4. Build & run!

Or [download the latest release](https://github.com/MhdHejazi/CoronaTracker/releases/latest) for macOS.

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
* [PKHUD](https://github.com/Hengyu/PKHUD): For the activity indicator.
