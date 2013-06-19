function Queue(player_div_id, player_start_div_id, player_container_div_id, recently_played_div_id, currently_playing_id, search_info_id) {
  this.player = $('#'+player_div_id);
  this.player_start = $('#'+player_start_div_id);
  this.player_container = $('#'+player_container_div_id);
  this.recently_played = new RecentlyPlayed($('#'+recently_played_div_id));
  this.currently_playing = $('#'+currently_playing_id);
  this.search_info = $('#'+search_info_id);

  var _this = this;
  this.player.jPlayer({
    ended: function (event) {
      _this.next();
    },
    next: function(event) {
      _this.next();
    },
    ready: function(event) {
      _this.jplayer_started = true;
      _this.start();
    },
    swfPath: "swf",
    supplied: "mp3",
    preload: "auto",
    solution: "flash, html" // Safari has issues with HTML5 player. Quick packet sniffer analysis indicated it was sending GET multiple times. Investigation needed.
  });
}

Queue.prototype = {
  search_url: '/tracks/search.json',
  last_search_criteria: [], // I think this is supposed to be just null, it gets an Object not an Array
  last_search_criteria_array: null,
  tracks: [],
  position: 0,
  jplayer_started: false,

  setLastSearchCriteria: function(query) {
    this.last_search_criteria = query;
  },

  searchWithForm: function(form) {
    this.last_search_criteria = form.serialize();
    this.last_search_criteria_array = form.serializeArray();
    this.search();
  },

  addMore: function() {
    var _this = this;
    $.get(this.search_url, this.last_search_criteria, function(new_tracks) {
      for(i=0;i<new_tracks.length;i++) {
        _this.tracks.push(new_tracks[i]);
      }
    });
  },

  drawSearchInfo: function() {
    var search_info = this.search_info;
    
//    search_info.html('You are listening to ');
    
    if(this.last_search_criteria) {
      
//      this.last_search_criteria_array.genre_ids.each( function(i, row) {
//        if(row == 
//      });
//      console.log(search_object);
    }
  },

  search: function() {
    var _this = this;
    $.get(this.search_url, this.last_search_criteria, function(ids) {
      _this.position = 0;
      _this.tracks = [];
      for(var i=0; i<ids.length;i++) {
        _this.tracks.push(new Track(ids[i]));
      }
      
      _this.drawSearchInfo();
      
      _this.player_start.css('display', 'none');
      _this.player_container.css('display', 'block');
      if(_this.jplayer_started) {
        queue.start(); // also fired when jPlayer is ready.
      }
    });
  },

  start: function() {
    if(this.tracks.length == 0) {
      return false;
    }
    this.play(this.tracks[0]);
  },

  previous: function() {
    if(this.position != 0) {
      this.position--;
      this.play(this.tracks[0]);
    }
  },

  addCurrentTrackToRecentlyPlayed: function() {
    this.recently_played.add(this.tracks[this.position]);
  },

  next: function() {
    this.player.jPlayer('stop');
    if(this.position == (this.tracks.length-1)) {
    } else {
      if(((this.tracks.length-1) - this.position) <= 2) {
        this.addMore();
      }
      this.recently_played.add(this.tracks[this.position]);
      this.position++;
      this.play(this.tracks[this.position]);
    }
  },

  displayCurrentlyPlaying: function(track) {
    this.currently_playing.html('<h1>NOW PLAYING</h1><h2>'+track.name+'</h2>'+'<h3>by '+track.artist_name+'</h3><h4><a href="'+track.file_url+'">Download</a> <small>(right click)</small></h4>');
  },

  play: function(track) {
    var _this = this;
    track.retrieveInfo(function(){
      _this.displayCurrentlyPlaying(track);
      _this.player.jPlayer("setMedia", {mp3: track.file_url});
      queue.player.jPlayer("play");
    });
  }
}
