%    MP MATLAB plugin
%
%    Copyright (C) 2013 Tomasz Spustek, Konrad Kwaúkiewicz, Karol Augu≈°tin
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
%    Konrad Kwaúkiewicz <konrad.kwaskiewicz@gmail.com>
%    Karol Augu≈°tin <karol@augustin.pl>


function [ALLEEG , EEG , CURRENTSET , X] = mp_simulate(EEG, ALLEEG, CURRENTSET, name)

signal = zeros(3,512,3);

signal(1,:,1) = gabor(512,128,12,128,0.8,15,0,'G') + gabor(512,128,12,384,0.8,30,0,'G');
signal(1,:,2) = gabor(512,128,12,128,0.8,15,0,'G') + 0.10 * randn(1,512);
signal(1,:,3) = gabor(512,128,12,128,0.8,15,0,'G') + 0.50 * randn(1,512);

signal(2,:,1) = gabor(512,128,12,384,0.8,30,0,'G');
signal(2,:,2) = gabor(512,128,12,384,0.8,30,0,'G') + 0.40 * randn(1,512);
signal(2,:,3) = 0.5 * randn(1,512); %gabor(512,128,12,384,0.8,30,0,'G') + 

% additional part for bonus simulation

frequency = (15.0/(0.5*128))*pi;
symetric_alpha1  = gabor(512,128,6,128,0.95,10.0,0,'G');
symetric_alpha2  = gabor(512,128,6,386,0.95,12.0,0,'G');
symetric_alpha   = symetric_alpha1 + symetric_alpha2;
%symetric_lpc    = 12 * (gauss( 512 , 10)' .* tukeywin(512,0.05))';
noise = 0.8 * randn(1,512);

%asymetric_ssvep = exp(-pi.*((1:512)/128).^2) .* (1:512);
%asymetric_ssvep = exp(-((1:512))) + exp(((1:512)));
asymetric_ssvep = 3000 * lognpdf((1:384),log(256),1.5) .* cos(frequency .* ((1:384) - 128));
signal(3,129:end,2) = asymetric_ssvep;
signal(3,:,2) = signal(3,:,2) + symetric_alpha + noise;
%figure; plot(squeeze(signal(3,:,2)));

X = EEG;
X.setname = name;
X.nbchan  = 3;
X.trials  = 3;
X.pnts    = 512;
X.srate   = 128;
X.data    = signal;

X.a = asymetric_ssvep;
X.b = symetric_alpha1;
X.c = symetric_alpha2;

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

CURRENTSET = CURRENTSET+1;
[ALLEEG , EEG , CURRENTSET] = eeg_store(ALLEEG , X , CURRENTSET);
%EEG = pop_saveset( EEG, 'filename',strcat(name,'.set'),'filepath','/home/praceeg_1/matlab/');
%eeglab redraw;

end
