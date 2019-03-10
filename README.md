# Testing: argue-with-ar-ios 🍏
A minimal test app for live image recognition using ARKit2.
<br /><br />
**Note: You can find another version of this where the prototype but not the testing is in the foreground [here](https://github.com/hendriku/argue-with-ar-ios/).**

Also check out the [android version](https://github.com/ConSpr/argue-with-ar-android/tree/testing) of this project.

## Usage
The app starts and tries to recognize an image. If there has been no image detected for 15 seconds the app will exit.
Run the script `test.sh <amount> <exportfile>` like that:

```
./test.sh 100 earth-D-brightlight-whitebg-portrait.log
```

And you will have a `.csv` export of the recognitions in the defined file.
The app will restart every time it closes itself and will do this until the defined amount of tests is reached.

## Test conditions

|Condition|Decription|
|------|----------|
|Images|There are four different imagesets. Some are similar some are distinct in terms of lightning, perspective or appearance.|
|Light|We tested three different types of lightning conditions. Bright (300 lux), normal (120 lux) and dark (20 lux).|
|Background|Tests were executed on restful and noisy backgrounds.|
|Device orientation|The devices werde tested in landscape and portrait orientation|

## Test metrics
|Metric|Decription|
|------|----------|
|Speed|Time the device on a tripod needs from orienting to recognizing an image.|
|Recognition rate|Determines whether the device recognices the imageset at all.|

In the case study the test metrics were measured on a base of 100 test executions for each set of test conditions.

### Credits
This project was started for our case study on DHBW Stuttgart.<br /><br />
[ConSpr](https://github.com/ConSpr),
[hendriku](https://github.com/hendriku)
