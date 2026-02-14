using Toybox.Application.Properties;
using Toybox.Application.Storage;
import Toybox.Lang;

class StationsSelector {
  private var _element = 0;
  private var _stationList as Array<String> = [];
  private var _idList as Array<String> = [];

  function initialize() {}

  function incElement() as Boolean {
    if (_element < _stationList.size() - 1) {
      _element++;
      return true;
    }
    return false;
  }

  function decElement() as Boolean {
    if (_element > 0) {
      _element--;
      return true;
    }
    return false;
  }

  function getElement() as Integer {
    return _element;
  }

  function getStation() as String? {
    if (_stationList.size() == 0 || _element + 1 > _stationList.size()) {
      return null;
    }
    return _stationList[_element];
  }

  function getId() as String? {
    if (_stationList.size() == 0 || _element + 1 > _stationList.size()) {
      return null;
    }
    return _idList[_element];
  }

  function getStationsList() as Array<String> {
    return _stationList;
  }

  function setStationIdList(stationIdList as Array<Array>) {
    _element = 0;
    _stationList = [];
    _idList = [];
    for (var i = 0; i < stationIdList.size(); i++) {
      var s = stationIdList[i];
      if (s instanceof Array && s.size() == 2) {
        _stationList.add(s[0]);
        _idList.add(s[1]);
      }
    }
  }
}
