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

function jump_to_row_index(target) {
	var cur_index = selected_row_index();
	$($('.selected_row')[target]).css('visibility','visible');
  $($('.selected_row')[cur_index]).css('visibility','hidden');  
}
function selected_row_index() {
	var to_return;
	$('.selected_row').each(function(index) {			
	  if($(this).css('visibility') == 'visible') {
		  to_return = index;
	  }	
	});
	return to_return;				
}

function total_rows() {
 	return $('.selected_row').length;
}

function selected_row() {
  return $($('.selected_row')[selected_row_index()]).closest('tr');	
}
// KEYBOARD SHORTCUTS BEGIN
//$('.controller_cell:first img.selected_row').css('visibility','visible')
function handle_key_down(evt) {
	console.info(evt.keyCode);
	
	


	
	
	
	
	


  // WOULD BE Nice to not hijack anything with modifiers...this doesnt work
  // if(!evt.shiftKey && !evt.ctrlKey && !evt.altKey) // No Modifiers
  //   evt.preventDefault();
  
  
	switch(evt.keyCode) {
		case 74: _k_row_down(evt); break;	// j = row_down
		case 75: _k_row_up(evt); break;		// k = row_up	
		case 76: _k_load_row(evt); break;	// l = load row	
		case 32:  // space = play looped or stop, preventDefault prevents space from moving scroll
		  var lstate =  selected_row().find('audio').data('loopoff_state');
		  if(lstate == 'stopped' || lstate == undefined) {
			  _k_row_play_looped(evt);  			  
		  }
		  else {
			  _k_row_stop(evt);
		  }		  
		  evt.preventDefault(); 
		  break;		
		case 80: _k_row_play(evt); break; // p = play regular			
		case 999: _k_row_pause(evt); break;			
		case 65: _k_toggle_cell_mute(evt,0); break;		// a = toggle mute cell 1	
		case 83: _k_toggle_cell_mute(evt,1); break;		// s = toggle mute cell 2	
		case 68: _k_toggle_cell_mute(evt,2); break;		// d = toggle mute cell 3	
		case 88: _k_toggle_row_checkbox(evt); break;	// x = mark the row's checkbox	
//		case 72: _k_previous_playlist(evt); break;						  // h = go to previous playlist
//		case 76: _k_next_playlist(evt); break;						   
	}
}

function _k_row_down(evt) {
	console.info('row_down called');
	var cur_index = selected_row_index();
	if(cur_index + 1 >= total_rows()) {
		return false;
	}
	jump_to_row_index(cur_index + 1);
	return false;
}
function _k_row_up(evt) {
	console.info('row_up called'); 
	var cur_index = selected_row_index();
	if(cur_index == 0) {
		return false;
	}
	jump_to_row_index(cur_index - 1 );
	return false;
}
function _k_load_row(evt) {
	console.info('load_row called'); 
	selected_row().find('.row_load').click();	
	return false;
}
function _k_row_play(evt) {
	console.info('toggle_row_play called'); 
  selected_row().find('.row_play').click()
	return false;
}

function _k_row_play_looped(evt) {
	console.info('_k_row_play_looped called'); 
  selected_row().find('.row_play_looped').click()
	return false;
}

function _k_row_stop(evt) {
	console.info('_k_row_stop called'); 
  selected_row().find('.row_stop').click()
	return false;
}
function _k_row_pause(evt) {
	console.info('_k_row_pause called'); 
  selected_row().find('.row_pause').click()
	return false;
}
function _k_toggle_row_checkbox(evt) {
	console.info('toggle_row_checkbox called');
	var chk =selected_row().find('input[name=do_export]');
	if(chk.attr('checked')) {
    chk.removeAttr('checked');	
	}
	else {
	  chk.attr('checked','checked');	
	}
	
	return false;
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

// KEYBOARD SHORTCUTS END




/////////// LOOPOFF TABLE CORE ACTIONS BEGIN
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
	  $(this).data('loopoff_state','playing');
	});
}
function row_play_looped(event) {
  $(event.target).closest('tr').find('audio').each(function () { 
	  pause_and_reset_playhead_if_playing(this);
	  $(this).bind('ended',{},function() {
		  $(this).trigger('play');
	  });
	  this.play();
	  $(this).data('loopoff_state','playing');
	});
}
function row_pause(event) {
  $(event.target).closest('tr').find('audio').each(function () {
	  this.pause()
	  $(this).data('loopoff_state','paused');
	}); 
}

function row_stop(event) {
  row_pause(event);
  $(event.target).closest('tr').find('audio').each(function () {
	  this.currentTime = 0;
	  $(this).data('loopoff_state','stopped');
	}); 
}
function export_selected(evt) {
  console.info("export_selected called")
  rows_to_export = [];
  // WARNING use name=do_export instead more specific
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


$(document).ready(function() {	
	$(document).bind('keydown',handle_key_down);


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


  if(document.location.hash.length > 0) {
	  //DOES NOT WORK
	  //// TODO SET currently selected row from url hash
	  $(document.location.hash).closest('tr').find('img.selected_row').css('visibility','visible');
  }
  else {
	  $('.controller_cell:first img.selected_row').css('visibility','visible');
  }
	
  // ACTUAL MANIPULATION DOM END
});

