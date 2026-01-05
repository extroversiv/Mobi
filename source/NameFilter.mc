import Toybox.Lang;

class NameFilter {
  private var _station as String;
  private var _products as Array<Char>?;
  private var _name as String?;
  private var PROD as Array?;
  private var _cleanse as (Method(args as String))?;
  function initialize(
    station as String,
    prod as Array?,
    cleanse as (Method(args as String))?
  ) {
    _station = station;
    _name = station;
    PROD = prod;
    _cleanse = cleanse;
    if (PROD != null) {
      standardSplitTypesAndName();
    }
  }
  function getName() as String {
    return _station;
  }
  function getNameCleaned() as String {
    if (_cleanse != null) {
      return _cleanse.invoke(_name);
    }
    return _name;
  }
  private function standardSplitTypesAndName() {
    var sep = _station.find(" ");
    // char before the first space must match sth. like S+U (one letter and + as separator)
    if (sep != null && sep % 2 == 1) {
      var prod = _station.substring(0, sep).toCharArray();
      var plusCheck = true;
      for (var i = 1; i < sep; i += 2) {
        if (!prod[i].equals('+')) {
          plusCheck = false;
        }
      }
      if (plusCheck) {
        _name = _station.substring(sep + 1, _station.length());
        prod.remove('+');
        _products = prod;
      }
    }
  }

  function getProducts() as Number? {
    // default is no filtering products = null
    var prod = 0;
    if (PROD != null && _products != null && _products instanceof Array) {
      for (var i = 0; i < _products.size(); i++) {
        var p = _products[i];
        for (var j = 0; j < PROD.size(); j++) {
          if (PROD[j].equals(p)) {
            prod += Math.pow(2, j);
          }
        }
      }
      return prod > 0 ? prod.toNumber() : null;
    }
    return null;
  }
}
