function [ lightfield ] = gui_load_lightfield_o( handles )

% Default
lightfield = [];

fov = [str2double(get(handles.editFOVY, 'String')), str2double(get(handles.editFOVX, 'String'))];

if any(isnan(fov)) || any(fov <= 0) || any(fov >= 180) 
    gui_warning(handles.textImportInfo, 'Field of view must be strictly between 0 and 180');
    return;
end
handles.data.editor.lightFieldFOV = fov;

lightfield = handles.data.editor.getOrthographicLightField();

end