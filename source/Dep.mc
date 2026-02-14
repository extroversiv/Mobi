using Toybox.Communications;
using Toybox.WatchUi;
using Toybox.System;
import Toybox.Lang;

class Dep extends WatchUi.BehaviorDelegate {
  private const RESULTS as Array = [2, 3, 5, 10, 15, 20, 30, 40];
  private const HEADER as Dictionary = $.Tools.getRequestGet();
  private var _pageManager as $.PageManager;
  private var _notify as (Method(text as Array<String> or String));
  private var _show as (Method(text as Array<String>));
  private var _url as String = "";
  private var _params as Dictionary = {};
  private var _forceExit = false;
  private var _retryN as Number = 0;

  function initialize(
    pageManager as $.PageManager,
    notify as (Method(text as Array<String> or String)),
    show as (Method(text as Array<String>))
  ) {
    WatchUi.BehaviorDelegate.initialize();
    _pageManager = pageManager;
    _notify = notify;
    _show = show;
  }

  function onSelect() as Boolean {
    if (_forceExit) {
      System.exit();
    }
    start();
    return true;
  }

  function onBack() as Boolean {
    if (_forceExit) {
      System.exit();
    }
    WatchUi.switchToView(new $.MenuView(), new $.Menu(), WatchUi.SLIDE_RIGHT);
    return true;
  }

  function onNextPage() as Boolean {
    if (_pageManager.increment()) {
      WatchUi.requestUpdate();
    }
    return true;
  }

  function onPreviousPage() as Boolean {
    if (_pageManager.decrement()) {
      WatchUi.requestUpdate();
    }
    return true;
  }

  function start() as Void {
    _pageManager.reset();
    _retryN = 0;
    makeRequest();
  }

  private function makeRequest() as Void {
    if (_retryN == 0) {
      _notify.invoke("loading departures ...");
    }
    initRequest();
    // System.println(_url);
    // System.println(_params);
    Communications.makeWebRequest(_url, _params, HEADER, method(:onReceive));
  }

  private function prepareRequestAgainAfterFailure(code as Number) as Boolean {
    var idx = $.stationsManager.getLimResults();
    if (idx != null && idx > 0) {
      $.stationsManager.setLimResults(idx - 1);
      return true;
    }
    return false;
  }

  function onReceive(
    code as Number,
    data as Dictionary or String or Null
  ) as Void {
    try {
      if (code == 200) {
        if (data instanceof Dictionary || data instanceof Array) {
          var results = parseData(data);
          if (results.size() == 0) {
            _notify.invoke("No departures upcoming.");
          } else {
            _show.invoke(results);
          }
        } else {
          _notify.invoke("Wrong departures data.");
        }
      } else {
        _retryN++;
        if (code == -403) {
          // seems to be a memory leak with -403 -> exit the app
          _forceExit = true;
          prepareRequestAgainAfterFailure(code);
        } else if (code == -402) {
          if (_retryN < 5 && prepareRequestAgainAfterFailure(code)) {
            makeRequest();
            return;
          }
        } else if (code >= 0) {
          // not a Garmin error, try again
          if (_retryN < 1 && prepareRequestAgainAfterFailure(code)) {
            makeRequest();
            return;
          }
        }
        _notify.invoke([
          "Failed to get departures.",
          "Error: " + code,
          $.Tools.errorMessage(code),
        ]);
      }
    } catch (e) {
      _notify.invoke("Something went wrong\ngetting departures.");
    }
  }

  private function initRequest() {
    _url = "https://api.transitous.org/api/v5/stoptimes";

    var idx = $.stationsManager.getLimResults();
    if (idx == null || idx < 0) {
      idx = System.getSystemStats().totalMemory < 132000 ? 5 : 7;
      $.stationsManager.setLimResults(idx);
    }

    _params = {
      "stopId" => $.stationsManager.getId(),
      "n" => RESULTS[idx],
      "radius" => 100, // include stops within 100m radius -> this includes departures from the same stops from other providers and makes the choice of the stop less problematic
      "withAlerts" => false, // not needed and can use up a lot of memory
    };

    var prod = $.stationsManager.getProducts();
    if (prod != null) {
      var mode = "";
      if (prod & 1) {
        mode += "HIGHSPEED_RAIL,";
        mode += "LONG_DISTANCE,";
        mode += "NIGHT_RAIL,";
      }
      if (prod & 2) {
        mode += "REGIONAL_FAST_RAIL,";
        mode += "REGIONAL_RAIL,";
      }
      if (prod & 4) {
        mode += "SUBURBAN,";
      }
      if (prod & 8) {
        mode += "SUBWAY,";
      }
      if (prod & 16) {
        mode += "TRAM,";
      }
      if (prod & 32) {
        mode += "BUS,";
      }
      if (prod & 64) {
        mode += "COACH,";
      }
      if (prod & 128) {
        mode += "FERRY,";
      }
      if (mode.length() > 0) {
        _params.put("mode", mode.substring(0, mode.length() - 1));
      }
    }
  }

  private function parseData(data as Dictionary or Array) as Array {
    var result = [];
    if (data instanceof Dictionary) {
      var departures = data["stopTimes"];
      if (departures != null && departures instanceof Array) {
        for (var i = 0; i < departures.size(); i++) {
          var dep = departures[i];
          if (dep != null && dep instanceof Dictionary) {
            var place = dep["place"];
            if (place != null && place instanceof Dictionary) {
              var cancelled = place["cancelled"] == true;
              if (!cancelled) {
                // get line name
                var line = dep["displayName"];
                if (line == null || line.equals("")) {
                  line = dep["routeShortName"];
                  if (line == null || line.equals("")) {
                    line = dep["routeLongName"];
                  }
                  if (line == null) {
                    line = "";
                  }
                }
                // get destination name
                var destination = dep["headsign"];
                if (destination == null) {
                  destination = "";
                }
                // get departure time
                var isRealtime = dep["realTime"] == true;
                var dateTime = place["departure"];
                if (dateTime == null) {
                  isRealtime = false;
                  dateTime = dep["scheduledDeparture"];
                }
                if (dateTime != null) {
                  // t = "2025-10-17T22:10:00Z
                  var epoch = $.Tools.datetimeToEpoch(dateTime, 0);
                  var time = $.Tools.epochToLocalHHMM(epoch);
                  // shorten line (important information is probably at the end, as in "ICE 1234")
                  var l = line.length();
                  if (l > 10) {
                    line = line.substring(l - 10, l);
                  }
                  // clean destination
                  destination = $.Tools.removePrefix(destination, line + " ");
                  destination = $.Tools.basicCleanse(destination);
                  destination = $.Tools.shorten(destination, 15);
                  var r =
                    time +
                    " " +
                    (isRealtime ? "| " : "¦ ") +
                    line +
                    " -> " +
                    destination;
                  // check for duplicates (can result from differen providers with same data)
                  if (result.indexOf(r) == -1) {
                    result.add(r);
                  } else {
                    r = 5;
                    continue;
                  }
                }
              }
            }
          }
        }
      }
    }
    return result;
  }
}
