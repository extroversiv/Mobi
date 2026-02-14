using Toybox.Graphics;
import Toybox.Lang;

class StopView extends $.BaseView {
  private var _stationsSelector as $.StationsSelector;

  function initialize() {
    $.BaseView.initialize();
    _stationsSelector = new $.StationsSelector();
  }

  function getStationsSelector() {
    return _stationsSelector;
  }

  function onUpdate(dc as Graphics.Dc) as Void {
    if (_showCenterText) {
      $.BaseView.onUpdate(dc);
      return;
    }

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    // stop menu
    var element = _stationsSelector.getElement();
    var stationsList = _stationsSelector.getStationsList() as Array<String>;

    var x = _width / 2;
    var y = (_height - _heightSmall) / 2 - element * _heightXTiny;

    for (var i = 0; i < stationsList.size(); ++i) {
      if (i == element) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
      } else {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
      }
      dc.drawText(
        x,
        y,
        i == element ? Graphics.FONT_TINY : Graphics.FONT_XTINY,
        stationsList[i],
        Graphics.TEXT_JUSTIFY_CENTER
      );
      y += i == element ? _heightTiny : _heightXTiny;
      y -= 2;
    }
  }

  function showStops() {
    _showCenterText = false;
    WatchUi.requestUpdate();
  }
}
