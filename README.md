# LocationTracker

An iOS App that is storing your phone's location history locally.

It doesn't connect to any backend server, the only way when the data leaves your device (beside iPhone backups) is when you enable Dropbox backup, in which case it is uploaded to your dropbox account.

This app is written in Swift and designed to do as little as possible, because your iPhone will load the app into memory on each signification location update. In order to minimize battery usage, the footprint of this app is tiny and all it does is storing that location in CoreData locally on the device. There is a minimal UI for rendering your history on a day-to-day basis, but the main use-case is that you are exporting that data via dropbox and using it elsewhere.

When using it on a daily basis, accuracy is best in areas with good cell coverage (because the app only uses cell towers for location, rather than GPS to preserve battery life). On my day to day tests it was consuming <1% of the phone's battery throughout the day.
