using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Math;
using Toybox.Timer;
import Toybox.Lang;

class DepView extends WatchUi.View {
  private var _text as Array<String> = [""];
  private var _maxChar as Number = 1; // gets set in onLayout
  private var _maxLines as Number = 1; // gets set in onLayout
  private var _timer = new Timer.Timer() as Timer.Timer;
  var _station as String;

  function initialize() {
    View.initialize();
    $.pageManager = new $.PageManager();
    _station = $.stationsManager.getStation();
  }

  function onHide() as Void {
    _timer.stop();
  }

  function onLayout(dc) {
    _maxChar = $.Tools.getCharPerLine(dc, Graphics.FONT_XTINY);
    _maxLines = $.Tools.getLines(dc, Graphics.FONT_XTINY);
  }

  function clockUpdate() as Void {
    WatchUi.requestUpdate();
  }

  function onUpdate(dc as Graphics.Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    // station name
    dc.drawText(
      dc.getWidth() / 2,
      dc.getHeight() * $.Tools.marginV - dc.getFontHeight(Graphics.FONT_TINY),
      Graphics.FONT_TINY,
      _station,
      Graphics.TEXT_JUSTIFY_CENTER
    );

    // departures table
    var maxPage = Math.ceil(_text.size().toFloat() / _maxLines).toNumber();
    $.pageManager.setMax(maxPage);
    var page = $.pageManager.getCurrent();
    var departures = "";
    var startLine = (page - 1) * _maxLines;
    var yClock = dc.getHeight() - dc.getFontHeight(Graphics.FONT_TINY);
    if (_text.size() > startLine) {
      var endLine = _text.size();
      if (endLine > page * _maxLines) {
        endLine = page * _maxLines;
      }
      for (var i = startLine; i < endLine; i++) {
        departures += _text[i].substring(0, _maxChar + 1) + "\n";
      }
    } else {
      departures = "Nothing in sight";
    }
    dc.drawText(
      dc.getWidth() * $.Tools.marginH,
      dc.getHeight() * $.Tools.marginV,
      Graphics.FONT_XTINY,
      departures,
      Graphics.TEXT_JUSTIFY_LEFT
    );

    // clock at very bottom (update every minute)
    var time = System.getClockTime();
    var timeString = $.Tools.displayTime(time.min, time.hour);
    _timer.start(method(:clockUpdate), (60 - time.sec) * 1000, false); // recursive, so call only once

    dc.drawText(
      dc.getWidth() / 2,
      yClock,
      Graphics.FONT_XTINY,
      timeString,
      Graphics.TEXT_JUSTIFY_CENTER
    );

    // draw page indicator
    if (maxPage > 1) {
      // vertical bar
      var xPage = 0.3 * $.Tools.marginH * dc.getWidth();
      var yPage = 1.9 * $.Tools.marginV * dc.getHeight();
      var dPage = (dc.getHeight() - 2 * yPage) / maxPage;
      dc.drawLine(
        xPage,
        yPage + (page - 1) * dPage,
        xPage,
        yPage + page * dPage
      );
    }
  }

  function onReceive(text as Array<String> or String) as Void {
    if (text instanceof String) {
      _text = [text];
    } else if (text instanceof Array) {
      _text = text;
    }
    WatchUi.requestUpdate();
  }
}
