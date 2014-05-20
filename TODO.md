# TODO

* Fix bug in current scheduling system that sometimes gets the show dates wrongly because some ical flags are being ignored (possibly an upstream bug that needs to be addressed)
* Convert schedule system to using the gdata API for reading calendars rather than scraping RSS
* Update to work with ruby 2.x
* Remove the dependency on therubyracer.
    * one of the other execjs alternatives may work, just needs some testing to ensure there are no issues.
* Correct htmlentities parsing in the twitter module.
* Convert the twitter module to the streaming API instead of polling
* Add a Youtube module to push release notices to the IRC channel.
* Add a RSS module to push JB site releases to the IRC channel.
* Add the sed module to the repo and correct its broken functionality.
    *  Users can currently use sed on other users text and there is also no limit to the sed length, which causes spam issues.
* Write a small web frontend with user accounts to control data.json and and/remove from shows.json