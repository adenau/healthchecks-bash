# healthchecks-bash

The following are a collection of Bash designed to use healthchecks.io as a light-weight monitoring system.

## What is healthchecks.io

As described in [their documentation](https://healthchecks.io/docs/), Healthchecks.io is a service for monitoring cron jobs and similar periodic processes. It works as a dead man's switch for processes that need to run continuously or on a regular, known schedule. 

It's easy to use, they have numerous integration and they offer a free account for anyone to start.

## Why do these script exist?

By design, healthchecks.io is a cron monitor. In other word, it sends our alerts when it doesn't receive a signal that a job was successfully completed. The following scripts take this concept to build a monitoring job. When installed as a cron job, for the resources it monitors, there are three possible outcome :

* The script completes succesfully, sending a signal to healthchecks.io
* The script detects a problem with the resources, sending a failure signal to healthchecks.io, which relays it to the user
* The script fails to run, healthchecks.io detects the lack of response and signals the failure to the user

## Why bash?

The idea was to make these as simple as possible to minimize dependencies. The original versions were in Python and had quite a few requirements.

## How do I setup a monitor?

1. You should signup for a free account on [healthchecks.io](https://healthchecks.io/docs/) if you don't have one already.
2. Create a check. The documentation can be found at : https://healthchecks.io/docs/configuring_checks/
3. Clone this repository.
4. Configure a check as a cron job. For example, I have the following line in my main servers crontab to monitor the server is online.

```
*/5 * * * *  root  /srv/healthchecks/check_online.sh 00000000-0000-0000-0000-000000000000
```

## Do these work with other dead man's switch system?

They can, with modification. You need to check if the system you chose supports a failure signal. If it does, most of your work will be to change the signaling system. If it doesn't, then you will need to change the system to avoid sending any signal at all in the case of a failure.
