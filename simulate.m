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

%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.

%    Tomasz Spustek <tomasz@spustek.pl>
%    Konrad Kwaśkiewicz <konrad.kwaskiewicz@gmail.com>
%    Karol Auguštin <karol@augustin.pl>




function [ALLEEG , EEG , CURRENTSET] = simulate(EEG, ALLEEG, CURRENTSET, name)

signal = zeros(2,512,3);

signal(1,:,1) = gabor(512,128,12,128,0.8,15,0,'G') + gabor(512,128,12,384,0.8,30,0,'G');
signal(1,:,2) = gabor(512,128,12,128,0.8,15,0,'G') + 0.10 * randn(1,512);
signal(1,:,3) = gabor(512,128,12,128,0.8,15,0,'G') + 0.50 * randn(1,512);

signal(2,:,1) = gabor(512,128,12,384,0.8,30,0,'G');
signal(2,:,2) = gabor(512,128,12,384,0.8,30,0,'G') + 0.40 * randn(1,512);
signal(2,:,3) = 0.5 * randn(1,512); %gabor(512,128,12,384,0.8,30,0,'G') + 

X = EEG;
X.setname = name;
X.nbchan  = 2;
X.trials  = 3;
X.pnts    = 512;
X.srate   = 128;
X.data    = signal;



% figure;
% plot(X.data(1,:,1));
% figure;
% plot(X.data(1,:,2));
% figure;
% plot(X.data(1,:,3));
% figure;
% plot(X.data(2,:,1));
% figure;
% plot(X.data(2,:,2));
% figure;
% plot(X.data(2,:,3));


[ALLEEG , EEG , CURRENTSET] = eeg_store(ALLEEG , X , CURRENTSET+1);
%EEG = pop_saveset( EEG, 'filename',strcat(name,'.set'),'filepath','/home/praceeg_1/matlab/');
%eeglab redraw;

end
