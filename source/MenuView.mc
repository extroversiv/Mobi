using Toybox.WatchUi;
using Toybox.Graphics;
import Toybox.Lang;

class MenuView extends WatchUi.View {

  function initialize() {
    View.initialize();
  }

  function onUpdate(dc as Graphics.Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    var textHeightTiny = dc.getFontHeight(Graphics.FONT_TINY);
    var textHeightMedium = dc.getFontHeight(Graphics.FONT_MEDIUM);

    var x = dc.getWidth() / 2;
    var y = (dc.getHeight() - textHeightMedium) / 2;

    var element = $.stationsManager.getElement();
    var stationsList = $.stationsManager.getStationsList() as Array<String>;

    y -= element * textHeightTiny;

    for (var i = 0; i < stationsList.size(); ++i) {
      var item = stationsList[i];
      if (i == element) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(
          x,
          y,
          Graphics.FONT_MEDIUM,
          item,
          Graphics.TEXT_JUSTIFY_CENTER
        );
        y += textHeightMedium;
      } else {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
          x,
          y,
          Graphics.FONT_TINY,
          item,
          Graphics.TEXT_JUSTIFY_CENTER
        );
        y += textHeightTiny;
      }
    }
  }
}
