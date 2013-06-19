var Util = {
  objectify: function (queryString) {
    var result = {};
    var re = /([^&=]+)=([^&]*)/g;
    var m;

    while (m = re.exec(queryString)) {
      result[decodeURIComponent(m[1])] = decodeURIComponent(m[2]);
    }
    return result;
  }
  
}