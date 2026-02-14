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

    var heightMedium = dc.getFontHeight(Graphics.FONT_MEDIUM);
    var heightTiny = dc.getFontHeight(Graphics.FONT_TINY);

    var x = dc.getWidth() / 2;
    var y = (dc.getHeight() - heightMedium) / 2;

    var element = $.stationsManager.getElement();
    var stationsList = $.stationsManager.getStationsList() as Array<String>;

    y -= element * heightTiny;

    for (var i = 0; i < stationsList.size(); ++i) {
      if (i == element) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
      } else {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
      }
      dc.drawText(
        x,
        y,
        i == element ? Graphics.FONT_MEDIUM : Graphics.FONT_TINY,
        stationsList[i],
        Graphics.TEXT_JUSTIFY_CENTER
      );
      y += i == element ? heightMedium : heightTiny;
    }
  }
}
