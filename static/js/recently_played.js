
function RecentlyPlayed(div) {
  this.div = div;
}

RecentlyPlayed.prototype = {
  tracks: [],
  add: function(track) {
    // Make sure it isn't already present.
    for(var i=0; i < this.tracks.length; i++) {
      if(this.tracks[i] == track) {
        return;
      }
    }
    this.tracks.push(track);
    this.div.prepend('<li>'+track.name+' - '+track.artist_name+'&nbsp;&nbsp;<a href="#" onclick="queue.recently_played.play('+track.id+')">Replay</a>&nbsp;&nbsp;<a href="'+track.file_url+'">Download</a> <small>(right click)</small></li>');
  },

  play: function(id) {
    queue.addCurrentTrackToRecentlyPlayed();
    queue.play(this.getTrackWithId(id));
  },

  getTrackWithId: function(id) {
    for(var i=0; i < this.tracks.length; i++) {
      if(this.tracks[i].id == id) {
        return this.tracks[i];
      }
    }
    return null;
  }
}
