# Vikanoid 2
A game written in Assembly for the unexpected VIC-20.
![screenshot](https://sdesros.ca/vic20/content/vicanoid2-16.png)

# About the game
This is the first game I wrote in Assembly drawing inspiration from the (8 bit show and tell)[https://www.youtube.com/c/8bitshowandtell] videos about assembly programming for C=64.  I started to work on a follow-up to my last VIC-20 game written in basic back in 1987 [Vikanoid](https://github.com/sdesros/VICanoid)

The levels are all different.

# Instructions
* Get a highest score while trying to clear all 8 levels of the game on a continous loop.
* Move the paddle using cursor down for left, cursor right for right.
* Special blocks
  * Checked boxes will reverse the ball's direction
  * "P" will award 500 points.
  * "E" will "explode" the surrouding blocks.
  * "F" will change the paddle to an up arrow.
    * Move the arrow using the same controls
    * Hitting "return" will fire a laser clearing all of the blocks on top and resume the game play as normal
* The ball speeds up after hitting the paddle 10 times
* Adds 3 lives on clearing the board (max 9)
* Hitting "1-8" on the title screen will start the game at that level.

# How to build
This repository includes a project in [CBM Prg Studio](http://www.ajordison.co.uk/) a windows IDE for various Commodore 8 bit computers.

Levels.sdd includes all of the gameplay levels.

# How to runS
Either build or download the .prg file(s) to run in an emulator or load into a real VIC-20 via SDIEC or other means.

Game is also available to play or download on: https://sdesros.ca/vic20/?gamefile=vicanoid2-16
