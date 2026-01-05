import Toybox.Lang;

class PageManager {

  private var _page as Number;
  private var _max as Number;

  function initialize() {
    _page = 1;
    _max = 1;
  }

  function reset() {
    _page = 1;
  }

  function setMax(max as Number){
    _max = max;
  }

  function increment() as Boolean {
    if (_page < _max) {
      _page++;
      return true;
    }
    return false;
  }

  function decrement() as Boolean {
    if (_page > 1) {
      _page--;
      return true;
    }
    return false;
  }

  function getCurrent() as Number {
    return (_page < _max) ? _page : _max;
  }
}
