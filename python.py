#!/usr/bin/python

import os

os.environ['pHP']

if (int(os.environ['pHP']) >= 0):
        print("Game won!")
        print("You rescued the princess and live happily ever after!\n")

elif (int(os.environ['pHP']) <= 0):
        print("Game lost, better luck next time!\n")
