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


function [reconstructing_array , parameters_array] = mp_multi_calc(EEG,channel_nr,epoch_nr,minS,maxS,dE,energy,iter,nfft,asym,rect)
    if (channel_nr > EEG.nbchan) || (channel_nr < 1)
        throw(MException('MatchingPursuit:mp_calc','Nonexisting channel number.'));
    elseif (epoch_nr > EEG.trials) || (epoch_nr < 1)
        throw(MException('MatchingPursuit:mp_calc','Nonexisting epoch number.'));
    else
        dictionary_params = [minS maxS dE];
        [book] = defineMixedInbook(dictionary_params , EEG.times , asym , rect);
        disp 'Dictionary - done'; 
        
        
    end

end