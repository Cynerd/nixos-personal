#!/bin/sh
{
	dmidecode -s system-uuid 
	dmidecode -s baseboard-serial-number
	dmidecode -s processor-version
} | sha512sum | cut -f1 -d ' '
