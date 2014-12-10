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




function [BOOK , LASTCOM] = view_mp_maps(BOOK , map_string , varargin)

global MPmapSettings;
global EEG;
LASTCOM = [];

if nargin == 2
    if strcmp(map_string,'new_plot')

        if exist('BOOK','var')==0 || isempty(BOOK)
            throw(MException('MatchingPursuit:view_mp_maps','You should calculate MP first.'));
        end

        MPmapSettings = [];
        MPmapSettings.title = 'Inspect time - frequency maps -- view_mp_maps()';
        MPmapSettings.position = [50 50 800 500];

        MPmapSettings.trialstag = 1;
        MPmapSettings.channelstag = 1;
        MPmapSettings.atomstag = 1;

        MPmapSettings.color = [1 1 1];
        MPmapSettings.time = [1:EEG.pnts] / EEG.srate;

        MPmapSettings.freqscale = [0 , EEG.srate / 2];
        
        MPmapSettings.freqfilt  = [0 , EEG.srate / 2];
        MPmapSettings.scalefilt = [0 , EEG.pnts / EEG.srate];

        MPmapSettings.figure = figure('UserData', MPmapSettings,...
          'Color', MPmapSettings.color, 'Toolbar' , 'figure' , 'name', MPmapSettings.title,...
          'MenuBar','figure','Position',MPmapSettings.position, ...
          'numbertitle', 'off', 'visible', 'on');
      
        set(MPmapSettings.figure , 'WindowKeyPressFcn' , {@key_pressed,BOOK});
      
        % positions of controlls for epochs scrolling
        posepoch = zeros(4,4);
        posepoch(1,:) = [ 0.8500    0.8000    0.0300    0.0300 ]; % < - button
        posepoch(3,:) = [ 0.8900    0.8000    0.0500    0.0300 ]; % [ - text window
        posepoch(2,:) = [ 0.9500    0.8000    0.0300    0.0300 ]; % > - button
        posepoch(4,:) = [ 0.8500    0.8500    0.1000    0.0300 ]; % _ - label
        % creation of epoch-controlls:
        MPmapSettings.e = zeros(4,1);
        MPmapSettings.e(1) = uicontrol('Parent',MPmapSettings.figure, ...
            'Units', 'normalized', ...
            'Position', posepoch(1,:), ...
            'Tag','epoch_button_left',...
            'string','<',...
            'Callback','view_mp_maps(BOOK , ''epoch_step_left'')');
        MPmapSettings.e(2) = uicontrol('Parent',MPmapSettings.figure, ...
            'Units', 'normalized', ...
            'Position', posepoch(2,:), ...
            'Tag','epoch_button_right',...
            'string','>',...
            'Callback','view_mp_maps(BOOK , ''epoch_step_right'')');
        MPmapSettings.e(3) = uicontrol('Parent',MPmapSettings.figure, ...
            'Units', 'normalized', ...
            'BackgroundColor',[1 1 1], ...
            'Position', posepoch(3,:), ...
            'Style','edit', ...
            'Tag','epoch_text',...
            'string', MPmapSettings.trialstag);
        MPmapSettings.e(4) = uicontrol('Parent',MPmapSettings.figure, ...
            'Style','text', ...
            'Units', 'normalized', ...
            'Position', posepoch(4,:), ...
            'Tag','epoch_button_label',...
            'string','Epoch');
        % positions of controlls for channels scrolling
        poschan = zeros(4,4);
        poschan(1,:) = [ 0.8500    0.7000    0.0300    0.0300 ]; % < - button
        poschan(3,:) = [ 0.8900    0.7000    0.0500    0.0300 ]; % [ - text window
        poschan(2,:) = [ 0.9500    0.7000    0.0300    0.0300 ]; % > - button
        poschan(4,:) = [ 0.8500    0.7500    0.1000    0.0300 ]; % _ - label
        % creation of channel-controlls:
        MPmapSettings.ch = zeros(4,1);
        MPmapSettings.ch(1) = uicontrol('Parent',MPmapSettings.figure, ...
            'Units', 'normalized', ...
            'Position', poschan(1,:), ...
            'Tag','epoch_button_left',...
            'string','<',...
            'Callback','view_mp_maps(BOOK , ''chan_step_left'')');
        MPmapSettings.ch(2) = uicontrol('Parent',MPmapSettings.figure, ...
            'Units', 'normalized', ...
            'Position', poschan(2,:), ...
            'Tag','epoch_button_right',...
            'string','>',...
            'Callback','view_mp_maps(BOOK , ''chan_step_right'')');
        MPmapSettings.ch(3) = uicontrol('Parent',MPmapSettings.figure, ...
            'Units', 'normalized', ...
            'BackgroundColor',[1 1 1], ...
            'Position', poschan(3,:), ...
            'Style','edit', ...
            'Tag','epoch_text',...
            'string', MPmapSettings.channelstag,...
            'Enable', 'off');
        MPmapSettings.ch(4) = uicontrol('Parent',MPmapSettings.figure, ...
            'Style','text', ...
            'Units', 'normalized', ...
            'Position', poschan(4,:), ...
            'Tag','channel_button_label',...
            'string','Channel');


        % positions of controlls for frequency scale controlling
        posfreqscale = zeros(4,4);
        posfreqscale(3,:) = [ 0.8500    0.4000    0.0300    0.0300 ]; % text window
        posfreqscale(1,:) = [ 0.8900    0.4000    0.0550    0.0300 ]; % set-button
        posfreqscale(2,:) = [ 0.8500    0.3500    0.1000    0.0300 ]; % default-button
        posfreqscale(4,:) = [ 0.8500    0.4500    0.1000    0.0300 ]; % label
        % creation of freqscale-controlls:
        MPmapSettings.pfs = zeros(4,1);
        MPmapSettings.pfs(1) = uicontrol('Parent',MPmapSettings.figure, ...
            'Units', 'normalized', ...
            'Position', posfreqscale(1,:), ...
            'Tag','set_scale_button',...
            'string','SET',...
            'Callback','view_mp_maps(BOOK , ''set_scale'')');
        MPmapSettings.pfs(2) = uicontrol('Parent',MPmapSettings.figure, ...
            'Units', 'normalized', ...
            'Position', posfreqscale(2,:), ...
            'Tag','set_scale_default_button',...
            'string','DEFAULT',...
            'Callback','view_mp_maps(BOOK , ''default_scale'')');
        MPmapSettings.pfs(3) = uicontrol('Parent',MPmapSettings.figure, ...
            'Units', 'normalized', ...
            'BackgroundColor',[1 1 1], ...
            'Position', posfreqscale(3,:), ...
            'Style','edit', ...
            'Tag','posfreqscale_text',...
            'string', num2str(MPmapSettings.freqscale));
        MPmapSettings.pfs(4) = uicontrol('Parent',MPmapSettings.figure, ...
            'Style','text', ...
            'Units', 'normalized', ...
            'Position', posfreqscale(4,:), ...
            'Tag','posfreqscale_label',...
            'string','Scale Settings');

        % positions of controlls for original/reconstruction checkbox
        
        posorigrec = zeros(2,4);
        posorigrec(1,:) = [ 0.8600    0.3000    0.0900    0.0300 ]; % text window
        posorigrec(2,:) = [ 0.8500    0.3000    0.0100    0.0300 ]; % set-button
        
        MPmapSettings.por = zeros(2,1);
        MPmapSettings.por(1) = uicontrol('Parent',MPmapSettings.figure, ...
            'Style','text', ...
            'Units', 'normalized', ...
            'Position', posorigrec(1,:), ...
            'Tag','posorigrec_label',...
            'string','Plot original signal');
        MPmapSettings.por(2) = uicontrol('Parent',MPmapSettings.figure, ...
            'Style','checkbox', ...
            'Units', 'normalized', ...
            'Position', posorigrec(2,:), ...
            'Value',1,...
            'Tag','posorigrec_checkbox',...
            'Callback' , 'view_mp_maps(BOOK , ''checkbox_clicked'')');
        
        % positions of controlls for filtration of resulting
        % atoms on a map
        posfilt = zeros(4,4);
        posfilt(3,:) = [ 0.8500    0.2000    0.0300    0.0300 ]; % text window - freq
        posfilt(5,:) = [ 0.8500    0.1700    0.0300    0.0300 ]; % text window - scale
        posfilt(1,:) = [ 0.8900    0.1700    0.0550    0.0600 ]; % set-button
        posfilt(2,:) = [ 0.8500    0.1100    0.1000    0.0300 ]; % default-button
        posfilt(4,:) = [ 0.8500    0.2500    0.1000    0.0300 ]; % label
        % creation of freqscale-controlls:
        MPmapSettings.pf = zeros(4,1);
        MPmapSettings.pf(1) = uicontrol('Parent',MPmapSettings.figure, ...
            'Units', 'normalized', ...
            'Position', posfilt(1,:), ...
            'Tag','set_filt_button',...
            'string','SET',...
            'Callback','view_mp_maps(BOOK , ''set_filt'')');
        MPmapSettings.pf(2) = uicontrol('Parent',MPmapSettings.figure, ...
            'Units', 'normalized', ...
            'Position', posfilt(2,:), ...
            'Tag','set_filt_default_button',...
            'string','DEFAULT',...
            'Callback','view_mp_maps(BOOK , ''default_filt'')');
        MPmapSettings.pf(3) = uicontrol('Parent',MPmapSettings.figure, ...
            'Units', 'normalized', ...
            'BackgroundColor',[1 1 1], ...
            'Position', posfilt(3,:), ...
            'Style','edit', ...
            'Tag','freq_filt_text',...
            'string', num2str(MPmapSettings.freqfilt));
        MPmapSettings.pf(4) = uicontrol('Parent',MPmapSettings.figure, ...
            'Style','text', ...
            'Units', 'normalized', ...
            'Position', posfilt(4,:), ...
            'Tag','filt_label',...
            'string','Frequency-Scale filter');
        MPmapSettings.pf(5) = uicontrol('Parent',MPmapSettings.figure, ...
            'Units', 'normalized', ...
            'BackgroundColor',[1 1 1], ...
            'Position', posfilt(5,:), ...
            'Style','edit', ...
            'Tag','scale_filt_text',...
            'string', num2str(MPmapSettings.scalefilt));
        
        
        MPmapSettings.mapaxis    = axes('outerposition',[.0  .4  .8  .6]);
        refresh_map(BOOK);

        MPmapSettings.signalaxis = axes('outerposition',[.0  .1  .8  .3]);
        refresh_signal(BOOK);

    elseif strcmp(map_string,'epoch_step_right')
        if MPmapSettings.trialstag == size(BOOK.epoch_labels,2)
            disp 'No further epochs';
        else
            disp 'Displaying next epoch'
            MPmapSettings.trialstag = MPmapSettings.trialstag + 1;
            refresh_map(BOOK);
            refresh_signal(BOOK);
        end
    elseif strcmp(map_string,'epoch_step_left')
        if MPmapSettings.trialstag == 1
            disp 'No previous epochs';
        else
            disp 'Displaying previous epoch'
            MPmapSettings.trialstag = MPmapSettings.trialstag - 1;
            refresh_map(BOOK);
            refresh_signal(BOOK);
        end
    elseif strcmp(map_string,'chan_step_right')
        if MPmapSettings.channelstag == size(BOOK.channel_labels,2)
            disp 'No further channels';
        else
            disp 'Displaying next channel';
            MPmapSettings.channelstag = MPmapSettings.channelstag + 1;
            refresh_map(BOOK);
            refresh_signal(BOOK);
        end
    elseif strcmp(map_string,'chan_step_left')
        if MPmapSettings.channelstag == 1
            disp 'No previous channels';
        else
            disp 'Displaying previous channel'
            MPmapSettings.channelstag = MPmapSettings.channelstag - 1;
            refresh_map(BOOK);
            refresh_signal(BOOK);
        end
    elseif strcmp(map_string,'set_scale')
        disp 'Setting frequency scale to the given limits';
        MPmapSettings.freqscale = str2num(get(MPmapSettings.pfs(3) , 'String'));


        if MPmapSettings.freqscale(1) > MPmapSettings.freqscale(2)
            tmp = MPmapSettings.freqscale(1);
            MPmapSettings.freqscale(1) = MPmapSettings.freqscale(2);
            MPmapSettings.freqscale(2) = tmp;
            set(MPmapSettings.pfs(3) ,'String',num2str(MPmapSettings.freqscale));
        end

        if MPmapSettings.freqscale(1) < 0 || MPmapSettings.freqscale(2) < 0
            disp 'There are no negative frequencies -- aborting';
            set(MPmapSettings.pfs(3) ,'String',num2str(MPmapSettings.freqscale));
            return;
        end

        if MPmapSettings.freqscale(2) > EEG.srate/2
            disp 'Frequencies above Nyquist threshold are non existent -- cutting to Nyquist freq';
            MPmapSettings.freqscale(2) = EEG.srate/2;
            set(MPmapSettings.pfs(3) ,'String',num2str(MPmapSettings.freqscale));
        end

        refresh_map(BOOK);

    elseif strcmp(map_string,'set_filt')
        disp 'Setting frequency-scale filtration to the given limits';
        MPmapSettings.freqfilt  = str2num(get(MPmapSettings.pf(3) , 'String'));
        MPmapSettings.scalefilt = str2num(get(MPmapSettings.pf(5) , 'String'));
        
        if MPmapSettings.freqfilt(1) > MPmapSettings.freqfilt(2)
            tmp = MPmapSettings.freqfilt(1);
            MPmapSettings.freqfilt(1) = MPmapSettings.freqfilt(2);
            MPmapSettings.freqfilt(2) = tmp;
            set(MPmapSettings.pf(3) ,'String',num2str(MPmapSettings.freqfilt));
        end
        
        if MPmapSettings.scalefilt(1) > MPmapSettings.scalefilt(2)
            tmp = MPmapSettings.scalefilt(1);
            MPmapSettings.scalefilt(1) = MPmapSettings.scalefilt(2);
            MPmapSettings.scalefilt(2) = tmp;
            set(MPmapSettings.pf(5) ,'String',num2str(MPmapSettings.scalefilt));
        end

        refresh_map(BOOK);
        refresh_signal(BOOK);
        
    elseif strcmp(map_string,'default_scale')
        disp 'Setting frequency scale to the default limits';
        MPmapSettings.freqscale = [0 , EEG.srate / 2];
        refresh_map(BOOK);
        set(MPmapSettings.pfs(3) ,'String',num2str(MPmapSettings.freqscale));

    elseif strcmp(map_string,'default_filt')
        disp 'Setting filt parameters to default values';
        MPmapSettings.freqfilt  = [0 , EEG.srate / 2];
        MPmapSettings.scalefilt = [0 , EEG.pnts/EEG.srate];
        refresh_map(BOOK);
        refresh_signal(BOOK);
        set(MPmapSettings.pf(3) ,'String',num2str(MPmapSettings.freqfilt));
        set(MPmapSettings.pf(5) ,'String',num2str(MPmapSettings.scalefilt));
        
    elseif strcmp(map_string,'checkbox_clicked')
        get(MPmapSettings.por(2) ,'Value')
        refresh_signal(BOOK);
        
    elseif strcmp(map_string,'no_plot')
        disp 'Not a proper keyword -- aborting';
        return;
    end
    
elseif nargin == 4
    if strcmp(map_string,'no_plot')
        disp 'No plot would be generated, just a map field within BOOK variable would hold the result'
        channel_nr = varargin{1};
        epoch_nr   = varargin{2};
        %freqscale  = varargin{3};
        
        [time , freqs , map] = countAmap(BOOK , 1:EEG.pnts , EEG.srate , epoch_nr , channel_nr , 0 , EEG.srate/2 , 0 , EEG.pnts/EEG.srate);
        BOOK.map.map         = map;
        BOOK.map.time        = time;
        BOOK.map.frequencies = freqs;
        BOOK.map.channel     = channel_nr;
        BOOK.map.trial       = epoch_nr;

        return;
    else
        disp 'Not a proper keyword -- aborting';
        return;
    end
    
elseif nargin == 6
    if strcmp(map_string,'no_plot')
        disp 'No plot would be generated, just a map field within BOOK variable would hold the result'
        channel_nr = varargin{1};
        epoch_nr   = varargin{2};
        freqsfilt  = varargin{3};
        scalefilt  = varargin{4};
        
        fp = freqsfilt(1);
        fk = freqsfilt(2);
        sp = scalefilt(1);
        sk = scalefilt(2);
        
        [time , freqs , map] = countAmap(BOOK , 1:EEG.pnts , EEG.srate , epoch_nr , channel_nr , fp , fk , sp , sk);
        BOOK.map.map         = map;
        BOOK.map.time        = time;
        BOOK.map.frequencies = freqs;
        BOOK.map.channel     = channel_nr;
        BOOK.map.trial       = epoch_nr;

        return;
    else
        disp 'Not a proper keyword -- aborting';
        return;
    end
    
else
    disp 'Not enough or too many input parameters -- aborting';
    return;
end

end


function refresh_map(BOOK)
    global MPmapSettings;
    global EEG;
    
    freq_p  = MPmapSettings.freqfilt(1);
    freq_k  = MPmapSettings.freqfilt(2);
    scale_p = MPmapSettings.scalefilt(1);
    scale_k = MPmapSettings.scalefilt(2);
    
    [time , freqs , map] = countAmap(BOOK , 1:EEG.pnts , EEG.srate , MPmapSettings.trialstag , MPmapSettings.channelstag , freq_p , freq_k , scale_p , scale_k);
    
    flimits = freqs(1):5:freqs(end);
    
    plotMap(time,freqs, time(1):0.5:time(end) , flimits ,abs((map)),[],MPmapSettings.freqscale,1);
    %plotMap(time,freqs, time(1):0.5:time(end) , flimits ,abs((map)),[],[0 EEG.srate/2],1);
    title(MPmapSettings.mapaxis , 'Time - Frequency map');
    %xlabel(MPmapSettings.mapaxis , 'Time [s]');
    ylabel(MPmapSettings.mapaxis , 'Frequency [Hz]');
    set(MPmapSettings.mapaxis , 'TickDir' , 'out' , 'XMinorTick' , 'on', 'YMinorTick' , 'on');
end

function refresh_signal(BOOK)
    global MPmapSettings;
    %global BOOK;
    
    X = real(squeeze(BOOK.reconstruction(MPmapSettings.trialstag,MPmapSettings.channelstag,:,:)));
    for ind_atom = 1 : size(BOOK.parameters(MPmapSettings.trialstag,MPmapSettings.channelstag).widths , 1)
        width = BOOK.parameters(MPmapSettings.trialstag,MPmapSettings.channelstag).widths(ind_atom);
        freq  = BOOK.parameters(MPmapSettings.trialstag,MPmapSettings.channelstag).frequencies(ind_atom);
        
        if freq < MPmapSettings.freqfilt(1) || freq > MPmapSettings.freqfilt(2) || width < MPmapSettings.scalefilt(1) || width > MPmapSettings.scalefilt(2)
            X(ind_atom,:) = zeros(1,size(X,2));
        end
        
    end
    plot(MPmapSettings.time , sum(X,1),'b','Parent',MPmapSettings.signalaxis);
    title(MPmapSettings.signalaxis,'Signal reconstruction');
    xlabel(MPmapSettings.signalaxis , 'Time [s]');
    ylabel(MPmapSettings.signalaxis , 'Amplitude');
    
    if get(MPmapSettings.por(2) ,'Value') == 1
        hold on;
        original =  retrieve_original_signal(BOOK);
        plot(MPmapSettings.time , original ,'r','Parent',MPmapSettings.signalaxis);
    end
    
    xlim([MPmapSettings.time(1) , MPmapSettings.time(end)]);
    set(MPmapSettings.e(3) ,'String',num2str(BOOK.epoch_labels(MPmapSettings.trialstag)));
    set(MPmapSettings.ch(3),'String',num2str(BOOK.channel_labels{MPmapSettings.channelstag}));
    hold off;
end

function original =  retrieve_original_signal(BOOK)
    global MPmapSettings;
    global EEG;
    
    ch = BOOK.channel_indexes(MPmapSettings.channelstag);
    t  = BOOK.epoch_labels(MPmapSettings.trialstag);
    
    if EEG.trials == 1
        original = EEG.data(ch,:);
    else
        original = EEG.data(ch,:,t);
    end
end


function key_pressed(~,eventDat,BOOK)    
    global MPmapSettings;
    
    old_trial = MPmapSettings.trialstag;
    
    drawnow;
    
    if strcmp(eventDat.Key , 'return')
        
        MPmapSettings.trialstag = str2double(get(MPmapSettings.e(3) , 'String'));
        
        if MPmapSettings.trialstag > size(BOOK.epoch_labels,2) || MPmapSettings.trialstag < 0
            disp 'Wrong epoch number!';
            set(MPmapSettings.e(3) , 'String', num2str(old_trial));
        else
            refresh_map(BOOK);
            refresh_signal(BOOK);
        end
    end
end