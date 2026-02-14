using Toybox.WatchUi;
using Toybox.Position;
using Toybox.Time;
using Toybox.Application.Storage;
import Toybox.Lang;

class Position extends Stop {
  static const LAST_COORDS = "lastPosition";
  static const LAST_TIME = "lastTime";
  static const LAST_DATA = "lastData";

  function initialize(
    stationsSelector as $.StationsSelector,
    notify as (Method(text as Array<String> or String)),
    show as (Method())
  ) {
    $.Stop.initialize(stationsSelector, notify, show);
  }

  static function checkAndDeleteData(forceDelete as Boolean) as Boolean {
    if (!forceDelete) {
      var when = Storage.getValue(LAST_TIME) as Number;
      if (when != null) {
        if (Time.now().value() < when + 240) {
          return true;
        }
      }
    }
    Storage.deleteValue(LAST_TIME);
    Storage.deleteValue(LAST_COORDS);
    Storage.deleteValue(LAST_DATA);
    return false;
  }

  function start() {
    var stationsNameId = [];
    if (checkAndDeleteData(false)) {
      var data = Storage.getValue(LAST_DATA) as Array;
      if (data != null && data.size() > 1) {
        stationsNameId = data;
      }
      if (stationsNameId != null && stationsNameId.size() > 0) {
        // use the previously stored station data
        _stationsSelector.setStationIdList(stationsNameId);
        _show.invoke();
      } else {
        // use previously stored position
        var coords = Storage.getValue(LAST_COORDS) as Array<Double>;
        if (coords != null) {
          Storage.deleteValue(LAST_DATA); // in case the server does not respond, then the data might be old
          setCoords(coords);
          makeRequest();
        }
      }
    } else {
      // search for the position signal and find the stops
      _notify.invoke("Waiting for position ...");
      Position.enableLocationEvents(
        Position.LOCATION_ONE_SHOT,
        method(:onPosition)
      );
    }
  }

  function onPosition(info as Position.Info) as Void {
    var coords = info.position.toDegrees();
    Storage.setValue(LAST_COORDS, coords);
    Storage.setValue(LAST_TIME, Time.now().value());
    setCoords(coords);
    makeRequest();
  }

  protected function initRequest() {
    //https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/motis-project/motis/refs/tags/v2.7.0/openapi.yaml#tag/geocode/operation/reverseGeocode
    _url = "https://api.transitous.org/api/v1/reverse-geocode";
    _params = { "type" => "STOP" };
  }

  protected function parseData(data as Dictionary or Array) as Array {
    var a = [];
    var b = extractData(data);
    for (var i = 0; i < b.size(); i++) {
      var c = b[i];
      if (c instanceof Array) {
        // prefix is not necessary when the request was fully based on the current position
        a.add([c[1], c[2]]);
      }
    }
    return a;
  }
}
