# Haunts
An app for having private, ephemeral digital experiences with those around you, anywhere.

## Overview

This app is an exploration of the unique experiences enabled by mesh networks as my thesis project for [NYU Interactive Telecommunications Program](http://itp.nyu.edu). The app enables a communal doodling experience with no need for infrastructure WiFi. It uses Apple's Multipeer Connectivity to enable peer-to-peer communication, and implements a very simple mesh flooding protocol to synchronize the canvas across devices.

The hope is to demonstrate that meshes provide alternative experiences for digital connectivity that doesn't require intermediate services. The app assumes that the users want an off-the-record experience, deleting by default rather than saving by default. Furthermore, the app locks any saved drawing to the location they were drawn in, to encourage people to associate the location and the community around it in these impromptu experiences.

## Features
* Connect to nearby instances to doodle collaboratively.
* A rich palette of three colors to draw with
* Collaborative canvases can be saved if two or more people agree to save it by pressing the disk button.
* Anyone can block saving by pressing the X button, forcing communitiy consensus in the saving action.
* Canvases are saved to the general GPS location, and you must be in that location to view them. 
* If there is no GPS signal available, canvases are saved in a special location called "nowhere."



Icons by [Freepik](www.freepik.com)
