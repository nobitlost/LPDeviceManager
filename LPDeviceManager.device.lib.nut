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

/** Default timeout for asynchronous functions execution */
const LP_DEFAULT_TIMEOUT_SEC = 10;

/**
 * The device-side library for low-power device and task management
 *
 * NOTE: 1) the library can be instantiated only once, it should be treated as a singleton.
 * NOTE: 2) Required changes for ConnectionManager (DONE in https://github.com/electricimp/ConnectionManager/pull/29):
 *          2.1. Allow for named onConnect/onDisconnect handlers. CM would allow for multiple
 *              handlers to registered/unregistered by handler names.
 *          2.2. Make server.flush(flushTimeout); optional, i.e. flushTimeout == -1 means no flush.
 * NOTE: 3) imp.onidle should not be used along with the library (as there is a chance they will be overwritten)
 *
 * @class
 */
class LPDeviceManager {

    /** @member {integer} - the stored wakeup reason */
    _wakeupReason = null;

    /** @member {ConnectionManager} - and optional instance of ConnectionManager */
    _cm = null;

    /** @member {function} - onSwReset callback to be triggered on imp.reset() or an OOM event */
    _onSwReset = null;

    /** @member {function} - onHwReset callback to be triggered on booting up after the restart by RESET_L pin */
    _onHwReset = null;

    /** @member {function} - onTimer callback to be executed after "deep" sleep time expired */
    _onTimer = null;

    /** @member {function} - onColdBoot callback to be executed on powered on (cold boot) */
    _onColdBoot = null;

    /** @member {function} - onInterrupt callback to be triggered on a wakeup pin toggled */
    _onInterrupt = null;

    /** @member {function[]} - array of onIdle handlers to be called */
    _onIdleCbs = null;

    /** @member {boolean} - controls the debug output of the library */
    _isDebug = null;

    /**
     * Initializes the library
     * @param {ConnectionManager} cm - an instance of ConnectionManager library
     * @param {table} config - configuration parameters:
     *          @tableEntry {boolean} POWER_SAVE - specifies whether the power save mode should be enabled
     */
    constructor(cm, config = {}) {
        const __RM_CALLBACK_NAME = "rm-callback";
        _cm = cm;
        _onIdleCbs = [];
        _wakeupReason = hardware.wakereason();

        imp.wakeup(0, _dispatchEvents.bindenv(this));
    }

    /**
     * Registers a callback to be executed on powered on (cold boot)
     */
    /**
     * The callback that's triggered when device cold boots
     * @callback
     */
    function onColdBoot(callback) {
        _onColdBoot = callback;
    }

    /**
     * Registers a callback to be executed on a software reset
     * (eg. with imp.reset()) or an out-of-memory error occurred
     */
    /**
     * The callback that's triggered when device cold boots
     * @callback
     */
    function onSwReset(callback) {
        _onSwReset = callback;
    }

    /**
     * Registers a callback to be executed after "deep" sleep time expired
     * (set via imp.deepsleepfor() or server.sleepfor() calls).
     */
    function onTimer(callback) {
        _onTimer = callback;
    }

    /**
     * Registers a callback to be triggered on a wakeup pin.
     */
    /**
     * The callback that's triggered when device cold boots
     * @callback
     */
    function onInterrupt(callback) {
        _onInterrupt = callback;
    }

    /**
     * Adds an action to be called on idle. The imp should not go to sleep until there is a least one
     * item in the onIdle list.
     */
    function addOnIdle(callback) {
        // reset the onidle handler
        imp.onidle(_processOnIdle.bindenv(this));

        if (_onIdleCbs.find(callback) != null) {
            return; // the item already exists
        }
        if (_isFunc(callback)) {
            _onIdleCbs.append(callback);
            return;
        }
        _err("Invalid callback type");
    }

    /**
     * Synchronously executes the specified action(s) and goes to deep sleep for the specified period of time.
     *
     * @param {function} actions - an action function to be fulfilled before we go to sleep. The function takes no arguments.
     * @param {integer} sleepTime - specified the time the device is going to sleep for after the actions are all fulfiled
     */
    // TODO: needs a lot of good examples covering all the edge use cases
    function doAndSleep(action, sleepTime) {
        _isFunc(action) && action();
        sleepFor(sleepTime);
    }

    /**
     * Schedules asynchronous execution of the specified action(s),
     * when the actions are done, goes to deep sleep for the specified period of time.
     * The device goes to sleep on whichever earlier occurs: the timeout or the action has completed.
     *
     * @param {action-callback} action - an action function to be fulfilled before we go to sleep
     * @param {float} sleepTime - specified the time the device is going to sleep for after the actions are all fulfiled
     * @param {float} timeout - the action timeout
     */
    /**
     * The function that implements an action to be performed.
     *
     * @callback action-callback
     * @param {function} done - the function to be called by the action when done.
     */
    function doAsyncAndSleep(action, sleepTime, timeout = LP_DEFAULT_TIMEOUT_SEC) {
        local timeoutTimer = imp.wakeup(timeout, function() {
            sleepFor(sleepTime);
        });

        local done = function() {
            imp.cancelwakeup(timeoutTimer);
            sleepFor(sleepTime);
        }

        _isFunc(action) && action(done);
    }

    /**
     * Sleeps for the specified period of time
     */
    function sleepFor(sleepTime) {
        addOnIdle(function() {
            server.sleepfor(sleepTime);
        });
    }

    /**
     * Attempts to establish a connection between the imp and the server.
     */
    function connect() {
        _cm.connect();
    }

    /**
     * Disconnects the imp from the server and turns the radio off
     */
    function disconnect() {
        _cm.disconnect(true);
    }

    /**
     * Registers a callback to be executed on successfull connection to the server
     * @param {onConnect-callback} callback -  a function to be called when device is connected
     * @param {string} cbName - an optional callback name that can be used to register multiple callbacks
     */
    /**
     * The callback to be executed when device connects. Have no parameters.
     * @callback onConnect-callback
     */
    function onConnect(callback, cbName = __RM_CALLBACK_NAME) {
        _cm.onConnect(callback, cbName);
    }

    /**
     * Registers a callback to be executed on disconnect or an error occurred during connection attempt.
     * @param {onDisconnect-callback} callback -  a function to be called when device is disconnected
     * @param {string} cbName - an optional callback name that can be used to register multiple callbacks
     */
    /**
     * The callback to be executed when device connects. Have no parameters.
     * @callback onDisconnect-callback
     * @param {boolean} expected - specifies if the disconnect was intentional, i.e triggered by the user
     */
    function onDisconnect(callback, cbName = __RM_CALLBACK_NAME) {
        _cm.onDisconnect(callback, cbName);
    }

    function _dispatchEvents() {
        switch (_wakeupReason) {
            case WAKEREASON_POWER_ON:
                _isFunc(_onColdBoot) && _onColdBoot();
                break;
            case WAKEREASON_TIMER:
                _isFunc(_onTimer) && _onTimer();
                break;
            case WAKEREASON_SW_RESET:
                _isFunc(_onSwReset) && _onSwReset();
                break;
            case WAKEREASON_PIN:
                _isFunc(_onInterrupt) && _onInterrupt();
                break;
            case WAKEREASON_HW_RESET:
                _isFunc(_onHwReset) && _onHwReset();
                break;
        }
    }

    function _processOnIdle() {
        foreach (cb in _onIdleCbs) {
            cb();
        }
    }

    function _isFunc(f) {
        return f != null && typeof f == "function";
    }

    function _isConnected() {
        return _cm.isConnected();
    }

    function _log(msg) {
        if (_isDebug && _isConnected()) {
            server.log("  [LP]: " + mgs);
        }
    }

    function _err(msg) {
        if (_isConnected()) {
            server.error("  [LP]: " + msg);
        }
    }
}
