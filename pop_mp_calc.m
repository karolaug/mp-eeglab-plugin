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



function [BOOK,LASTCOM] = pop_mp_calc(EEG , varargin)
    % Returns parameterised signal and plots time-frequency map
    % of it.
    %
    % Usage:
    %   >> pop_mp_calc(EEG);          % pop_up window
    %   >> mp_calc(EEG,channel_nr,epoch_nr,minS,maxS,dE,energy,iter,nfft,asym);

    
    LASTCOM = [];

    if nargin < 1
        help pop_mp_calc;
        return;
    end
    
    if isempty(EEG.data)
        error('Cannot process empty dataset');
    end

    if nargin < 3
        
        if nargin == 1
            BOOK = [];
        else
            BOOK = varargin{1};
        end
        
        if isfield(BOOK , 'decompositionSetup')
            defaults = BOOK.decompositionSetup;
        else
            defaults = [];
            defaults.channel_nr = 1;
            defaults.epoch_nr   = 1;
            defaults.minS   = floor(EEG.srate/4);
            defaults.maxS   = size(EEG.data,2);
            defaults.dE     = 0.01;
            defaults.energy = 0.99;
            defaults.iter   = 15;
            defaults.nfft   = 2*EEG.srate;
            defaults.asym   = 0;
            defaults.rect   = 0;
        end
        
        title_string = 'Parameterise a signal in time-frequency domain by means of MP procedure -- pop_mp_calc()';
        geometry = { 1 [1 1] [1 1] 1 1 [1 1] [1 1] [1 1] 1 1 [1 1] [1 1] [1 1] [1 1] [1 1]};
        uilist = { ...
         { 'style', 'text', 'string', 'Data info: ', 'fontweight', 'bold'}, ...
         { 'style', 'text', 'string', 'Channel numbers: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.channel_nr), 'tag', 'channel_nr'}, ...
         { 'style', 'text', 'string', 'Epoch numbers: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.epoch_nr), 'tag', 'epoch_nr'}, ...
         { }, ...
         { 'style', 'text', 'string', 'Dictionary info: ', 'fontweight', 'bold'}, ...
         { 'style', 'text', 'string', 'minDicStructure: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.minS), 'tag', 'minS'}, ...
         { 'style', 'text', 'string', 'maxDicStructure: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.maxS), 'tag', 'maxS'}, ...
         { 'style', 'text', 'string', 'dE: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.dE), 'tag', 'dE'}, ...
         { }, ...
         { 'style', 'text', 'string', 'Decomposition parameters: ', 'fontweight', 'bold'}, ...
         { 'style', 'text', 'string', 'Energy percentage: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.energy), 'tag', 'energy'}, ...
         { 'style', 'text', 'string', 'Maximal number of iterations: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.iter), 'tag', 'iter'}, ...
         { 'style', 'text', 'string', 'min_NFFT: ' }, ...
         { 'style', 'edit', 'string', num2str(defaults.nfft), 'tag', 'nfft'}, ...
         { 'style', 'text', 'string', 'Use asymetric functions: ' }, ...
         { 'style', 'checkbox', 'value', defaults.asym, 'tag', 'asym'}, ...
         { 'style', 'text', 'string', 'Use rectangle functions: ' }, ...
         { 'style', 'checkbox', 'value', defaults.rect, 'tag', 'rect'}, ...
         };

        [~, ~, err params] = inputgui( 'geometry', geometry, 'uilist', uilist, 'helpcom', 'pophelp(''pop_mp_calc'');', 'title' , title_string);
        if isempty(params) == 1
            return;
        end
        
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
            params.rect       = params.rect;
        catch ME1
            throw(ME1);
        end
        
    elseif nargin == 11
        % mp_calc(EEG,channel_nr,epoch_nr,minS,maxS,dE,energy,iter,nfft,asym);
        params = [];
        BOOK   = [];
                
        try
            params.channel_nr = varargin{1};
            params.epoch_nr   = varargin{2};
            params.minS       = varargin{3};
            params.maxS       = varargin{4};
            params.dE         = varargin{5};
            params.energy     = varargin{6};
            params.iter       = varargin{7};
            params.nfft       = varargin{8};
            params.asym       = varargin{9};
            params.rect       = varargin{10};
        catch ME1
            throw(ME1);
        end
    elseif nargin == 12
        % mp_calc(EEG,BOOK,channel_nr,epoch_nr,minS,maxS,dE,energy,iter,nfft,asym);
        params = [];
                
        try
            BOOK = varargin{1};

            params.channel_nr = varargin{2};
            params.epoch_nr   = varargin{3};
            params.minS       = varargin{4};
            params.maxS       = varargin{5};
            params.dE         = varargin{6};
            params.energy     = varargin{7};
            params.iter       = varargin{8};
            params.nfft       = varargin{9};
            params.asym       = varargin{10};
            params.rect       = varargin{11};
        catch ME1
            throw(ME1);
        end
    else
        disp 'Not enough input parameters -- aborting';
        return;
    end
    
    try
        BOOK.reconstruction = zeros(size(params.epoch_nr,2),size(params.channel_nr,2),params.iter,size(EEG.data,2));
        for ch = 1:1:size(params.channel_nr,2)
            for ep = 1:1:size(params.epoch_nr,2)
                sprintf('Calculations for channel: %u, epoch: %u.',ch,ep)
                [X , Y] = mp_calc(EEG,params.channel_nr(ch),params.epoch_nr(ep),params.minS,params.maxS,params.dE,params.energy,params.iter,params.nfft,params.asym,params.rect);
                BOOK.reconstruction(ep,ch,1:size(X,1),:) = X;
                BOOK.parameters(ep,ch)  = Y;
                BOOK.decompositionSetup = params;
            end
        end

        tmpstring = 'pop_mp_calc(EEG';
        
        if nargin == 12
            tmpstring = sprintf('%s%s' , tmpstring , ' , BOOK');
        end
        
        fields = fieldnames(params);
        for ind1 = 1:numel(fields)
            tmpstring = [tmpstring , ' , ' , num2str(params.(fields{ind1}))]; 
        end
        LASTCOM = [tmpstring , ');'];
        
        BOOK.epoch_labels = params.epoch_nr;

        for ind1 = 1 : size(params.channel_nr,2)
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
    catch ME1
        throw(ME1);
    end
    
    
    disp 'Done'
end
