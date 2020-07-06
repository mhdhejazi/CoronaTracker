<img src="https://user-images.githubusercontent.com/121827/78813826-4709ac80-79d6-11ea-9406-247ebabd815b.png" height="175">

![iOS](https://img.shields.io/badge/iOS-10%20-blue)
![macOS](https://img.shields.io/badge/macOS-10.15-blue)
![Swift](https://img.shields.io/badge/Swift-5-orange?logo=Swift&logoColor=white)
<a href="https://twitter.com/intent/follow?screen_name=Hejazi"><img src="https://img.shields.io/badge/@hejazi-x?color=08a0e9&logo=twitter&logoColor=white" /></a>

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
   * __Daily new cases__ shows how fast the virus is spreading in a given country.
   * __Cases since the 100th case__ how fast the virus is spreading in different countries.
   * Option for using a __logarithmic__ scale.
* __Search__ for countries & cities.
* __Share__ stats & charts as images.
* __Today widget__ for worldwide stats.
* __Red color scale__: Reflects the number of confirmed cases. In addition to increasing circle size.
* __Statistics__: Including the number of confirmed, recovered, and deaths, in addition to percents.
* __iPad__ & __macOS__ support.

![image](https://user-images.githubusercontent.com/121827/77246980-a6796580-6c3d-11ea-80dd-57833a7c386a.png)
![image](https://user-images.githubusercontent.com/121827/77247007-03751b80-6c3e-11ea-91fc-b3d535fda6a2.png)

## How to Use
### 1. iOS & macOS App
#### Build from source code
1. Clone/Download the repo.
2. Open `Corona.xcodeproj` in Xcode.
3. Choose the right target (iOS or macOS).
4. Build & run!

### 2. macOS App
[Download the latest release](https://github.com/mhdhejazi/CoronaTracker/releases/latest) for macOS.

Or install via [brew](http://brew.sh):

  ```bash
  brew cask install corona-tracker
  ```

## Contribute
Please feel free to contribute pull requests or create issues for bugs and feature requests.

## Author
Mhd Hejazi <a href="https://twitter.com/intent/follow?screen_name=Hejazi"><img src="https://img.shields.io/badge/@hejazi-x?color=08a0e9&logo=twitter&logoColor=white" valign="middle" /></a> (contact@samabox.com)

## Credits
### Data
* Johns Hopkins University Center for Systems Science and Engineering ([JHU CSSE](https://github.com/CSSEGISandData/COVID-19))
* Robert Koch Institute ([RKI](https://experience.arcgis.com/experience/478220a4c454480e823b17327b2bf1d4/))
* Bundesministeriums für Soziales, Gesundheit, Pflege und Konsumentenschutz ([BMSGPK](https://experience.arcgis.com/experience/fb603473e1f74f0bbae48155ff238565/))
* Bing COVID-19 Tracker ([Bing](https://bing.com/covid/))

### Features
* Today widget by [Piotr Ożóg](https://github.com/pbeo).

### Data Sources
* State-level data for Germany by [Manuel Carrasco Molina](https://github.com/stuffmc).
* State-level data for Austria by [Patrick Steiner](https://github.com/patricks).

### Translations
* __German__ by [Sebastian Binder](https://github.com/sebastianbinder), [Jakob Fuchs](https://github.com/jsf030)
* __Swedish__ by [Swedish Power Tech AB](https://github.com/FluffyDev2019)
* __Portuguese__ by [Pedro Paulo Amorim](https://github.com/ppamorim)
* __Italian__ by [Ale](https://github.com/Ale111)
* __French__ by [Clément Knoderer](https://github.com/Risengan), [Paul de Laage](https://github.com/pdldm)
* __Russian__ by [Mikhail Akopov](https://github.com/wacumov)
* __Chinese, Simplified__ by [Erick Li](https://github.com/erickzli)
* __Spanish__ by [Emily Jewik](https://github.com/ejewik)
* __Japanese__ by [Sorachi Kato](https://github.com/dev-sora)
* __Polish__ by [Piotr Ożóg](https://github.com/pbeo)
* __Dutch__ by [Heidi Duchting](https://github.com/hdatteln)
* __Romanian__ by [Andrei Ciobanu](https://github.com/rhcpfan)
* __Korean__ by [Lee Gwang Yong](https://github.com/dev-yong)
* __Arabic__ by [Hussam Zain](https://github.com/hussamzain)
* __Norwegian Bokmål__ by [Allan Nordhøy](https://github.com/comradekingu)
* __Indonesian__ by [Niko Tidar Lantang Perkasa](https://github.com/nikotidar)
* __Danish__ by [Per Meldgaard](https://github.com/peme)
* __Chinese, Traditional (Taiwan)__ by [@League2EB](https://github.com/League2EB)
* __Turkish__ by [Nesim Tunç](https://github.com/nesimtunc)
* __Hungarian__ by [@BrotherLouie](https://github.com/BrotherLouie)
* __Ukrainian__ by [Valeriy Soglaev](https://github.com/ValeriySoglaev)
* __Albanian__ by [Lori K.](https://github.com/lor1x)
* __Greek__ by [Kyriakos Markakis](https://github.com/marquicodes)

### Libraries
* [CSV.swift](https://github.com/yaslab/CSV.swift): For parsing the CSV data file.
* [Charts](https://github.com/danielgindi/Charts): Beautiful and powerful charts.
* [FloatingPanel](https://github.com/SCENEE/FloatingPanel): For the bottom sheet.
* [Disk](https://github.com/saoudrizwan/Disk): Simplifies loading/saving files.
