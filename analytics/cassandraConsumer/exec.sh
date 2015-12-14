#!/bin/bash
GRADLE_OPTS=-Xmx256m gradle run -Dexec.args="localhost:2181/ 0 tweetscassandra 1 127.0.0.1 datacenter1"