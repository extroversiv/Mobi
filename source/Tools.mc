using Toybox.Communications;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Math;
using Toybox.System;
using Toybox.Graphics;
import Toybox.Lang;

class Tools {
  static const marginV = 0.2; // top and bottom margin of departure box
  static const marginH = 0.1; // left and right margin of departure box

  static function getCharPerLine(
    dc as Graphics.Dc,
    font as Graphics.FontType
  ) as Number {
    var chars = "AbCdEfGhIj";
    var avgCharWidth =
      dc.getTextWidthInPixels(chars, font).toFloat() / chars.length();
    var charPerLine = ((1 - 2 * marginH) * dc.getWidth()) / avgCharWidth;
    return charPerLine.toNumber() + 1;
  }

  static function getLines(
    dc as Graphics.Dc,
    font as Graphics.FontType
  ) as Number {
    var endLines =
      ((1 - 2 * marginV) * dc.getHeight()) / dc.getFontHeight(font);
    return endLines.toNumber();
  }

  static function getRequestGet() as Dictionary {
    return {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :headers => {
        "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
        "Accept" => "application/json",
        "User-Agent" => "Mobi for Garmin",
      },
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
    };
  }

  static function trim(s as String) as String {
    var done = false;
    do {
      var e = replaceStart(s, " ", "");
      done = !e.equals(s);
      s = e;
    } while (done);
    done = false;
    do {
      var e = replaceEnd(s, " ", "");
      done = !e.equals(s);
      s = e;
    } while (done);
    return s;
  }

  static function replaceStart(
    element as String,
    deleteString as String,
    replaceString as String
  ) as String {
    var el = element.length();
    var dl = deleteString.length();
    if (el >= dl && element.substring(0, dl).equals(deleteString)) {
      element = replaceString + element.substring(dl, el);
    }
    return element;
  }

  static function replaceEnd(
    element as String,
    deleteString as String,
    replaceString as String
  ) as String {
    var el = element.length();
    var dl = deleteString.length();
    if (
      el >= dl &&
      element.substring(el - dl, element.length()).equals(deleteString)
    ) {
      element = element.substring(0, el - dl) + replaceString;
    }
    return element;
  }

  static function replace(
    original as String,
    oldString as String,
    newString as String
  ) as String {
    if (oldString.length() == 0) {
      return original;
    }
    var idx = original.toLower().find(oldString.toLower());
    if (idx != null) {
      var replaced = original.substring(0, idx);
      replaced += newString;
      replaced += original.substring(
        idx + oldString.length(),
        original.length()
      );
      return replaced;
    }
    return original;
  }

  static function shorten(element as String, length as Number) as String {
    element = trim(element);
    if (element.length() > length) {
      var idx = element.find(", ");
      if (idx == null) {
        idx = element.find(" ");
      }
      if (idx != null && idx > length / 2) {
        var endString = element.substring(idx, element.length());
        if (endString.length() > 5) {
          return element.substring(0, 4) + "~" + endString;
        }
      }
    }
    return element;
  }

  static function arraysEqualInAnyOrder(
    a1 as Array<String>,
    a2 as Array<String>
  ) as Boolean {
    if (a1.size() != a2.size()) {
      return false;
    }
    for (var i = 0; i < a1.size(); i++) {
      if (a1.indexOf(a2[i]) == -1) {
        // _element of a2 not found in a1
        return false;
      }
    }
    return true;
  }

  static function basicCleanse(element as String) as String {
    element = replaceEnd(element, " Flughafen", " Flugh.");
    element = replaceEnd(element, " Hauptbahnhof", " Hbf.");
    element = replaceEnd(element, " Bahnhof", " Bf.");
    element = replaceEnd(element, " Station", " St.");
    element = replaceEnd(element, " Centralstation", " C.");
    element = replaceEnd(element, " Centralst", " C.");
    element = replaceEnd(element, " Centraal", " C.");
    element = replaceEnd(element, " Central", " C.");
    element = replaceEnd(element, " Street", " St.");
    element = replaceEnd(element, " Road", " Rd.");
    element = replaceEnd(element, " Junction", " Jct.");
    return trim(element);
  }

  static function removePrefix(element as String, prefix as String) as String {
    element = replaceStart(element, prefix, "");
    element = replaceStart(element, ",", "");
    element = replaceStart(element, "-", "");
    return trim(element);
  }

  static function datetimeToEpoch(
    datetime as String,
    offsetSeconds as Number
  ) as Number {
    try {
      return (
        Gregorian.moment({
          :year => datetime.substring(0, 4).toNumber(),
          :month => datetime.substring(5, 7).toNumber(),
          :day => datetime.substring(8, 10).toNumber(),
          :hour => datetime.substring(11, 13).toNumber(),
          :minute => datetime.substring(14, 16).toNumber(),
          :second => datetime.substring(17, 19).toNumber(),
        }).value() - offsetSeconds
      );
    } catch (e) {
      return 1;
    }
  }

  static function epochToLocalHHMM(epoch as Number) as String {
    var t = new Time.Moment(epoch);
    var local = Gregorian.info(t, Time.FORMAT_SHORT);
    return displayTime(local.min, local.hour);
  }

  static function displayTime(min as Number, hour as Number) as String {
    if (!System.getDeviceSettings().is24Hour) {
      hour = hour % 12;
      if (hour == 0) {
        hour = 12;
      }
    }
    var hourPadding = hour < 10 ? " " : "";
    return hourPadding + hour.format("%2d") + ":" + min.format("%02d");
  }
}
