function eegplugin_mpcalc(fig, try_strings, catch_strings)

if nargin < 3
throw(MException('MatchingPursuit:eegplugin_mpcalc','Function eegplugin_mp_calc requires 3 arguments, only %s given.',len(nargin)));
end;

Toolmenu = findobj(fig, 'tag', 'tools');
MPmenu = uimenu( Toolmenu, 'label', 'Matching Pursuit analysis');

com1 = [ try_strings.no_check '[EEG] = pop_mp_calc(EEG);' catch_strings.new_non_empty ];
%com2 = [ try_strings.no_check 'view_mp_results(EEG);' catch_strings.new_non_empty ];
com3 = [ try_strings.no_check 'view_mp_atoms(''new_plot'');' catch_strings.new_non_empty ];

uimenu( MPmenu, 'label', 'Calculate MP', 'callback', com1);
%uimenu( MPmenu, 'label', 'View MP results', 'callback', com2);
uimenu( MPmenu, 'label', 'Inspect single atoms', 'callback', com3);

end
