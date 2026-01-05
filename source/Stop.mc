using Toybox.Communications;
using Toybox.WatchUi;
import Toybox.Lang;

class Stop extends WatchUi.BehaviorDelegate {
  protected const HEADER as Dictionary = $.Tools.getRequestGet();
  protected var _url as String = "";
  protected var _params as Dictionary = {};

  function initialize() {
    WatchUi.BehaviorDelegate.initialize();
    initRequest();
  }

  function start() as Void {
    makeRequest();
  }

  function onSelect() as Boolean {
    var name = $.stationsSelector.getStation();
    if (name == null) {
      return false;
    }
    var id = $.stationsSelector.getId();
    if (id == null) {
      return false;
    }
    $.stationsManager.addStationId(name, id);

    var view = new $.DepView();
    var delegate = new $.Dep(view.method(:onReceive));
    WatchUi.switchToView(view, delegate, WatchUi.SLIDE_LEFT);
    delegate.start();
    return true;
  }

  function onBack() as Boolean {
    WatchUi.switchToView(new $.MenuView(), new $.Menu(), WatchUi.SLIDE_RIGHT);
    return true;
  }

  function onNextPage() as Boolean {
    if ($.stationsSelector.incElement()) {
      WatchUi.requestUpdate();
    }
    return true;
  }

  function onPreviousPage() as Boolean {
    if ($.stationsSelector.decElement()) {
      WatchUi.requestUpdate();
    }
    return true;
  }

  protected function makeRequest() as Void {
    $.stationsSelector.setNotify("Checking stops ...");
    // System.println(_url);
    // System.println(_params);
    Communications.makeWebRequest(_url, _params, HEADER, method(:onReceive));
  }

  function onReceive(
    responseCode as Number,
    data as Dictionary or String or Null
  ) as Void {
    try {
      if (responseCode == 200) {
        var stationsNameId = parseData(data);
        if (stationsNameId.size() == 0) {
          if ($.stationsManager.isPosition()) {
            // special case where getting the position was active
            $.stationsSelector.setNotify("No stops nearby.");
          } else {
            $.stationsSelector.setNotify(
              "No stops found for \n" + $.stationsManager.getStation()
            );
          }
        } else {
          $.stationsSelector.setStationIdList(stationsNameId);
        }
      } else {
        // ToDo> restart on -403 error
        var message =
          responseCode == -402 || responseCode == -403
            ? "Not enough memory."
            : "Is the internet available?";
        $.stationsSelector.setNotify(
          "Failed to load stops.\nError: " + responseCode + "\n" + message
        );
      }
    } catch (e) {
      $.stationsSelector.setNotify("Something went wrong.");
    }
  }

  protected function setCoords(pos as Array<Double>) as Void {
    _params["place"] = pos[0].format("%2.5f") + "," + pos[1].format("%2.5f");
  }

  protected function initRequest() {
    // https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/motis-project/motis/refs/tags/v2.7.0/openapi.yaml#tag/geocode/operation/geocode
    _url = "https://api.transitous.org/api/v1/geocode/";
    _params = {
      "text" => $.stationsManager.getNameCleaned(),
      "type" => "STOP",
    };
    // get a position signal to improve the stop search
    var pos = Weather.getCurrentConditions().observationLocationPosition;
    if (pos != null) {
      pos = pos.toDegrees();
      if (
        pos != null &&
        pos.size() == 2 &&
        pos[0].abs() < 90 &&
        pos[1].abs() < 180
      ) {
        _params.put("placeBias", 5);
        setCoords(pos);
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
