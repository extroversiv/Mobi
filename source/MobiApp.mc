using Toybox.Application;
using Toybox.WatchUi;
import Toybox.Lang;

var stationsManager as $.StationsManager? = null;

class MobiApp extends Application.AppBase {
  function initialize() {
    AppBase.initialize();
  }

  function onStart(state as Dictionary?) as Void {
    $.Position.checkAndDeleteData(true);
    $.stationsManager = new $.StationsManager();
  }

  function onStop(state as Dictionary?) as Void {
    stationsManager.saveCache();
  }

  function getInitialView() as [WatchUi.Views] or
    [WatchUi.Views, WatchUi.InputDelegates] {
    return [new $.MenuView(), new $.Menu()];
  }

  function onSettingsChanged() as Void {
    $.stationsManager.clearCache();
    WatchUi.requestUpdate();
  }
}
