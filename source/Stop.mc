using Toybox.Communications;
using Toybox.WatchUi;
using Toybox.Weather;
import Toybox.Lang;

class Stop extends WatchUi.BehaviorDelegate {
  protected const HEADER as Dictionary = $.Tools.getRequestGet();
  protected var _stationsSelector as $.StationsSelector;
  protected var _notify as (Method(text as Array<String> or String));
  protected var _show as (Method());
  protected var _url as String = "";
  protected var _params as Dictionary = {};
  protected var _forceExit = false;

  function initialize(
    stationsSelector as $.StationsSelector,
    notify as (Method(text as Array<String> or String)),
    show as (Method())
  ) {
    WatchUi.BehaviorDelegate.initialize();
    _stationsSelector = stationsSelector;
    _notify = notify;
    _show = show;
    initRequest();
  }

  function start() as Void {
    makeRequest();
  }

  function onSelect() as Boolean {
    if (_forceExit) {
      System.exit();
    }
    var name = _stationsSelector.getStation();
    if (name == null) {
      return false;
    }
    var id = _stationsSelector.getId();
    if (id == null) {
      return false;
    }
    $.stationsManager.addStationId(name, id);

    var view = new $.DepView();
    var delegate = new $.Dep(
      view.getPageManager(),
      view.method(:onReceive),
      view.method(:showDepartures)
    );
    WatchUi.switchToView(view, delegate, WatchUi.SLIDE_LEFT);
    delegate.start();
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
    if (_stationsSelector.incElement()) {
      WatchUi.requestUpdate();
    }
    return true;
  }

  function onPreviousPage() as Boolean {
    if (_stationsSelector.decElement()) {
      WatchUi.requestUpdate();
    }
    return true;
  }

  protected function makeRequest() as Void {
    _notify.invoke("Checking stops ...");
    // System.println(_url);
    // System.println(_params);
    Communications.makeWebRequest(_url, _params, HEADER, method(:onReceive));
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
            if ($.stationsManager.isPosition()) {
              // special case where getting the position was active
              _notify.invoke("No stops nearby.");
            } else {
              _notify.invoke(
                "No stops found for\n" + $.stationsManager.getStation()
              );
            }
          } else {
            _stationsSelector.setStationIdList(results);
            _show.invoke();
          }
        } else {
          _notify.invoke("Wrong stops data.");
        }
      } else {
        if (code == -403) {
          // seems to be a memory leak with -403 -> exit the app
          _forceExit = true;
        }
        _notify.invoke([
          "Failed to load stops.",
          "Error: " + code,
          $.Tools.errorMessage(code),
        ]);
      }
    } catch (e) {
      _notify.invoke("Something went wrong\nloading stops.");
    }
  }

  protected function setCoords(pos as Array<Double>) as Void {
    _params["place"] = pos[0].format("%2.5f") + "," + pos[1].format("%2.5f");
  }

  protected function initRequest() {
    _url = "https://api.transitous.org/api/v1/geocode";
    _params = {
      "text" => $.stationsManager.getNameCleaned(),
      "type" => "STOP",
    };

    // try to get a position signal to improve the stop search
    if (Toybox has :Weather) {
      var conditions = Weather.getCurrentConditions();
      if (conditions != null) {
        var pos = conditions.observationLocationPosition;
        if (pos != null) {
          pos = pos.toDegrees();
          if (pos != null && pos[0].abs() < 90 && pos[1].abs() < 180) {
            _params.put("placeBias", 5);
            setCoords(pos);
          }
        }
      }
    }
  }

  protected function parseData(data as Dictionary or Array) as Array {
    var a = [];
    var b = extractData(data);
    for (var i = 0; i < b.size(); i++) {
      var c = b[i];
      if (c instanceof Array) {
        a.add([c[0] + ": " + c[1], c[2]]);
      }
    }
    return a;
  }

  protected function extractData(data as Dictionary or Array) as Array {
    var a = [];
    if (data instanceof Array) {
      for (var i = 0; i < data.size(); i++) {
        var s = data[i];
        if (s != null && s instanceof Dictionary) {
          var areas = s["areas"];
          var prefix = "";
          if (areas != null && areas instanceof Array) {
            for (var j = 0; j < areas.size(); j++) {
              var ar = areas[j];
              if (ar != null && ar instanceof Dictionary) {
                if (ar["default"] == true) {
                  prefix = ar["name"];
                  break;
                }
              }
            }
          }
          if (s.hasKey("name") && s.hasKey("id")) {
            var name = s["name"];
            // clean name
            if (!name.equals(prefix)) {
              name = $.Tools.replace(name, "(" + prefix + ")", "");
              name = $.Tools.removePrefix(name, prefix);
            }
            name = $.Tools.basicCleanse(name);
            name = $.Tools.shorten(name, 15);
            // clean prefix
            prefix = $.Tools.replace(prefix, ",", "");
            if (prefix.length() > 10) {
              prefix = prefix.substring(0, 9) + "~";
            }
            a.add([prefix, name, s["id"]]);
          }
        }
      }
    }
    return a;
  }
}
