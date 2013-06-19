function Track(id) {
  this.id = id;
}

Track.prototype = {
  info_loaded: false,

  retrieveInfo: function(callback) {
    if(this.info_loaded == true) {
      callback();
    } else {
      var _this = this;
      $.get('/tracks/'+this.id+'.json', function(r) {
        _this.name = r.name;
        _this.artist_name = r.artist_name;
        _this.file_url = r.file_url;
        _this.genres = r.genres;
        _this.city = r.city;
        _this.state = r.state;
        _this.country = r.country;
        _this.info_loaded = true;
        callback();
      });
    }
  }
}