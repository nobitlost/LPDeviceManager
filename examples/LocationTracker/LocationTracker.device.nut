// MIT License
//
// Copyright 2019 Electric Imp
//
// SPDX-License-Identifier: MIT
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

/**
 * The example implements sceleton of a Tracker application:
 *
 *
 * 1. Tracker in sleep:
 *  - No application or communication activity
 *  - GNSS and cellular modem powered down or in power-save mode.
 *  - Accelerometer configured to generate wakeup interrupt upon exceeding of configurable acceleration threshold.
 * 2. Wake for one of the following:
 *  - Check-In (periodic with configurable time period, i.e. 24 hours)
 *  - Acceleration (shock or movement)
 *  2.1. Check-In Wake:
 *      - Tracker wakes upon expiration of time period
 *      - Determine Location and accuracy (i.e. power up GNSS and using assist data), timestamp and battery level, other operational parameters (e.g. sensor values)
 *      - Connect to cloud agent (i.e. power up modem and connect to cellular network)
 *      - Send location, accuracy, timestamp, battery level, and other operational parameters to cloud agent
 *      - Receive any pending data from cloud agent
 *      - Sleep, back to #2
 *  2.2. Acceleration Wake:
 *      - Tracker wakes upon acceleration interrupt. Application logic determines if this is a relevant shock or movement event (may involve repeated sleep/wake-up cycles to determine). If not a relevant event, return to deep sleep.
 *      - Determine Location and accuracy (i.e. power up GNSS and using assist data), timestamp and battery level, other operational parameters (e.g. max acceleration value, sensor values)
 *      - Connect to cloud agent (i.e. power up modem and connect to cellular network)
 *      - Send location, accuracy, timestamp, battery level, and other operational parameters to cloud agent
 *      - Receive any pending data from cloud agent
 * 3. If movement event (beginning of transport cycle):
 *  - Set acceleration threshold to shock level to ignore ongoing movement until the next Check-In Wake.
 *  - In all cases:
 *  - Sleep, back to #2
 */
