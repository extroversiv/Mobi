using Toybox.Application;
using Toybox.WatchUi;
import Toybox.Lang;

var stationsManager as $.StationsManager? = null;

class MobiApp extends Application.AppBase {
  function initialize() {
    AppBase.initialize();
  }

  function onStop(state as Dictionary?) as Void {
    if ($.stationsManager != null) {
      stationsManager.saveCache();
    }
  }

  function getInitialView() as [WatchUi.Views] or
    [WatchUi.Views, WatchUi.InputDelegates] {
    $.Position.checkAndDeleteData(true);
    $.stationsManager = new $.StationsManager();
    return [new $.MenuView(), new $.Menu()];
  }

  (:glance)
  function getGlanceView() as [WatchUi.GlanceView] or
    [WatchUi.GlanceView, WatchUi.GlanceViewDelegate] or
    Null {
    return [new MobiGlanceView()];
  }

  function onSettingsChanged() as Void {
    if ($.stationsManager != null) {
      $.stationsManager.clearCache();
      WatchUi.requestUpdate();
    }
  }
}
