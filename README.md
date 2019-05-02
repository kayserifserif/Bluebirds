# Climate Change Denial

A Twitter interface/visualisation based on Daniel Shiffman's flocking algorithm.

*Originally a final project about climate change denial for USC IML-288: Critical Thinking and Procedural Media with [John B. Carpenter](http://johnbcarpenter.com/). Exercises and explorations [here](https://github.com/whykatherine/climate-change-denial.git) and class repository [here](https://github.com/johnbcarpenter/USC_IML288).*

## Install
1. Download [Processing](https://processing.org/download/).
2. Download or clone this repository.

## Setup
1. Create a [Twitter Developer](https://developer.twitter.com/) account.
2. Create an [app](https://developer.twitter.com/en/apps/create).
3. Set up a [dev environment](https://developer.twitter.com/en/account/environments). Choose "Search Tweets: Full Archive / Sandbox".
4. In the `/data` folder, make a copy of `twitter4j-default.properties` called `twitter4j.properties`.
5. Populate `twitter4j.properties` with your keys and tokens.
6. Run the sketch in Processing!

## Libraries

* [Twitter4J](http://twitter4j.org/en/index.html) (included)
* [RiTa](https://rednoise.org/rita/) (install: Sketch > Import Library… > Add Library…)
* [ControlP5](http://www.sojamo.de/libraries/controlP5/) (install: Sketch > Import Library… > Add Library…)

## Usage

* When prompted, enter a search query to show 100 Tweets from the past 30 days.
* Hover over birds to isolate them by changing their flocking behaviour.
* Hold down on birds to show their full Tweet.
* Press enter while holding down on a Tweet to launch the URL.
* Hover over the a top word in the list to highlight birds containing that word.
* Hold down on a top word in the list to show full Tweets containing that word.
* Click Reset to search a new query.

## Inspiration

* [Flocking](https://processing.org/examples/flocking.html) by Daniel Shiffman