# Acme Mobile Browser 
Hello Neeva team. This is my take on the Acme Mobile Browser project. Enjoy :)


# How to Run
Simply open my project in xCode and run. Note that the QR code scanning functionality won't be usable unless you are running on an actual iOS device.


# Additional Features
I decided to implement something other than what was suggested. I thought of many ideas, but ultimately decided on a QR code scanner which allows you to open URL's. I think this is a great addition to the web browser especially given that many restaraunts and businesses nowadays are using QR codes due to COVID.

# My Approach
My approach to this project was to first try to implement it with SwiftUI. SwiftUI is a really cool framework but is relatively new. I was having a bit of difficulty dealing with the automatic updating of tabs, so I pivoted to using UIKit. I then messed around with WKWebView until I was able to add, reload, and go backwards on a single tab. 

After this, I added functionality for multiple tabs, error handling, and QR code scanning functionality. After all the basics were complete, I moved on making the experience better. I added support for loading URL's without a specific protocol (HTTP or HTTPS). I also added support for automatic google search directly in the search bar.



