function gui_browse_for_image_folder( handles )

path = uigetdir('', 'Select a Folder');
if path == 0 % User cancelled
    return;
end

path = fullfile([path, filesep]);
set(handles.editPath, 'String', path);

% Predict angular resolution
filetypeStr = get(handles.popupFileType, 'String');
filetypeVal = get(handles.popupFileType, 'Value');
filetype = filetypeStr(filetypeVal, :);
imageList = dir([path '*.' filetype]);
n = numel(imageList);
if n == 0
    gui_warning(handles.textImportInfo, 'No images found');
elseif rem(sqrt(n), 1) == 0
    set(handles.editAngularResY, 'String', sqrt(n)); 
    set(handles.editAngularResX, 'String', sqrt(n));
    
    % Fill in default slice indices
    set(handles.editAngularIndFromY, 'String', '1');
    set(handles.editAngularIndStepY, 'String', '1');
    set(handles.editAngularIndToY, 'String', sqrt(n));
    set(handles.editAngularIndFromX, 'String', '1');
    set(handles.editAngularIndStepX, 'String', '1');
    set(handles.editAngularIndToX, 'String', sqrt(n));
else
    set(handles.editAngularResY, 'String', 1); 
    set(handles.editAngularResX, 'String', n);
end

end

