<p align="center"><img src="images/IconPrettified.png" width="200"></p>

<p align="center">
    <img src="https://img.shields.io/badge/iOS-15.0+-blue.svg" />
    <img src="https://img.shields.io/badge/Xcode-13.1+-brightgreen.svg" />
    <img src="https://img.shields.io/badge/Swift-5.5-orange.svg" />
    <img src="https://img.shields.io/badge/SwiftUI-2.0-red.svg" />
</p>

# 🇬🇧 UK COVID-19 Statistics
This app was created with the intention of publishing to the AppStore.

The primary purpose of this app is to share information with the UK public in the hopes that people will change their behavior to help us all control the spread of this virus.

### 🏙 Screenshots

#### App

<img src="images/app.png" width="320"/>

#### Widget

<img src="images/widget.png" width="320"/>

#### Background Fetch Notification

<img src="images/notification.png" width="320"/>

### 😞 Rejection

<img src="images/rejection.png" width="356"/>

Understandably, Apple has rejected this app as it contains information regarding the COVID-19 pandemic.

Only recognised institutions are allowed to create apps relating to the pandemic to help curb misinformation.

> We found in our review that your app provides services or requires sensitive user information related to the COVID-19 pandemic. Since the COVID-19 pandemic is a public health crisis, services and information related to it are considered to be part of the healthcare industry. In addition, the seller and company names associated with your app are not from a recognized institution, such as a governmental entity, hospital, insurance company, non-governmental organization, or university.  

For more information: [Ensuring the Credibility of Health & Safety Information](https://developer.apple.com/news/?id=03142020a)

### 👨🏻‍💻 API

[https://coronavirus.data.gov.uk/developers-guide](https://coronavirus.data.gov.uk/developers-guide)

### 🧐 Features

- Widget showing latest daily cases and deaths
- 🔄 Automatically reload data every 15 minutes (from within the app, and widget data)
- 🔔 Fetch data every 15 minutes in the background (subject to iOS system rules for scheduling background tasks) and send a local notification upon detecting any changes
- 📈 Chart timescale can be changed (All data, 1 year, 6 months, 3 months, 1 month)
- Change dataset for (🇬🇧 UK, 🏴󠁧󠁢󠁥󠁮󠁧󠁿 England, Northern Ireland, 🏴󠁧󠁢󠁳󠁣󠁴󠁿 Scotland, 🏴󠁧󠁢󠁷󠁬󠁳󠁿 Wales)

### 👨🏻‍⚖️ Disclaimer

> I have decided to open source this app for the following reasons:
>
> - Transparency in the hopes that it might be approved for the AppStore one day
> - To share SwiftUI code with other iOS developers
> - To improve this app through contributions
> - In the hopes that other iOS developers may use the app themselves
> - To show how awesome SwiftUI is 🥳
