% ~/.mutt/jed.mutt.sl
% fsCKing menu keys:
unsetkey("^[F");
unsetkey("^[B");
% emacs keybinding for jed:
() = evalfile("emacs");  
% Find signature begin, position cursor there:
if (re_fsearch("^--")) {
 call("previous_line_cmd");
} else {
 % else search headers end
 re_fsearch("^$");
 call("next_line_cmd");
}
push_mark();

