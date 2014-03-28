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




function [reconstructing_array parameters_array] = mp_calc(EEG,channel_nr,epoch_nr,minS,maxS,dE,energy,iter,nfft,asym,rect)

if (channel_nr > EEG.nbchan) || (channel_nr < 1)
    throw(MException('MatchingPursuit:mp_calc','Nonexisting channel number.'));

elseif (epoch_nr > EEG.trials) || (epoch_nr < 1)
    throw(MException('MatchingPursuit:mp_calc','Nonexisting epoch number.'));
else
    dictionary_params = [minS maxS dE];
    disp 'Dictionary params - done';
    [book] = defineMixedInbook(dictionary_params , EEG.times , asym , rect);
    disp 'Dictionary - done';
    sig = EEG.data(channel_nr , : , epoch_nr)';
    disp 'Signal - done';
    out_book = mp6(sig , book , nfft , iter , energy , dE , 1 , EEG.srate , asym);
    disp 'Parameters - done';
    
    max_time_size = 0;
    for i = 1 : size(out_book,2)
        if size(out_book(1,i).time,2) > max_time_size
            max_time_size = size(out_book(1,i).time,2);
        end
    end
    
    reconstructing_array = zeros( size(out_book,2) , size(out_book(1).reconstruction,2));
    time_array           = zeros( size(out_book,2) , max_time_size);
    envelope_array       = zeros( size(out_book,2) , size(out_book(1).envelope,2));
    amplitude_array      = zeros( size(out_book,2) , 1);
    true_amplitude_array = zeros( size(out_book,2) , 1);
    width_array          = zeros( size(out_book,2) , 1);
    frequency_array      = zeros( size(out_book,2) , 1);
    %miu_array            = zeros( size(out_book,2) , 1);
    sigma_array          = zeros( size(out_book,2) , 1);
    
    for i = 1: size(out_book,2)
        reconstructing_array(i,:)       = out_book(1,i).reconstruction;
        envelope_array(i,:)             = out_book(1,i).envelope;
        X                               = out_book(1,i).time;
        time_array(i,1:size(X,2))       = X;
        amplitude_array(i)              = out_book(1,i).amplitude;
        true_amplitude_array(i)         = abs(out_book(1,i).amplitude) * max(envelope_array(i,:));
        frequency_array(i)              = EEG.srate * (out_book(1,i).oscilation / (2*pi));
        %miu_array(i)                    = out_book(1,i).mi;
        sigma_array(i)                  = out_book(1,i).sigma;
        
        width_array(i)                  = find_width(envelope_array(i,:),EEG.srate);
    end
    
    disp 'Reconstructing_array - done';
    parameters_array = [];
    parameters_array.envelopes      = envelope_array;
    parameters_array.times          = time_array;
    parameters_array.amplitudes     = amplitude_array;
    parameters_array.atomAmplitudes = true_amplitude_array;
    parameters_array.frequencies    = frequency_array;
    %parameters_array.mius           = miu_array;
    parameters_array.sigmas         = sigma_array;
    parameters_array.widths         = width_array;
    disp 'Parameters array - done';
    
end
end

function width = find_width(signal,srate)
    [mz mzi]=max(signal);
    
    width = sum( signal >= 0.5 * mz) / srate;
end
