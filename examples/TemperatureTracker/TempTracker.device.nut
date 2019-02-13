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
 * 2. Wake for one of the following:
 *  - Check-In (periodic with configurable time period, i.e. 24 hours)
 *  2.1. Check-In Wake:
 *      - Tracker wakes upon expiration of time period
 *      - Determine temperature; if the temperature exceeds the predefined threshold value, creates an alert
 *      - Connect to cloud agent (i.e. power up modem and connect to cellular network)
 *      - Send location, accuracy, timestamp, battery level, and other operational parameters to cloud agent
 *      - Receive any pending data from cloud agent
 *      - Sleep, back to #2
 */

#require "HTS221.device.lib.nut:2.0.1"
#require "ConnectionManager.lib.nut:3.1.0"
@include __PATH__ + "/../../LPDeviceManager.device.lib.nut"

// Wake up period for the tracker to report data
const WAKE_UP_PERIOD_SEC = 15;
const TEMP_HUM_SENSOR_I2C_ADDR = 0xBE;

class Tracker {

    _debug      = null;
    _lp         = null;
    _tempHumid  = null;
    _values     = null;

    constructor(lp) {
        _lp = lp;
        _initHW();
        _values = _readSensor();
        _lp.onConnect(function() {
            _lp.doAndSleep(_sendReadings.bindenv(this), WAKE_UP_PERIOD_SEC);
        }.bindenv(this));
    }

    function _initHW() {
        _log("Init hardware...");
        local i2c = hardware.i2cKL;
        i2c.configure(CLOCK_SPEED_400_KHZ);
        _tempHumid = HTS221(i2c, TEMP_HUM_SENSOR_I2C_ADDR);
        _tempHumid.setMode(HTS221_MODE.ONE_SHOT);
    }

    function _sendReadings() {
        if ("temperature" in _values && "humidity" in _values) {
            server.log("values: temp = " + _values.temperature + " humi = " + _values.humidity);
        } else {
            server.log("Error reading the sensor...");
        }
        agent.send("reading", _values);
    }

    function _readSensor() {
        local result = _tempHumid.read();
        if ("error" in result) {
            server.error("An Error Occurred: " + result.error);
            return;
        }
        return {
            "humidity" : result.humidity,
            "temperature" : result.temperature
        };
    }

    function _log(msg) {
        if (server.isconnected() && _debug) {
            server.log(msg);
        }
    }
}

local cm = ConnectionManager({
    "blinkupBehavior" : CM_BLINK_ALWAYS
})

local lp = LPDeviceManager(cm);
app <- Tracker(lp);
lp.connect();