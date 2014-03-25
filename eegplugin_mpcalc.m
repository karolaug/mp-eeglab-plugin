%    MP MATLAB plugin
%
%    Copyright (C) 2013 Tomasz Spustek, Konrad Kwaśkiewicz, Karol Auguštin
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%    Tomasz Spustek <tomasz@spustek.pl>
%    Konrad Kwaśkiewicz <konrad.kwaskiewicz@gmail.com>
%    Karol Auguštin <karol@augustin.pl>




function eegplugin_mpcalc(fig, try_strings, catch_strings)

if nargin < 3
    throw(MException('MatchingPursuit:eegplugin_mpcalc','Function eegplugin_mp_calc requires 3 arguments, only %s given.',len(nargin)));
end;

Toolmenu = findobj(fig, 'tag', 'tools');
MPmenu = uimenu( Toolmenu, 'label', 'Matching Pursuit analysis');

com1 = [ try_strings.no_check '[EEG,BOOK] = pop_mp_calc(EEG);' catch_strings.new_non_empty ];
com2 = [ try_strings.no_check 'view_mp_maps(''new_plot'');' catch_strings.new_non_empty ];
com3 = [ try_strings.no_check 'view_mp_atoms(''new_plot'');' catch_strings.new_non_empty ];

uimenu( MPmenu, 'label', 'Calculate MP', 'callback', com1);
uimenu( MPmenu, 'label', 'View time - frequency maps', 'callback', com2);
uimenu( MPmenu, 'label', 'Inspect resulting decomposition', 'callback', com3);

end
