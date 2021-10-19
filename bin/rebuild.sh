#!/bin/sh
  
cd /var/discourse
./launcher rebuild app
'y' | ./launcher cleanup