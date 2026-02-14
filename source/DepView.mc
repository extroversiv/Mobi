using Toybox.Graphics;
using Toybox.Math;
using Toybox.System;
using Toybox.Timer;
import Toybox.Lang;

class DepView extends $.BaseView {
  private var _pageManager as $.PageManager;
  private var _dep as Array<String> = [""];
  private var _timer = new Timer.Timer();
  private var _marginLR = 0;
  private var _marginTop = 0;
  private var _marginBottom = 0;
  private var _maxChar = 0;
  private var _maxLines = 0;
  private var _station as String;

  function initialize() {
    $.BaseView.initialize();
    _pageManager = new $.PageManager();
    _station = $.stationsManager.getStation();
  }

  function getPageManager() {
    return _pageManager;
  }

  function onHide() as Void {
    _timer.stop();
  }

  function onLayout(dc as Graphics.Dc) {
    $.BaseView.onLayout(dc);
    // 10% margin on the left and right side
    _marginLR = (0.1 * _width).toNumber();
    // marginTop needs to accomodate the station name with a tiny extra space
    // on round screens, 10% margin left/right, corresponds to 20% on top to be fully visible
    // sqrt(1 - 0.8^2) = 0.6^2
    _marginTop =
      System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_RECTANGLE
        ? 0
        : (0.2 * _height).toNumber();
    if (_marginTop < _heightTiny + 2) {
      _marginTop = _heightTiny + 2;
    }
    // marginBottom needs to accomodate the clock with a tiny extra space
    _marginBottom = _heightXTiny + 2;
    // calculate mac characters and lines to fit within the margins
    _maxChar = Math.ceil(
      (_width - 2.0 * _marginLR) /
        (dc.getTextWidthInPixels("Abc12:|", Graphics.FONT_XTINY) / 7.0)
    ).toNumber();
    _maxLines = Math.floor(
      (_height - _marginTop - _marginBottom) / _heightXTiny
    ).toNumber();
  }

  function clockUpdate() as Void {
    WatchUi.requestUpdate();
  }

  function onUpdate(dc as Graphics.Dc) as Void {
    if (_showCenterText) {
      $.BaseView.onUpdate(dc);
      return;
    }

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    var maxPage = Math.ceil(_dep.size().toFloat() / _maxLines).toNumber();
    _pageManager.setMax(maxPage);
    var page = _pageManager.getCurrent();
    var text = "";
    var startLine = (page - 1) * _maxLines;
    if (_dep.size() > startLine) {
      var endLine = _dep.size();
      if (endLine > page * _maxLines) {
        endLine = page * _maxLines;
      }
      if (endLine > startLine) {
        text = _dep[startLine].substring(0, _maxChar + 1);
      }
      for (var i = startLine + 1; i < endLine; i++) {
        text += "\n" + _dep[i].substring(0, _maxChar + 1);
      }
    }

    // station name
    dc.drawText(
      _width / 2,
      _marginTop - _heightTiny,
      Graphics.FONT_TINY,
      _station,
      Graphics.TEXT_JUSTIFY_CENTER
    );

    // departures table
    dc.drawText(
      _marginLR,
      _marginTop,
      Graphics.FONT_XTINY,
      text,
      Graphics.TEXT_JUSTIFY_LEFT
    );

    // draw page indicator
    if (maxPage > 1) {
      // vertical bar
      var xPage = _marginLR / 2;
      var yPage = 0.4 * _height;
      var dPage = (_height - 2 * yPage) / maxPage;
      dc.drawLine(
        xPage,
        yPage + (page - 1) * dPage,
        xPage,
        yPage + page * dPage
      );
    }

    // clock at very bottom (update every minute)
    var time = System.getClockTime();
    var timeString = $.Tools.displayTime(time.min, time.hour);

    dc.drawText(
      _width / 2,
      _height - _marginBottom,
      Graphics.FONT_XTINY,
      timeString,
      Graphics.TEXT_JUSTIFY_CENTER
    );

    _timer.start(method(:clockUpdate), (60 - time.sec) * 1000, false); // recursive, so call only once
  }

  function showDepartures(result as Array<String>) as Void {
    _showCenterText = false;
    _dep = result;
    WatchUi.requestUpdate();
  }
}
