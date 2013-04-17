function view_mp_atoms(check_string , EEG)

figh = figure;

% positions of buttons
  posbut = zeros(2,4);
  posbut(1,:) = [ 0.0924    0.0254    0.0288    0.0339 ]; % <
  posbut(2,:) = [ 0.1924    0.0254    0.0299    0.0339 ]; % >

% creation of move buttons:
  u = zeros(2,1);

  u(1) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(1,:), ...
	'Tag','button_left',...
	'string','<',...
	'Callback','view_mp_atoms(''step_left'',EEG)');

  u(2) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(2,:), ...
	'Tag','button_right',...
	'string','>',...
	'Callback','view_mp_atoms(''step_right'',EEG)');

% plot of original signal
subplot(211);
plot(EEG.data(1,:,1));

% plot of it's reconstruction
subplot(212);
plot(real(EEG.book(1,1).reconstruction));

end