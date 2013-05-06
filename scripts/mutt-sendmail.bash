#!/bin/bash
tee >(muttqt -f) | sendmail $*
