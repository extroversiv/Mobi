using Toybox.Test;
using Toybox.System;
import Toybox.Lang;

// Unit tests for the Mobi app.
//
// Tests are stripped from non-test builds via the (:test) annotation.
// Run with:
//   monkeyc ... --unit-test ... && monkeydo <prg> <device> -t
//
// Each test takes a Logger and returns true on success.

// ---------------------------------------------------------------------------
// Tools.trim
// ---------------------------------------------------------------------------

(:test)
function testTrimBothSides(logger as Test.Logger) as Boolean {
  return $.Tools.trim("   hello   ").equals("hello");
}

(:test)
function testTrimNoSpaces(logger as Test.Logger) as Boolean {
  return $.Tools.trim("hello").equals("hello");
}

(:test)
function testTrimAllSpaces(logger as Test.Logger) as Boolean {
  return $.Tools.trim("     ").equals("");
}

(:test)
function testTrimEmpty(logger as Test.Logger) as Boolean {
  return $.Tools.trim("").equals("");
}

(:test)
function testTrimPreservesInner(logger as Test.Logger) as Boolean {
  return $.Tools.trim("  a b c  ").equals("a b c");
}

// ---------------------------------------------------------------------------
// Tools.replaceStart / replaceEnd
// ---------------------------------------------------------------------------

(:test)
function testReplaceStartMatches(logger as Test.Logger) as Boolean {
  return $.Tools.replaceStart("foobar", "foo", "X").equals("Xbar");
}

(:test)
function testReplaceStartNoMatch(logger as Test.Logger) as Boolean {
  return $.Tools.replaceStart("foobar", "baz", "X").equals("foobar");
}

(:test)
function testReplaceStartDeleteShorterThanString(logger as Test.Logger) as Boolean {
  return $.Tools.replaceStart("ab", "abcdef", "X").equals("ab");
}

(:test)
function testReplaceEndMatches(logger as Test.Logger) as Boolean {
  return $.Tools.replaceEnd("foobar", "bar", "X").equals("fooX");
}

(:test)
function testReplaceEndNoMatch(logger as Test.Logger) as Boolean {
  return $.Tools.replaceEnd("foobar", "baz", "X").equals("foobar");
}

// ---------------------------------------------------------------------------
// Tools.replace
// ---------------------------------------------------------------------------

(:test)
function testReplaceBasic(logger as Test.Logger) as Boolean {
  return $.Tools.replace("hello world", "world", "there").equals("hello there");
}

(:test)
function testReplaceCaseInsensitive(logger as Test.Logger) as Boolean {
  return $.Tools.replace("Hello WORLD", "world", "there").equals("Hello there");
}

(:test)
function testReplaceNotFound(logger as Test.Logger) as Boolean {
  return $.Tools.replace("hello", "x", "y").equals("hello");
}

(:test)
function testReplaceEmptyOld(logger as Test.Logger) as Boolean {
  return $.Tools.replace("hello", "", "y").equals("hello");
}

// ---------------------------------------------------------------------------
// Tools.shorten
// ---------------------------------------------------------------------------

(:test)
function testShortenBelowLimit(logger as Test.Logger) as Boolean {
  return $.Tools.shorten("short", 10).equals("short");
}

(:test)
function testShortenAtLimit(logger as Test.Logger) as Boolean {
  return $.Tools.shorten("exactlength", 11).equals("exactlength");
}

(:test)
function testShortenCollapsesAroundComma(logger as Test.Logger) as Boolean {
  // "Hauptbahnhof, Berlin" length=20, > 15, find(", ") at idx 12, 12 > 15/2(=7) -> split
  // endString = ", Berlin" (len 8 > 5) -> "Haup" + "~" + ", Berlin"
  var r = $.Tools.shorten("Hauptbahnhof, Berlin", 15);
  return r.equals("Haup~, Berlin");
}

// ---------------------------------------------------------------------------
// Tools.arraysEqualInAnyOrder (multiset semantics)
// ---------------------------------------------------------------------------

(:test)
function testArraysEqualSameOrder(logger as Test.Logger) as Boolean {
  return $.Tools.arraysEqualInAnyOrder(["a", "b", "c"], ["a", "b", "c"]);
}

(:test)
function testArraysEqualDifferentOrder(logger as Test.Logger) as Boolean {
  return $.Tools.arraysEqualInAnyOrder(["a", "b", "c"], ["c", "a", "b"]);
}

(:test)
function testArraysEqualDifferentSize(logger as Test.Logger) as Boolean {
  return !$.Tools.arraysEqualInAnyOrder(["a", "b"], ["a", "b", "c"]);
}

(:test)
function testArraysEqualBothEmpty(logger as Test.Logger) as Boolean {
  return $.Tools.arraysEqualInAnyOrder([], []);
}

(:test)
function testArraysEqualDuplicates(logger as Test.Logger) as Boolean {
  return $.Tools.arraysEqualInAnyOrder(["a", "a", "b"], ["a", "a", "b"]);
}

(:test)
function testArraysEqualDuplicatesMatch(logger as Test.Logger) as Boolean {
  return $.Tools.arraysEqualInAnyOrder(["a", "a", "b"], ["a", "b", "a"]);
}

(:test)
function testArraysEqualDisjoint(logger as Test.Logger) as Boolean {
  return !$.Tools.arraysEqualInAnyOrder(["a", "b"], ["c", "d"]);
}

// ---------------------------------------------------------------------------
// Tools.basicCleanse
// ---------------------------------------------------------------------------

(:test)
function testBasicCleanseHauptbahnhof(logger as Test.Logger) as Boolean {
  return $.Tools.basicCleanse("Berlin Hauptbahnhof").equals("Berlin Hbf.");
}

(:test)
function testBasicCleanseBahnhof(logger as Test.Logger) as Boolean {
  return $.Tools.basicCleanse("Berlin Bahnhof").equals("Berlin Bf.");
}

(:test)
function testBasicCleanseStreet(logger as Test.Logger) as Boolean {
  return $.Tools.basicCleanse("Baker Street").equals("Baker St.");
}

(:test)
function testBasicCleanseNoMatch(logger as Test.Logger) as Boolean {
  return $.Tools.basicCleanse("Some Random Stop").equals("Some Random Stop");
}

// ---------------------------------------------------------------------------
// Tools.removePrefix
// ---------------------------------------------------------------------------

(:test)
function testRemovePrefixMatches(logger as Test.Logger) as Boolean {
  return $.Tools.removePrefix("Berlin Hbf", "Berlin ").equals("Hbf");
}

(:test)
function testRemovePrefixStripsLeadingComma(logger as Test.Logger) as Boolean {
  return $.Tools.removePrefix(", Hbf", "").equals("Hbf");
}

(:test)
function testRemovePrefixStripsLeadingDash(logger as Test.Logger) as Boolean {
  return $.Tools.removePrefix("- Hbf", "").equals("Hbf");
}

(:test)
function testRemovePrefixNoMatch(logger as Test.Logger) as Boolean {
  return $.Tools.removePrefix("Berlin Hbf", "Hamburg ").equals("Berlin Hbf");
}

(:test)
function testDatetimeToEpochValid(logger as Test.Logger) as Boolean {
  var v = $.Tools.datetimeToEpoch("2025-10-17T22:10:00Z", 0);
  return v != null && v > 0;
}

(:test)
function testDatetimeToEpochOffsetSubtracted(logger as Test.Logger) as Boolean {
  var a = $.Tools.datetimeToEpoch("2025-10-17T22:10:00Z", 0);
  var b = $.Tools.datetimeToEpoch("2025-10-17T22:10:00Z", 60);
  return a != null && b != null && a - b == 60;
}

(:test)
function testDatetimeToEpochInvalidReturnsNull(logger as Test.Logger) as Boolean {
  return $.Tools.datetimeToEpoch("garbage", 0) == null;
}

(:test)
function testDatetimeToEpochShortReturnsNull(logger as Test.Logger) as Boolean {
  return $.Tools.datetimeToEpoch("2025-10-17", 0) == null;
}

(:test)
function testDatetimeToEpochEmptyReturnsNull(logger as Test.Logger) as Boolean {
  return $.Tools.datetimeToEpoch("", 0) == null;
}

(:test)
function testDisplayTimeSingleDigitHourPaddedOnce(logger as Test.Logger) as Boolean {
  // Pre-fix produced "  9:05" (two leading spaces). Post-fix: " 9:05".
  var s = $.Tools.displayTime(5, 9);
  // 24h format only matches if device is 24h; we accept both " 9:05" and " 9:05"
  // after AM/PM mapping (9 stays 9 in both formats).
  return s.equals(" 9:05");
}

(:test)
function testDisplayTimeTwoDigitHourNoPadding(logger as Test.Logger) as Boolean {
  var s = $.Tools.displayTime(0, 15);
  // 15 in 24h => "15:00"; in 12h => " 3:00"
  if (System.getDeviceSettings().is24Hour) {
    return s.equals("15:00");
  }
  return s.equals(" 3:00");
}

(:test)
function testDisplayTimeMinutesPadded(logger as Test.Logger) as Boolean {
  var s = $.Tools.displayTime(3, 10);
  return s.equals("10:03");
}

(:test)
function testDisplayTimeMidnight(logger as Test.Logger) as Boolean {
  var s = $.Tools.displayTime(0, 0);
  // 24h => " 0:00"; 12h => "12:00"
  if (System.getDeviceSettings().is24Hour) {
    return s.equals(" 0:00");
  }
  return s.equals("12:00");
}

// ---------------------------------------------------------------------------
// Tools.errorMessage
// ---------------------------------------------------------------------------

(:test)
function testErrorMessageFilesystemFull(logger as Test.Logger) as Boolean {
  return $.Tools.errorMessage(-1000).equals("Filesystem full.");
}

(:test)
function testErrorMessageRestart(logger as Test.Logger) as Boolean {
  return $.Tools.errorMessage(-403).equals("Please restart!");
}

(:test)
function testErrorMessageMemory(logger as Test.Logger) as Boolean {
  return $.Tools.errorMessage(-402).equals("Not enough memory.");
}

(:test)
function testErrorMessageBluetooth(logger as Test.Logger) as Boolean {
  return $.Tools.errorMessage(-100).equals("Bluetooth connected?");
}

(:test)
function testErrorMessageDefault(logger as Test.Logger) as Boolean {
  return $.Tools.errorMessage(500).equals("Internet available?");
}

// ---------------------------------------------------------------------------
// PageManager
// ---------------------------------------------------------------------------

(:test)
function testPageManagerInitialState(logger as Test.Logger) as Boolean {
  var pm = new $.PageManager();
  return pm.getCurrent() == 1;
}

(:test)
function testPageManagerIncrementWithinRange(logger as Test.Logger) as Boolean {
  var pm = new $.PageManager();
  pm.setMax(3);
  var ok1 = pm.increment();
  var ok2 = pm.increment();
  return ok1 && ok2 && pm.getCurrent() == 3;
}

(:test)
function testPageManagerIncrementStopsAtMax(logger as Test.Logger) as Boolean {
  var pm = new $.PageManager();
  pm.setMax(2);
  pm.increment();
  var ok = pm.increment(); // should fail (already at max)
  return !ok && pm.getCurrent() == 2;
}

(:test)
function testPageManagerDecrementStopsAtOne(logger as Test.Logger) as Boolean {
  var pm = new $.PageManager();
  pm.setMax(3);
  var ok = pm.decrement(); // already at 1
  return !ok && pm.getCurrent() == 1;
}

(:test)
function testPageManagerReset(logger as Test.Logger) as Boolean {
  var pm = new $.PageManager();
  pm.setMax(5);
  pm.increment();
  pm.increment();
  pm.reset();
  return pm.getCurrent() == 1;
}

(:test)
function testPageManagerClampsCurrentWhenMaxShrinks(logger as Test.Logger) as Boolean {
  var pm = new $.PageManager();
  pm.setMax(5);
  pm.increment();
  pm.increment();
  pm.increment(); // page = 4
  pm.setMax(2);
  return pm.getCurrent() == 2;
}

// ---------------------------------------------------------------------------
// NameFilter
// ---------------------------------------------------------------------------

(:test)
function testNameFilterPlainName(logger as Test.Logger) as Boolean {
  var nf = new $.NameFilter("Pankow", ['X', 'R', 'S', 'U', 'T', 'B', 'C', 'F'], null);
  return nf.getName().equals("Pankow") && nf.getProducts() == null;
}

(:test)
function testNameFilterWithProducts(logger as Test.Logger) as Boolean {
  // "S+U Berlin Hbf" -> name=Berlin Hbf, products S(idx2)=4 + U(idx3)=8 = 12
  var nf = new $.NameFilter(
    "S+U Berlin Hbf",
    ['X', 'R', 'S', 'U', 'T', 'B', 'C', 'F'],
    null
  );
  return nf.getName().equals("S+U Berlin Hbf") &&
    nf.getNameCleaned().equals("Berlin Hbf") &&
    nf.getProducts() == 12;
}

(:test)
function testNameFilterSingleLetterPrefix(logger as Test.Logger) as Boolean {
  // "S Berlin" -> sep at idx 1 (odd), 1%2==1, prod=['S'], plusCheck loop doesn't run -> still true
  var nf = new $.NameFilter(
    "S Berlin",
    ['X', 'R', 'S', 'U', 'T', 'B', 'C', 'F'],
    null
  );
  return nf.getNameCleaned().equals("Berlin") && nf.getProducts() == 4;
}

(:test)
function testNameFilterMalformedPrefix(logger as Test.Logger) as Boolean {
  // "SU Berlin" -> sep at idx 2 (even), no split
  var nf = new $.NameFilter(
    "SU Berlin",
    ['X', 'R', 'S', 'U', 'T', 'B', 'C', 'F'],
    null
  );
  return nf.getNameCleaned().equals("SU Berlin") && nf.getProducts() == null;
}

(:test)
function testNameFilterPrefixWithoutPlus(logger as Test.Logger) as Boolean {
  // "SXU Berlin" -> sep at 3 (odd), but prod[1]='X', not '+' -> plusCheck false, no split
  var nf = new $.NameFilter(
    "SXU Berlin",
    ['X', 'R', 'S', 'U', 'T', 'B', 'C', 'F'],
    null
  );
  return nf.getNameCleaned().equals("SXU Berlin") && nf.getProducts() == null;
}

(:test)
function testNameFilterUnknownProductLetter(logger as Test.Logger) as Boolean {
  // "Z Berlin": Z is not in product list, so products bitfield = 0 -> returns null
  var nf = new $.NameFilter(
    "Z Berlin",
    ['X', 'R', 'S', 'U', 'T', 'B', 'C', 'F'],
    null
  );
  return nf.getNameCleaned().equals("Berlin") && nf.getProducts() == null;
}
