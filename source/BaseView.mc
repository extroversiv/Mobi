using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
import Toybox.Lang;

class BaseView extends WatchUi.View {
    protected var _width = 0;
    protected var _height = 0;
    protected var _heightSmall = 0;
    protected var _heightTiny = 0;
    protected var _heightXTiny = 0;

    private var _centerText = "";
    protected var _showCenterText = false;

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Graphics.Dc) as Void {
        _width = dc.getWidth();
        _height = dc.getHeight();
        // the linespacing seems to be 3 pixels for all fonts on all devices
        // var lineHeight = dc.getTextDimensions("\n", Graphics.FONT_TINY);
        _heightSmall = 3 + dc.getFontHeight(Graphics.FONT_SMALL);
        _heightTiny = 3 + dc.getFontHeight(Graphics.FONT_TINY);
        _heightXTiny = 3 + dc.getFontHeight(Graphics.FONT_XTINY);
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawText(
            _width / 2,
            _height / 2,
            Graphics.FONT_XTINY,
            _centerText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function onReceive(text as Array<String> or String) as Void {
        _centerText = "";
        if (text instanceof Array && text.size() > 0) {
            _centerText = text[0];
            for (var i = 1; i < text.size(); i++) {
                _centerText += "\n" + text[i];
            }
        } else if (text instanceof String) {
            _centerText = text;
        }
        _showCenterText = true;
        WatchUi.requestUpdate();
    }
}
