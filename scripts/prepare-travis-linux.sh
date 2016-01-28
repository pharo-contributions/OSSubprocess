#!/bin/bash -x

set -e # exit on error

#install 32 bit libs if necessary
case "$(uname -m)" in
	"x86_64")
		echo "64bit os"
			# 32-bit VM
			sudo apt-get -qq update
			sudo apt-get -qq install libc6:i386
			# UUIDPlugin
			sudo apt-get -qq install libuuid1:i386
			# SqueakSSL
			sudo apt-get -qq install libkrb5-3:i386 libk5crypto3:i386 zlib1g:i386 libcomerr2:i386 libkrb5support0:i386 libkeyutils1:i386
			# Pharo specific
			sudo apt-get -qq install libssl1.0.0:i386
			# libFT2Plugin
			sudo apt-get -qq install libfreetype6:i386
			;;
		*)
			echo "32bit os"
			;;
esac
