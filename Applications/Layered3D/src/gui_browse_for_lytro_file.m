function gui_browse_for_lytro_file( handles )

[filename, path, ~] = uigetfile({'*.lfr;*.lfx;*.lfp',...
                                'Lytro Files (*.lfr, *.lfx, *.lfp)'}, 'Select Lytro file');
if filename == 0 % User cancelled
    return;
end

set(handles.editPath, 'String', fullfile(path, filename));

end