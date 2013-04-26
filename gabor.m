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




function [signal, time] = gabor(sizeOfSignal,sampleFrequency,atomAmplitude,atomPosition,atomWidth,atomFrequency,atomPhase,atomType)

% the input parameters of the function should be specified in SI units:
% sampleFrequency in Hz
% width in sec.
% atomPosition in sec.    (TO JEST AKURAT W PUNKTACH, NIE W SEKUNDACH)
% atomAmplitude in uV, V etc (depends on the signal)
% atomPhase in radians (?)

time = 0:1:sizeOfSignal-1;
%parameters in samples (points):
position  = atomPosition;
width     = atomWidth*sampleFrequency;
frequency = (atomFrequency/(0.5*sampleFrequency))*pi;

if atomType=='H'
    signal = atomAmplitude*cos(frequency*time + atomPhase);
elseif atomType=='D'
    signal = zeros(size(time));
    signal(position + 1) = atomAmplitude;
elseif atomType=='N'
    signal = atomAmplitude*exp(-pi.*((time-position)/width).^2);
elseif atomType=='G'
    signal = atomAmplitude*exp(-pi.*((time-position)/width).^2).*cos(frequency.*(time-position) + atomPhase);
end

