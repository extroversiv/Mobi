using Toybox.WatchUi;
using Toybox.Graphics;
import Toybox.Lang;

class StopView extends WatchUi.View {
  private var _maxCharSmall = 1;
  private var _maxCharXTiny = 1;

  function initialize() {
    View.initialize();
    $.stationsSelector = new $.StationsSelector();
  }

  function onLayout(dc) {
    _maxCharSmall = $.Tools.getCharPerLine(dc, Graphics.FONT_SMALL);
    _maxCharXTiny = $.Tools.getCharPerLine(dc, Graphics.FONT_XTINY);
  }

  function onUpdate(dc as Graphics.Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    var textHeightXTiny = dc.getFontHeight(Graphics.FONT_XTINY);
    var textHeightSmall = dc.getFontHeight(Graphics.FONT_SMALL);

    // notify
    dc.drawText(
      dc.getWidth() * $.Tools.marginH,
      dc.getHeight() * $.Tools.marginV,
      Graphics.FONT_XTINY,
      $.stationsSelector.getNotify(),
      Graphics.TEXT_JUSTIFY_LEFT
    );

    // menu
    var elementNumber = $.stationsSelector.getElement();
    var stationsList = $.stationsSelector.getStationsList() as Array<String>;

    var x = dc.getWidth() / 2;
    var y = (dc.getHeight() - textHeightSmall) / 2 - elementNumber * textHeightXTiny;

    for (var i = 0; i < stationsList.size(); ++i) {
      if (i == elementNumber) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(
          x,
          y,
          Graphics.FONT_SMALL,
          stationsList[i].substring(0, _maxCharSmall),
          Graphics.TEXT_JUSTIFY_CENTER
        );
        y += textHeightSmall;
      } else {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
          x,
          y,
          Graphics.FONT_XTINY,
          stationsList[i].substring(0, _maxCharXTiny),
          Graphics.TEXT_JUSTIFY_CENTER
        );
        y += textHeightXTiny;
      }
    }
  }
}
