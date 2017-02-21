#!/bin/sh

protoc --python_out=../../../mammoserver  mammogram_header.proto
protoc --objc_out=./ mammogram_header.proto