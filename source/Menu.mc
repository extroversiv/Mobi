using Toybox.WatchUi;
using Toybox.Graphics;
import Toybox.Lang;

class Menu extends WatchUi.BehaviorDelegate {
  function initialize() {
    BehaviorDelegate.initialize();
    $.Position.checkAndDeleteData(false);
  }

  function onMenu() as Boolean {
    $.stationsManager.clearCache();
    WatchUi.requestUpdate();
    return true;
  }

  function onNextPage() as Boolean {
    if ($.stationsManager.incElement()) {
      WatchUi.requestUpdate();
    }
    return true;
  }

  function onPreviousPage() as Boolean {
    if ($.stationsManager.decElement()) {
      WatchUi.requestUpdate();
    }
    return true;
  }

  function onSelect() as Boolean {
    var view;
    var delegate;
    if ($.stationsManager.getElement() == 0) {
      view = new $.StopView();
      delegate = new $.Position();
    } else {
      $.stationsManager.prioritizeCurrentElement();
      var id = $.stationsManager.getId();
      if (id == null || id == "") {
        view = new $.StopView();
        delegate = new $.Stop();
      } else {
        view = new $.DepView();
        delegate = new $.Dep(view.method(:onReceive));
      }
    }
    WatchUi.switchToView(view, delegate, WatchUi.SLIDE_LEFT);
    delegate.start();
    return true;
  }
}
