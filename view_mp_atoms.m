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

function [BOOK , LASTCOM] = view_mp_atoms(BOOK , check_string , varargin)

global MPatomSettings;
global EEG;
LASTCOM = [];

string_prefix  = '[BOOK , LASTCOM] = view_mp_atoms(BOOK';
string_postfix = check_string;
tmpcom = [string_prefix , ' , ''' , string_postfix , ''');'];

LASTCOM = [LASTCOM , tmpcom];

if strcmp(check_string,'new_plot')
    
    if exist('BOOK','var')==0 || isempty(BOOK)
        throw(MException('MatchingPursuit:view_mp_maps','You should calculate MP first.'));
    end
    
    MPatomSettings = [];
    MPatomSettings.title = 'Inspect signal reconstruction and single reconstructing atoms -- view_mp_atoms()';
    MPatomSettings.position = [50 50 800 500];
    MPatomSettings.trialstag = 1;
    MPatomSettings.channelstag = 1;
    MPatomSettings.atomstag = 1;
    MPatomSettings.color = [1 1 1];
    MPatomSettings.time = (1:EEG.pnts) / EEG.srate;
    MPatomSettings.figure = figure('UserData', MPatomSettings,...
      'Color', MPatomSettings.color, 'Toolbar' , 'figure' , 'name', MPatomSettings.title,...
      'MenuBar','figure','Position',MPatomSettings.position, ...
      'numbertitle', 'off', 'visible', 'on');
  
    set(MPatomSettings.figure , 'WindowKeyPressFcn' , {@key_pressed,BOOK});
    
    % positions of controlls for epochs scrolling
    posepoch = zeros(4,4);
    posepoch(1,:) = [ 0.8500    0.8000    0.0300    0.0300 ]; % < - button
    posepoch(3,:) = [ 0.8900    0.8000    0.0500    0.0300 ]; % [ - text window
    posepoch(2,:) = [ 0.9500    0.8000    0.0300    0.0300 ]; % > - button
    posepoch(4,:) = [ 0.8500    0.8500    0.1000    0.0300 ]; % _ - label
    % creation of epoch-controlls:
    MPatomSettings.e = zeros(4,1);
    MPatomSettings.e(1) = uicontrol('Parent',MPatomSettings.figure, ...
        'Units', 'normalized', ...
        'Position', posepoch(1,:), ...
        'Tag','epoch_button_left',...
        'string','<',...
        'Callback','view_mp_atoms(BOOK , ''epoch_step_left'')');
    MPatomSettings.e(2) = uicontrol('Parent',MPatomSettings.figure, ...
        'Units', 'normalized', ...
        'Position', posepoch(2,:), ...
        'Tag','epoch_button_right',...
        'string','>',...
        'Callback','view_mp_atoms(BOOK , ''epoch_step_right'')');
    MPatomSettings.e(3) = uicontrol('Parent',MPatomSettings.figure, ...
        'Units', 'normalized', ...
        'BackgroundColor',[1 1 1], ...
        'Position', posepoch(3,:), ...
        'Style','edit', ...
        'Tag','epoch_text',...
        'string', num2str(BOOK.epoch_labels(1)));
    MPatomSettings.e(4) = uicontrol('Parent',MPatomSettings.figure, ...
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
    MPatomSettings.ch = zeros(4,1);
    MPatomSettings.ch(1) = uicontrol('Parent',MPatomSettings.figure, ...
        'Units', 'normalized', ...
        'Position', poschan(1,:), ...
        'Tag','epoch_button_left',...
        'string','<',...
        'Callback','view_mp_atoms(BOOK , ''chan_step_left'')');
    MPatomSettings.ch(2) = uicontrol('Parent',MPatomSettings.figure, ...
        'Units', 'normalized', ...
        'Position', poschan(2,:), ...
        'Tag','epoch_button_right',...
        'string','>',...
        'Callback','view_mp_atoms(BOOK , ''chan_step_right'')');
    MPatomSettings.ch(3) = uicontrol('Parent',MPatomSettings.figure, ...
        'Units', 'normalized', ...
        'BackgroundColor',[1 1 1], ...
        'Position', poschan(3,:), ...
        'Style','edit', ...
        'Tag','epoch_text',...
        'string', BOOK.channel_labels{1},...
        'Enable', 'off');
    MPatomSettings.ch(4) = uicontrol('Parent',MPatomSettings.figure, ...
        'Style','text', ...
        'Units', 'normalized', ...
        'Position', poschan(4,:), ...
        'Tag','channel_button_label',...
        'string','Channel');
    % positions of a frame with parameters of atoms
    posframe = zeros(1,4);
    posframe(1,:) = [ 0.7500    0.0500    0.2300    0.4400 ]; % [] - frame
    posparam = zeros(6,4);
    posparam(1,:)  = [ 0.1000    0.9000    0.8000    0.1000 ]; % - amplitude label
    posparam(2,:)  = [ 0.2000    0.8500    0.7000    0.1000 ]; % - amplitude text
    posparam(3,:)  = [ 0.1000    0.7500    0.8000    0.1000 ]; % - width label
    posparam(4,:)  = [ 0.2000    0.6500    0.7000    0.1000 ]; % - width text
    posparam(5,:)  = [ 0.1000    0.5500    0.8000    0.1000 ]; % - frequency label
    posparam(6,:)  = [ 0.2000    0.4500    0.7000    0.1000 ]; % - frequency text
    posparam(7,:)  = [ 0.1000    0.3500    0.8000    0.1000 ]; % - latency label
    posparam(8,:)  = [ 0.2000    0.2500    0.7000    0.1000 ]; % - latency text
    posparam(9,:)  = [ 0.1000    0.1500    0.8000    0.1000 ]; % - beginning label
    posparam(10,:) = [ 0.2000    0.1000    0.7000    0.1000 ]; % - beginning text
    
    MPatomSettings.f = zeros(9,1);
    MPatomSettings.f(1) = uipanel('Title','Atom parameters:','FontSize',12,...
             'BackgroundColor','white',...
             'Position',posframe(1,:));       
    MPatomSettings.f(2) = uicontrol('Parent',MPatomSettings.f(1), ...
        'Style','text', ...
        'Units', 'normalized', ...
        'BackgroundColor','white',...
        'Position', posparam(1,:), ...
        'Tag','atom_amplitude_label',...
        'string','Amplitude:');
    MPatomSettings.f(3) = uicontrol('Parent',MPatomSettings.f(1), ...
        'Style','text', ...
        'Units', 'normalized', ...
        'BackgroundColor','white',...
        'Position', posparam(2,:), ...
        'Tag','atom_amplitude_text',...
        'string','p_t');
    MPatomSettings.f(4) = uicontrol('Parent',MPatomSettings.f(1), ...
        'Style','text', ...
        'Units', 'normalized', ...
        'BackgroundColor','white',...
        'Position', posparam(3,:), ...
        'Tag','atom_width_label',...
        'string','Width:');
    MPatomSettings.f(5) = uicontrol('Parent',MPatomSettings.f(1), ...
        'Style','text', ...
        'Units', 'normalized', ...
        'BackgroundColor','white',...
        'Position', posparam(4,:), ...
        'Tag','atom_width_text',...
        'string','w_t');
    MPatomSettings.f(6) = uicontrol('Parent',MPatomSettings.f(1), ...
        'Style','text', ...
        'Units', 'normalized', ...
        'BackgroundColor','white',...
        'Position', posparam(5,:), ...
        'Tag','atom_frequency_label',...
        'string','Frequency:');
    MPatomSettings.f(7) = uicontrol('Parent',MPatomSettings.f(1), ...
        'Style','text', ...
        'Units', 'normalized', ...
        'BackgroundColor','white',...
        'Position', posparam(6,:), ...
        'Tag','atom_frequency_text',...
        'string','f_t');
    
    MPatomSettings.f(8) = uicontrol('Parent',MPatomSettings.f(1), ...
        'Style','text', ...
        'Units', 'normalized', ...
        'BackgroundColor','white',...
        'Position', posparam(7,:), ...
        'Tag','atom_frequency_label',...
        'string','Latency:');
    MPatomSettings.f(9) = uicontrol('Parent',MPatomSettings.f(1), ...
        'Style','text', ...
        'Units', 'normalized', ...
        'BackgroundColor','white',...
        'Position', posparam(8,:), ...
        'Tag','atom_latency_text',...
        'string','l_t');
 
    MPatomSettings.f(10) = uicontrol('Parent',MPatomSettings.f(1), ...
        'Style','text', ...
        'Units', 'normalized', ...
        'BackgroundColor','white',...
        'Position', posparam(9,:), ...
        'Tag','atom_pocz_label',...
        'string','Beginning:');
    MPatomSettings.f(11) = uicontrol('Parent',MPatomSettings.f(1), ...
        'Style','text', ...
        'Units', 'normalized', ...
        'BackgroundColor','white',...
        'Position', posparam(10,:), ...
        'Tag','atom_beginning_text',...
        'string','p_t');
    
    % positions of controlls for atoms scrolling
    posatom = zeros(4,4);
    posatom(1,:) = [ 0.8500    0.5500    0.0300    0.0300 ]; % < - button
    posatom(3,:) = [ 0.8900    0.5500    0.0500    0.0300 ]; % [ - text window
    posatom(2,:) = [ 0.9500    0.5500    0.0300    0.0300 ]; % > - button
    posatom(4,:) = [ 0.8500    0.6000    0.1000    0.0300 ]; % _ - label
    % creation of atom-controlls:
    MPatomSettings.a = zeros(4,1);
    MPatomSettings.a(1) = uicontrol('Parent',MPatomSettings.figure, ...
        'Units', 'normalized', ...
        'Position', posatom(1,:), ...
        'Tag','epoch_button_left',...
        'string','<',...
        'Callback','view_mp_atoms(BOOK , ''atom_step_left'')');
    MPatomSettings.a(2) = uicontrol('Parent',MPatomSettings.figure, ...
        'Units', 'normalized', ...
        'Position', posatom(2,:), ...
        'Tag','epoch_button_right',...
        'string','>',...
        'Callback','view_mp_atoms(BOOK , ''atom_step_right'')');
    MPatomSettings.a(3) = uicontrol('Parent',MPatomSettings.figure, ...
        'Units', 'normalized', ...
        'BackgroundColor',[1 1 1], ...
        'Position', posatom(3,:), ...
        'Style','edit', ...
        'Tag','epoch_text',...
        'string', MPatomSettings.atomstag);
     MPatomSettings.a(4) = uicontrol('Parent',MPatomSettings.figure, ...
        'Style','text', ...
        'Units', 'normalized', ...
        'Position', posatom(4,:), ...
        'Tag','atom_button_label',...
        'string','Atom');
    MPatomSettings.originalaxis = axes('outerposition',[.0  .7  .8  .3]);
        plot_original(BOOK);
    MPatomSettings.reconstructaxis = axes('outerposition',[.0  .4  .8  .3]);
        plot_reconstruct(BOOK);
    MPatomSettings.atomaxis = axes('outerposition',[.0  .1  .8  .3]);
        plot_atom(BOOK);
        refresh_atom_parameters(BOOK);
        
elseif strcmp(check_string, 'epoch_step_left')
    if MPatomSettings.trialstag == 1
        disp 'No previous epochs';
    else
        disp 'Displaying previous epoch'
        MPatomSettings.trialstag = MPatomSettings.trialstag - 1;
        set(MPatomSettings.e(3),'String',num2str(BOOK.epoch_labels(MPatomSettings.trialstag)));
        if any(BOOK.reconstruction(MPatomSettings.trialstag,MPatomSettings.channelstag,MPatomSettings.atomstag,:)~=0) == 0 
            MPatomSettings.atomstag = 1;
            set(MPatomSettings.a(3),'String',num2str(MPatomSettings.atomstag));
        end
        plot_original(BOOK);
        plot_reconstruct(BOOK);
        plot_atom(BOOK);
        refresh_atom_parameters(BOOK);
    end 
elseif strcmp(check_string, 'epoch_step_right')
    if MPatomSettings.trialstag == size(BOOK.epoch_labels,2)
        disp 'No further epochs';
    else
        disp 'Displaying next epoch'
        MPatomSettings.trialstag = MPatomSettings.trialstag + 1;
        set(MPatomSettings.e(3),'String',num2str(BOOK.epoch_labels(MPatomSettings.trialstag)));
        if any(BOOK.reconstruction(MPatomSettings.trialstag,MPatomSettings.channelstag,MPatomSettings.atomstag,:)~=0) == 0 
            MPatomSettings.atomstag = 1;
        end
        plot_original(BOOK);
        plot_reconstruct(BOOK);
        plot_atom(BOOK);
        refresh_atom_parameters(BOOK);
    end  
elseif strcmp(check_string, 'chan_step_left')
    if MPatomSettings.channelstag == 1
        disp 'No previous channels';
    else
        disp 'Displaying previous channel'
        MPatomSettings.channelstag = MPatomSettings.channelstag - 1;
        set(MPatomSettings.ch(3),'String',num2str(BOOK.channel_labels{MPatomSettings.channelstag}));
        if any(BOOK.reconstruction(MPatomSettings.trialstag,MPatomSettings.channelstag,MPatomSettings.atomstag,:)~=0) == 0 
            MPatomSettings.atomstag = 1;
        end
        plot_original(BOOK);
        plot_reconstruct(BOOK);
        plot_atom(BOOK);
        refresh_atom_parameters(BOOK);
    end    
elseif strcmp(check_string, 'chan_step_right')
    if MPatomSettings.channelstag == size(BOOK.channel_labels,2)
        disp 'No further channels';
    else
        disp 'Displaying next channel'
        MPatomSettings.channelstag = MPatomSettings.channelstag + 1;
        set(MPatomSettings.ch(3),'String',num2str(BOOK.channel_labels{MPatomSettings.channelstag}));  
        if any(BOOK.reconstruction(MPatomSettings.trialstag,MPatomSettings.channelstag,MPatomSettings.atomstag,:)~=0) == 0 
            MPatomSettings.atomstag = 1;
        end
        plot_original(BOOK);
        plot_reconstruct(BOOK);
        plot_atom(BOOK);
        refresh_atom_parameters(BOOK);
    end
elseif strcmp(check_string, 'atom_step_left')
    if MPatomSettings.atomstag == 1
        disp 'No previous atoms';
    else
        disp 'Displaying previous atom'
        MPatomSettings.atomstag = MPatomSettings.atomstag - 1;
        plot_atom(BOOK);
        refresh_atom_parameters(BOOK);
    end
elseif strcmp(check_string, 'atom_step_right')
    if MPatomSettings.atomstag == size(BOOK.reconstruction(MPatomSettings.trialstag,MPatomSettings.channelstag,:,:),3) || any(BOOK.reconstruction(MPatomSettings.trialstag,MPatomSettings.channelstag,MPatomSettings.atomstag+1,:)~=0) == 0
        disp 'No further atoms';
    else
        disp 'Displaying next atom'
        MPatomSettings.atomstag = MPatomSettings.atomstag + 1;
        plot_atom(BOOK);
        refresh_atom_parameters(BOOK);
    end
    
elseif strcmp(check_string, 'spec_plot')
    
    if nargin == 5
        print vargin
        
        MPatomSettings = [];
        MPatomSettings.trialstag   = varargin{1};
        MPatomSettings.channelstag = varargin{2};
        MPatomSettings.atomstag    = varargin{3};
        MPatomSettings.time = (1:EEG.pnts) / EEG.srate;

        MPatomSettings.title = 'Inspect signal reconstruction and single reconstructing atoms -- view_mp_atoms()';
        MPatomSettings.position = [50 50 800 500];
        MPatomSettings.color = [1 1 1];
        MPatomSettings.figure = figure('UserData', MPatomSettings,...
      'Color', MPatomSettings.color, 'Toolbar' , 'figure' , 'name', MPatomSettings.title,...
      'MenuBar','figure','Position',MPatomSettings.position, ...
      'numbertitle', 'off', 'visible', 'on');
        
        MPatomSettings.originalaxis = axes('outerposition',[.025  .7  .95  .3]);
        MPatomSettings.reconstructaxis = axes('outerposition',[.025  .4  .95  .3]);
        MPatomSettings.atomaxis = axes('outerposition',[.025  .1  .95  .3]);
  
        plot_original(BOOK);
        plot_reconstruct(BOOK);
        plot_atom(BOOK , check_string);
        
    else
        disp 'Wrong number of parameters -- aborting';
        return;
    end
    
else
    disp 'Not a proper keyword -- aborting';
    return;
end

end

function plot_original(BOOK)
    global EEG;
    global MPatomSettings;
    %global BOOK;
    
    t  = BOOK.epoch_labels(MPatomSettings.trialstag);
    
    %ch = BOOK.channel_labels{MPatomSettings.chanelstag};
    ch = str2num(BOOK.channel_labels{MPatomSettings.channelstag});
    
    if isempty(ch)
        ch = BOOK.channel_indexes(MPatomSettings.channelstag);  
    end
    
    %ch = MPatomSettings.channelstag;
    plot(MPatomSettings.time , EEG.data(ch,:,t),'k','Parent',MPatomSettings.originalaxis);
    title(MPatomSettings.originalaxis,'Original signal');
    MPatomSettings.yaxlimits=get(MPatomSettings.originalaxis,'YLim');
    ylabel(MPatomSettings.originalaxis , 'Amplitude');
    xlim(MPatomSettings.originalaxis , [MPatomSettings.time(1) , MPatomSettings.time(end)]);
end
function plot_reconstruct(BOOK)
    global MPatomSettings;
    
    X = squeeze(BOOK.reconstruction(MPatomSettings.trialstag,MPatomSettings.channelstag,:,:));
    plot(MPatomSettings.time , sum(real(X),1),'k','Parent',MPatomSettings.reconstructaxis);
    title(MPatomSettings.reconstructaxis,'Signal reconstruction');
    set(MPatomSettings.reconstructaxis,'YLim',MPatomSettings.yaxlimits);
    ylabel(MPatomSettings.reconstructaxis , 'Amplitude');
    xlim(MPatomSettings.reconstructaxis , [MPatomSettings.time(1) , MPatomSettings.time(end)]);
end
function plot_atom(BOOK , varargin)
    global MPatomSettings;
    
    plot(MPatomSettings.time , squeeze(real(BOOK.reconstruction(MPatomSettings.trialstag,MPatomSettings.channelstag,MPatomSettings.atomstag,:))),'k','Parent',MPatomSettings.atomaxis);
    title(MPatomSettings.atomaxis,'Reconstructing functions');
    set(MPatomSettings.atomaxis,'YLim',MPatomSettings.yaxlimits);
    if nargin == 1
        set(MPatomSettings.a(3),'String',num2str(MPatomSettings.atomstag));
    elseif nargin == 2 && strcmp( varargin{1} , 'spec_plot') == 1 
        
    else
        disp 'Something is wrong -- aborting';
    end
    ylabel(MPatomSettings.atomaxis , 'Amplitude');
    xlabel(MPatomSettings.atomaxis , 'Time [s]');
    xlim(MPatomSettings.atomaxis , [MPatomSettings.time(1) , MPatomSettings.time(end)]);
    
    % adding vertical line at the beginning of a stimulation
    %hold on
    %plot([5,5] , [-50,50] , 'r');
    %hold off
end

function refresh_atom_parameters(BOOK)
    global EEG;    
    global MPatomSettings;
    % f(3)-pos f(5)-width f(7)-freq f(9)-lat
    
    MPatomSettings.trialstag;
    MPatomSettings.channelstag;
    MPatomSettings.atomstag;
    ampl = BOOK.parameters(MPatomSettings.trialstag,MPatomSettings.channelstag).atomAmplitudes(MPatomSettings.atomstag);
    set(MPatomSettings.f(3),'String',num2str(ampl));
    width = BOOK.parameters(MPatomSettings.trialstag,MPatomSettings.channelstag).widths(MPatomSettings.atomstag);
    set(MPatomSettings.f(5),'String',num2str(width));
    freq = BOOK.parameters(MPatomSettings.trialstag,MPatomSettings.channelstag).frequencies(MPatomSettings.atomstag);
    set(MPatomSettings.f(7),'String',num2str(freq));
    
    [~ , ind_max] = max(real(BOOK.reconstruction(MPatomSettings.trialstag,MPatomSettings.channelstag,MPatomSettings.atomstag,:)));
    lat = ind_max / EEG.srate;
    set(MPatomSettings.f(9),'String',num2str(lat));
    
    ind_pocz = find(real(BOOK.reconstruction(MPatomSettings.trialstag,MPatomSettings.channelstag,MPatomSettings.atomstag,:)) > 1 , 1);
    pocz = ind_pocz / EEG.srate;
    set(MPatomSettings.f(11),'String',num2str(pocz));
end

function key_pressed(~,eventDat,BOOK)    
    global MPatomSettings;
    
    old_trial = MPatomSettings.trialstag;
    old_atom  = MPatomSettings.atomstag;
    
    drawnow;
    
    if strcmp(eventDat.Key , 'return')
        
        MPatomSettings.trialstag = str2double(get(MPatomSettings.e(3) , 'String'));
        MPatomSettings.atomstag  = str2double(get(MPatomSettings.a(3) , 'String'));
        
        if MPatomSettings.trialstag > size(BOOK.epoch_labels,2) || MPatomSettings.trialstag < 0 || MPatomSettings.atomstag < 0 || MPatomSettings.atomstag > size(BOOK.reconstruction(MPatomSettings.trialstag,MPatomSettings.channelstag,:,:),3)
            disp 'Wrong epoch or atom number!';
            set(MPatomSettings.e(3) , 'String', num2str(old_trial));
            set(MPatomSettings.a(3) , 'String', num2str(old_atom));
        else
            plot_original(BOOK);
            plot_reconstruct(BOOK);
            plot_atom(BOOK);
            refresh_atom_parameters(BOOK);
        end
    end
end