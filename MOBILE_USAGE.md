# Run tests on mobile

This is a step-by-step guide on how to run tests on mobile devices such as 
Android and iOS using a PC as companion device.

Open landing page on mobile device:  
URL `http://<host>:<port>/_wave/index.html`,  
e.g. `http://192.168.1.170:8000/_wave/index.html`

![mobile landing page](./assets/landing-page-top.jpg)

Scroll down to see the session token

![mobile landing page token](./assets/landing-page-config.jpg)

On companion device,  
visit `http://<host>:<port>/_wave/configuration.html`  
e.g. `http://192.168.170:8000/_wave/configuration.html`

![pc configuration landing](./assets/config-landing.jpg)

Enter first 8 characters of token from mobile

![pc enter token](./assets/config-enter-token.jpg)

Press "Configure Session"

![pc configure session](./assets/config-groups.jpg)

Press "None" to deselect all tests

![pc deselect](./assets/config-deselected.jpg)

Press on group name to open test list

![pc group list](./assets/config-selected.jpg)

Select the tests that shall be executed

![pc start session](./assets/config-start-session.jpg)

At the bottom, press "Start session"

![pc results started](./assets/results-started.jpg)

The view changes to the results overview. Results are updated automatically.

![mobile pre test](./assets/pre-test.jpg)

On mobile, a pre test page is shown for about 5 seconds

![mobile running test](./assets/running-test.jpg)

Tests are being executed

![mobile tests finished](./assets/session-complete.jpg)

After all tests have been run, a screen shows "Session Complete"

![pc results finished](./assets/results-finished.jpg)

On the companion screen, test results are received. Press "json" or "report" to get the results
