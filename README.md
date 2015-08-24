DockerCon US 2015 Compose demo
==============================


Requirements
------------

- Make
- VirtualBox
- Docker Machine
- Docker Compose


Preparation
-----------

1.  Revert any code changes:

        $ git reset --hard

2.  Ensure a machine called `dev` is running:

        $ docker-machine ls

    It should show something like this:

        NAME   ACTIVE   DRIVER       STATE     URL
        dev    *        virtualbox   Running   tcp://192.168.99.100:2376

    If there isn't a machine, create one:

        $ docker-machine create -d virtualbox dev

    If there is but it doesn't say "Running", start it:

        $ docker-machine start dev

3.  Open two terminal panes.

4.  In each terminal pane, point Compose at the machine by setting the relevant
    environment variables:

        $ eval "$(docker-machine env dev)"

5.  In one of the terminals, pull/build the images and clear out any existing
    containers:

        $ make


Script
------

Unless otherwise specified, commands are to be run in the first terminal pane.
You'll probably want to make the second one a bit smaller than the first.

1.  Show the contents of `app.py`:

        $ cat app.py

    Things to point out:

    - We're using the Flask Python library to write a very simple webapp.
    - It connects to a Redis instance at the hostname "redis".
    - It pulls a custom greeting message out of an environment variable.
    - On each request, it increments a counter, and then displays our custom
      greeting, along with the counter's current value.

2.  Show the contents of the `Dockerfile`:

        $ cat Dockerfile

    Things to point out:

    - We start from the official Python 2.7 image on the Docker Hub.
    - We install our required Python libraries, flask and redis.
    - We add our code into the image and install our dependencies.
    - We set the container's command to run the Python file we just saw.

3.  Show the contents of `docker-compose.yml`:

        $ cat docker-compose.yml

    Things to point out:

    - We define two services, web and redis.
    - The web service uses an image created by building from the Dockerfile we
      just saw.
    - It exposes port 5000 on the host.
    - It links to the redis container, which is what creates that "redis"
      hostname that `app.py` connects to.
    - We set the greeting environment variable to "Hello World!".
    - The redis service just uses the official redis image from the Docker Hub.

4.  With those three files, we're ready to go:

        $ docker-compose up

    Things to point out:

    - We've already got the web image built and the redis image pulled (we don't
      want to rely on conference wifi!), but if we didn't, Compose would build
      and pull them automatically.
    - Compose knows to start the redis container first, followed by the web
      container, because web depends on redis.
    - Compose has started both containers and is streaming their logs in a
      single terminal.

5.  In the second terminal, run:

        $ docker-machine ls

    Point out that we've used Docker Machine to provision a local VM running
    the Docker daemon. That's what our two containers are running on right now.

6.  Type this out but don't run it yet. Point out that we're using Docker
    Machine to grab the IP address of the machine.

        $ curl http://$(docker-machine ip dev):5000

7.  Run it. It should print out "Hello World! I have been seen 1 times."

    The first terminal should print a log message from the Python app saying
    it's been hit.

    Run the same command a few more times. It should show the counter
    incrementing.

8.  Close the second terminal.

9.  Back in the first terminal, stop Compose with Ctrl-C. Now run it in detached
    mode:

        $ docker-compose up -d

10. Show the containers running:

        $ docker-compose ps

11. Update `docker-compose.yml` to change the greeting:

        $ vim docker-compose.yml

    Find the "GREETING: Hello World!" line and change it to something else, e.g.
    "GREETING: Hello DockerCon!"

12. Hit the app again, to show that it hasn't updated yet:

        $ curl http://$(docker-machine ip dev):5000

    It should still print "Hello World!".

13. Because we've made a change to the environment variables, we need to
    recreate the container:

        $ docker-compose up -d

14. Hit the app again, to show that it has now updated:

        $ curl http://$(docker-machine ip dev):5000

    It should now print the updated greeting.

15. Point out that each time we run `docker-compose up -d`, we're recreating
    both the redis AND the web containers, which is unnecessary - nothing about
    the redis configuration has changed. You can run the command a few more
    times to drive the point home.

    We've got an experimental new feature that addresses this, though!

    Run:

        $ docker-compose up -d --x-smart-recreate

    It should say that both containers are up-to-date - i.e. it hasn't done
    anything.

16. Make another change to `docker-compose.yml` to update the greeting, e.g. to
    "GREETING: Hello DockerCon 2015!". Run Compose again:

        $ docker-compose up -d --x-smart-recreate

    It should first say that redis is up-to-date, and then recreate web.

17. Check that the greeting has updated again:

        $ curl http://$(docker-machine ip dev):5000

18. Run `up` one more time:

        $ docker-compose up -d --x-smart-recreate

    It should once again say that both containers are up-to-date.
