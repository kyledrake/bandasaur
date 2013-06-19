function SearchForm(id) {
  this.id = id;
  // this.form = $('#'+id);
}

SearchForm.prototype = {
  form: function() {
    return $('#'+this.id);
  },
  
  clearFields: function() {
    $('#'+this.id+' input[type=checkbox]').each(function(i, checkbox) {checkbox.checked = false});
  }
}