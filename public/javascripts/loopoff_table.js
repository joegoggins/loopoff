var rows_to_export = [];
var container_id = "loopoff_container_1";
var actions=[
	'playlist_info',
	'playlist_oldest',
	'playlist_previous',
	'playlist_next',
	'playlist_newest',
	'row_load',
	'row_reload',
	'row_play',
	'row_play_looped',
	'row_pause',
	'row_stop',
	'cell_toggle_mute',
	'export_selected',
	'add_selected_to_playlist',
	'delete_row_from_playlist'
];

$(document).ready(function() {	
	// KEYBOARD SHORTCUTS
	function handle_key_down(evt) {
		console.info(evt.keyCode);
		// j = row_down
		// k = row_up
		// space = play looped | pause
		// enter = load row
		// a = toggle mute cell 1
		// s = toggle mute cell 2
		// d = toggle mute cell 3
		// x = mark the row's checkbox

    // h = go to previous playlist
    // l = go to next playlist

    // WOULD BE Nice to not hijack anything with modifiers...this doesnt work
    // if(!evt.shiftKey && !evt.ctrlKey && !evt.altKey) // No Modifiers
    //   evt.preventDefault();
    
    
		switch(evt.keyCode) {
			case 74: _k_row_down(evt); break;			
			case 75: _k_row_up(evt); break;			
			case 13: _k_load_row(evt); break;			
			case 32: _k_toggle_row_play(evt); evt.preventDefault(); break;			
			case 65: _k_toggle_cell_mute(evt,0); break;			
			case 83: _k_toggle_cell_mute(evt,1); break;			
			case 68: _k_toggle_cell_mute(evt,2); break;			
			case 88: _k_toggle_row_checkbox(evt); break;					
			case 72: _k_previous_playlist(evt); break;					
			case 76: _k_next_playlist(evt); break;					
		}
	}
	$(document).bind('keydown',handle_key_down);
	function _k_row_down(evt) {
		console.info('row_down called'); return false;
	}
	function _k_row_up(evt) {
		console.info('row_up called'); return false;
	}
	function _k_load_row(evt) {
		console.info('load_row called'); return false;
	}
	function _k_toggle_row_play(evt) {
		console.info('toggle_row_play called'); return false;
	}
	function _k_toggle_row_checkbox(evt) {
		console.info('toggle_row_checkbox called');
	}
	function _k_toggle_cell_mute(evt,cell_index) {
		console.info('toggle_cell_mute called for ' + cell_index);
	}
	function _k_previous_playlist(evt,cell_index) {
		console.info('previous_playlist called for');
	}
	function _k_next_playlist(evt,cell_index) {
		console.info('next_playlist called for ');
	}
	
	
	/////////// LOOPOFF TABLE ACTIONS
  function playlist_info(event) {
	  $('#playlist_info_content').jqmShow();
  }
  function playlist_oldest(event) {}
  function playlist_previous(event) {}
  function playlist_next(event) {}
  function playlist_newest(event) {}
  function row_load(event) {
	  console.log(event.target);
	  $(event.target).closest('tr').find('td.audio_cell').each(function() {      
      $(this).prepend('L<audio src="' + $(this).attr('rel') + '" autobuffer="autobuffer" loop="loop"></audio>')
      //$(event.target).siblings('input[name=do_export]').attr('checked','checked') //select for export
	  })
  }
  function row_reload(event) {}
  function row_play(event) {
	  $(event.target).closest('tr').find('audio').map(function () { 
		  pause_and_reset_playhead_if_playing(this);
		  $(this).unbind('ended');
		  this.play()
		});
  }
  function row_play_looped(event) {
	  $(event.target).closest('tr').find('audio').each(function () { 
		  pause_and_reset_playhead_if_playing(this);
		  $(this).bind('ended',{},function() {
			  $(this).trigger('play');
		  });
		  this.play();
		});
  }
  function row_pause(event) {
	  $(event.target).closest('tr').find('audio').map(function () {this.pause()});
  }

  function row_stop(event) {
	  row_pause(event);
	  $(event.target).closest('tr').find('audio').each(function () {
		  this.currentTime = 0;
		});
  }
  function export_selected(evt) {
	  console.info("export_selected called")
	  rows_to_export = [];
    $('.controller_cell input[type=checkbox]').each(function() {		  
		  if($(this).attr('checked')) {
			  rows_to_export.push($(this).val());
			  $(this).removeAttr('checked');
		  }
	  })
	  console.info("sending request to copy files to server");
	  var export_dir = $.urlParam('export_dir');
	  if(rows_to_export.length == 0) {
		  alert('ERROR: No rows selected');
	    return false;
	  }
	  
	  var export_options ={"rows":rows_to_export,"export_dir":export_dir};
		$.getJSON($(evt.target).attr('rel'),export_options, function(json) {
		  console.info(json);
		  if(json != null && json.status == "success") {
			$(evt.target).after(' Exported');			
		  }
		  else {
			$(evt.target).after(' FAILURE');			
		  }
		  
		});
  } 

  function add_selected_to_playlist(evt) {
	  // TODO: REFACTOR DUPLICATION with export_selected function
	  rows_to_export = [];
    $('.controller_cell input[type=checkbox]').each(function() {		  
		  if($(this).attr('checked')) {
			  rows_to_export.push($(this).val());
			  $(this).removeAttr('checked');
		  }
	  })
	  if(rows_to_export.length == 0) {
		  alert('ERROR: No rows selected');
	    return false;
	  }
	  
	  //var export_dir = $.urlParam('export_playlist_id');
	  //playlists/<ID>/add_selected?commit_id=<X>&blob_ids=<B1>,<B2>,<B3>
		var playlist_options ={"rows":rows_to_export,"playlist_export_id":"1"}; //HARD CODED to 1
		$.getJSON($(evt.target).attr('rel'),playlist_options, function(json) {
		  console.info(json);
		  if(json != null && json.status == "success") {
			$(evt.target).after(' Exported');			
		  }
		  else {
			$(evt.target).after(' FAILURE');			
		  }
		  
		});
  }

  function delete_row_from_playlist(evt) {
	  var x = confirm("Are you sure you want to delete this file reference from the playlist?");
	  if(!x) {
		  return false;
	  }
		$.getJSON($(evt.target).attr('rel'),{}, function(json) {
			if(json != null && json.status == "success") {
			  $(evt.target).closest('tr').remove();
		  }
		  else {
			  $(evt.target).after(' FAILURE');			
		  }		  
		});	 
  }

	function cell_toggle_mute(evt) {
		var audio_obj = $(evt.target).closest('td.audio_cell').find('audio')[0];
		if(audio_obj == null) {
		  alert('Error, could not find the audio obj to mute');	
		}
		if(audio_obj.volume > 0) {
		  audio_obj.volume = 0;
		}
		else {
		  audio_obj.volume = 1;
		}		
  }

  ///////////////// HELPER FUNCTIONS BEGIN
  function pause_and_reset_playhead_if_playing(audio_inst) {
	  if(!audio_inst.paused) {
		  audio_inst.pause();
		  audio_inst.currentTime = 0;
	  }
  }

  // http://snipplr.com/view/11583/retrieve-url-params-with-jquery/
	$.urlParam = function(name) {
	  var results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(window.location.href);
	  if(results == null) {
		  return "";
	  }
	  else {
		  return results[1];
	  }
	}

  ///////////////// HELPER FUNCTIONS END


  // THE MOST IMPORTANT STUFF...bind all action css classes
  // with functions that handle their stuff
	$(actions).each(function(index) {
		$('.' + this).each(function() {
      //console.info(this);
      $(this).bind('click',{},eval(actions[index]));
		})
	})		
  $('#playlist_info_content').jqm();

  //////// DROP DOWN MENUS
  $('select#input_dir').change(function(evt) {
	  document.location.href = $(evt.target).val();
	  console.info($(evt.target).val());
  });  
});

