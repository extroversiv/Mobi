using Toybox.WatchUi;
using Toybox.Graphics;
import Toybox.Lang;

class Menu extends WatchUi.BehaviorDelegate {
  function initialize() {
    BehaviorDelegate.initialize();
    $.Position.checkAndDeleteData(false);
  }

  function onMenu() as Boolean {
    $.stationsManager.resetStationTempValues();
    return true;
  }

  function onNextPage() as Boolean {
    return $.stationsManager.incElement();
  }

  function onPreviousPage() as Boolean {
    return $.stationsManager.decElement();
  }

  function onSelect() as Boolean {
    var view;
    var delegate;
    if ($.stationsManager.getElement() == 0) {
      view = new $.StopView();
      delegate = new $.Position(
        view.getStationsSelector(),
        view.method(:onReceive),
        view.method(:showStops)
      );
    } else {
      $.stationsManager.prioritizeCurrentElement();
      var id = $.stationsManager.getId();
      if (id == null || id == "") {
        view = new $.StopView();
        delegate = new $.Stop(
          view.getStationsSelector(),
          view.method(:onReceive),
          view.method(:showStops)
        );
      } else {
        view = new $.DepView();
        delegate = new $.Dep(
          view.getPageManager(),
          view.method(:onReceive),
          view.method(:showDepartures)
        );
      }
    }
    WatchUi.switchToView(view, delegate, WatchUi.SLIDE_LEFT);
    delegate.start();
    return true;
  }
}
