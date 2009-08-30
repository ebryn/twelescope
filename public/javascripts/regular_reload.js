function reload_content( target, source ) {
  $(target).load( source );
  if($('#ajax-loading').size() == 0 ) { clearInterval(reloader); }
}
