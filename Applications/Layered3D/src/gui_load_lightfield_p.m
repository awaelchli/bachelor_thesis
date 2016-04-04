function [ lightfield ] =  gui_load_lightfield_p( handles )

% Default
lightfield = [];

baseline = [str2double(get(handles.editBaselineY, 'String')), str2double(get(handles.editBaselineX, 'String'))];
cameraPlaneZ = str2double(get(handles.editCameraPlaneZ, 'String'));

if any(isnan(baseline)) || any(baseline <= 0) 
    gui_warning(handles.textImportInfo, 'Invalid baseline');
    return;
end
handles.data.editor.distanceBetweenTwoCameras = baseline ./ (handles.data.editor.angularResolution - 1);

if isnan(cameraPlaneZ)
    gui_warning(handles.textImportInfo, 'Invalid Z value for camera plane');
    return;
end
handles.data.editor.cameraPlaneZ = cameraPlaneZ;

lightfield = handles.data.editor.getPerspectiveLightField();


end

