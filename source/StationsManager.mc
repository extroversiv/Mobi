using Toybox.Application.Properties;
using Toybox.Application.Storage;
import Toybox.Lang;

class StationsManager {
  private var _stations as Array<Array>;
  private var _stationsList as Array<String>;
  private var _element = 0;

  const STATIONSCACHE = "stationsCache" as String;

  function initialize() {
    // load station list from storage or settings (initially)
    // the stations cache stores different values in array, like:
    //                   | full name       | id (str?)  | products filtered (int?)  | name filtered (string?) | limResults (int?)
    //                 0 | @               | null       | null                      | null                    | null
    //                 1 | S+I Berlin Hbf  | xyz        | 33=(100001)_2             | Berlin Hbf              | 16
    //                 2 | Pankow          | null       | null                      | null                    | null
    _stations = [];
    _stationsList = [];
    try {
      // reset the stations from the current setting and compare the list with the cache if present
      resetStationsListFromSettings();
      var reset = _stations;
      var cache = Storage.getValue(STATIONSCACHE);
      if (cache == null || !(cache instanceof Array)) {
        // nothing in the cache, nothing to do, stations were reset
      } else {
        var resetList = getStationsList();
        // use cache
        _stations = cache;
        var cachedList = getStationsList();
        if (!$.Tools.arraysEqualInAnyOrder(resetList, cachedList)) {
          // the settings have changed -> go back to the reset stations
          _stations = reset;
        }
      }
    } catch (e) {
      _stationsList = ["Failed to load stations."];
      Storage.clearValues(); // this should reset the list from the setting at the next start
      WatchUi.requestUpdate();
    } finally {
      _element = _stations.size() > 1 ? 1 : 0;
    }
  }

  function saveCache() {
    Storage.setValue(STATIONSCACHE, _stations);
  }

  function clearCache() {
    Storage.deleteValue(STATIONSCACHE);
    resetStationsListFromSettings();
  }

  // reset the station list with the one from the settings and reset the element number to 0
  private function resetStationsListFromSettings() as Void {
    // fill stations list from settings values
    _stationsList = ["@"];
    for (var i = 1; i <= 10; i++) {
      var s = $.Tools.trim(Properties.getValue("fav" + i));
      if (s.length() > 0) {
        _stationsList.add(s);
      }
    }

    // initialize the cache
    _stations = [[_stationsList[0], null, null, null, null]];
    for (var i = 1; i < _stationsList.size(); i++) {
      var filter = new $.NameFilter(
        _stationsList[i],
        ['X', 'R', 'S', 'U', 'T', 'B', 'C', 'F'],
        null
      );
      _stations.add([
        filter.getName(),
        null,
        filter.getProducts(),
        filter.getNameCleaned(),
        null,
      ]);
    }
  }

  function incElement() as Boolean {
    if (_element < _stations.size() - 1) {
      _element++;
      WatchUi.requestUpdate();
      return true;
    }
    return false;
  }

  function decElement() as Boolean {
    if (_element > 0) {
      _element--;
      WatchUi.requestUpdate();
      return true;
    }
    return false;
  }

  // swap current element with the 0 element
  function prioritizeCurrentElement() as Void {
    if (_element > 0) {
      var cache = [_stations[0]] as Array<Array>; // @ always stays the first element
      cache.add(_stations[_element]);
      for (var i = 1; i < _stations.size(); i++) {
        if (i != _element) {
          cache.add(_stations[i]);
        }
      }
      _stations = cache;
      _element = 1;
    }
  }

  function isPosition() {
    return _element == 0;
  }

  function getElement() as Integer {
    return _element;
  }

  function getStationsList() as Array<String> {
    _stationsList = [];
    for (var i = 0; i < _stations.size(); i++) {
      _stationsList.add(_stations[i][0]);
    }
    return _stationsList;
  }

  function getStation() as String? {
    if (isPosition()) {
      // this station name is stored in nameCleaned as an exception
      return _stations[_element][3];
    }
    return _stations[_element][0];
  }

  function setId(id as String) {
    _stations[_element][1] = id;
  }

  function getId() as String? {
    return _stations[_element][1];
  }

  function setProducts(prod as Number?) {
    _stations[_element][2] = prod;
  }

  function getProducts() as Number? {
    return _stations[_element][2];
  }

  function setNameCleaned(name as String) {
    _stations[_element][3] = name;
  }

  function getNameCleaned() as String? {
    return _stations[_element][3];
  }

  function setLimResults(value as Number?) {
    _stations[_element][4] = value;
  }

  function getLimResults() as Number? {
    return _stations[_element][4];
  }

  // Sets the station id and if it is the station to the current position, all other values too (not if it was a previous stop already).
  function addStationId(name as String, id as String) {
    if (isPosition()) {
      // set the values for the stop chosen from the current position
      // e.g. the LimResults value might need to be adjusted, so it should stay
      var sameStop = id.equals(getId()) && name.equals(getNameCleaned());
      if (!sameStop) {
        setId(id);
        setProducts(null);
        setNameCleaned(name);
        setLimResults(null);
      }
    } else {
      setId(id);
    }
  }

  function resetStationTempValues(){
    _stations[_element][1] = null;
    _stations[_element][4] = null;
  }
}
