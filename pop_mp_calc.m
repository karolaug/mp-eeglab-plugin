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



function [EEG,BOOK] = pop_mp_calc(EEG)
% Returns parameterised signal and plots time-frequency map
% of it.
%
% Usage:
%   >> pop_mp_calc(EEG);          % pop_up window
%   >> mp_calc(EEG,channel_nr,epoch_nr,minS,maxS,dE,energy,iter,nfft);

global BOOK;

title_string = 'Parameterise a signal in time-frequency domain by means of MP procedure -- pop_mp_calc()';
geometry = { 1 [1 1] [1 1] 1 1 [1 1] [1 1] [1 1] 1 1 [1 1] [1 1] [1 1] [1 1] };
uilist = { ...
         { 'style', 'text', 'string', 'Data info: ', 'fontweight', 'bold'}, ...
         { 'style', 'text', 'string', 'Channel numbers: ' }, ...
         { 'style', 'edit', 'string', '1', 'tag', 'channel_nr'}, ...
         { 'style', 'text', 'string', 'Epoch numbers: ' }, ...
         { 'style', 'edit', 'string', '1', 'tag', 'epoch_nr'}, ...
         { }, ...
         { 'style', 'text', 'string', 'Dictionary info: ', 'fontweight', 'bold'}, ...
         { 'style', 'text', 'string', 'minDicStructure: ' }, ...
         { 'style', 'edit', 'string', num2str(floor(EEG.srate/4)), 'tag', 'minS'}, ...
         { 'style', 'text', 'string', 'maxDicStructure: ' }, ...
         { 'style', 'edit', 'string', num2str(size(EEG.data,2)), 'tag', 'maxS'}, ...
         { 'style', 'text', 'string', 'dE: ' }, ...
         { 'style', 'edit', 'string', '0.01', 'tag', 'dE'}, ...
         { }, ...
         { 'style', 'text', 'string', 'Decomposition parameters: ', 'fontweight', 'bold'}, ...
         { 'style', 'text', 'string', 'Energy percentage: ' }, ...
         { 'style', 'edit', 'string', '0.95', 'tag', 'energy'}, ...
         { 'style', 'text', 'string', 'Maximal number of iterations: ' }, ...
         { 'style', 'edit', 'string', '15', 'tag', 'iter'}, ...
         { 'style', 'text', 'string', 'min_NFFT: ' }, ...
         { 'style', 'edit', 'string', num2str(2 * EEG.srate), 'tag', 'nfft'}, ...
         { 'style', 'text', 'string', 'Use asymetric functions (1 or 0): ' }, ...
         { 'style', 'checkbox', 'value', 1, 'tag', 'asym'}, ...
         };

[~, ~, err params] = inputgui( 'geometry', geometry, 'uilist', uilist, 'helpcom', 'pophelp(''pop_mp_calc'');', 'title' , title_string);

% try
%     EEG = rmfield(EEG , 'book');
% catch ME2
% end
    
try
    params.channel_nr = str2num(params.channel_nr);
    params.epoch_nr   = str2num(params.epoch_nr);
    params.dE         = str2num(params.dE);
    params.minS       = str2num(params.minS);
    params.maxS       = str2num(params.maxS);
    params.iter       = str2num(params.iter);
    params.nfft       = str2num(params.nfft);
    params.energy     = str2num(params.energy);
    params.asym       = params.asym;

    BOOK.reconstruction = zeros(size(params.epoch_nr,2),size(params.channel_nr,2),params.iter,size(EEG.data,2));
    for ch = 1:1:size(params.channel_nr,2)
        for ep = 1:1:size(params.epoch_nr,2)
            sprintf('Calculations for channel: %u, epoch: %u.',ch,ep)
            [X , Y] = mp_calc(EEG,params.channel_nr(ch),params.epoch_nr(ep),params.minS,params.maxS,params.dE,params.energy,params.iter,params.nfft,params.asym);
            BOOK.reconstruction(ep,ch,1:size(X,1),:) = X;
            BOOK.parameters(ep,ch) = Y;
        end
    end
    
    BOOK.epoch_labels = params.epoch_nr;
    
    for ind1 = 1 : size(params.epoch_nr)
       BOOK.channel_indexes(ind1) = params.channel_nr(ind1); 
    end
    
    if ~isempty(EEG.chanlocs)
        for i = 1:size(params.channel_nr,2)
            BOOK.channel_labels{i} = EEG.chanlocs(1,params.channel_nr(i)).labels;
        end
    else
        for i = 1:size(params.channel_nr,2)
            BOOK.channel_labels{i} = num2str(params.channel_nr(i));
        end
    end
    disp 'Done'

    
catch ME1
idSegLast = regexp(ME1.identifier, '(?<=:)\w+$', 'match');
if strcmp(idSegLast, 'nonStrucReference')
    disp 'Aborted by user'
else
    throw(ME1);

end
end
