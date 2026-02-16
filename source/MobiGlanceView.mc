import Toybox.Graphics;
import Toybox.WatchUi;


(:glance)
class MobiGlanceView extends WatchUi.GlanceView {
  function initialize() {
    GlanceView.initialize();
  }

  function onUpdate(dc as Graphics.Dc) as Void {
    dc.clear();
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      0,
      dc.getHeight() / 2 - Graphics.getFontHeight(Graphics.FONT_GLANCE) - 3,
      Graphics.FONT_GLANCE,
      "Mobi",
      Graphics.TEXT_JUSTIFY_LEFT
    );
    dc.drawText(
      0,
      dc.getHeight() / 2,
      Graphics.FONT_TINY,
      "Find your ride",
      Graphics.TEXT_JUSTIFY_LEFT
    );
  }
}
