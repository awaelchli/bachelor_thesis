function gui_browse_for_matlab_file( handles )

[filename, path, ~] = uigetfile({'*.mat', 'MATLAB Files (*.mat)'}, 'Select a MATLAB File');
if filename == 0 % User cancelled
    return;
end

matlabFile = fullfile(path, filename);
set(handles.editPath, 'String', matlabFile);

mat = matfile(matlabFile);

[angularResY, angularResX, ~] = size(mat, 'lightFieldArray');

set(handles.editAngularResY, 'String', angularResY);
set(handles.editAngularResX, 'String', angularResX);

set([handles.checkboxInvY, handles.checkboxInvX], 'Value', 0);

% TODO: check existance of variables
load(matlabFile, 'projectionType', 'fov', 'baseline', 'cameraPlaneZ', 'imagePlaneSize', 'imagePlaneZ');

if strcmpi(projectionType, 'Perspective')
    set(handles.popupProjectionType, 'Value', 1);
    set([handles.editFOVY, handles.editFOVX], 'Enable', 'off');
    set([handles.editFOVY, handles.editFOVX], 'String', '');
    set([handles.editBaselineY, handles.editBaselineX, handles.editCameraPlaneZ], 'Enable', 'On');
    set(handles.editBaselineY, 'String', baseline(1));
    set(handles.editBaselineX, 'String', baseline(2));
    set(handles.editCameraPlaneZ, 'String', cameraPlaneZ);
end
if strcmpi(projectionType, 'Oblique')
    set(handles.popupProjectionType, 'Value', 2);
    set([handles.editFOVY, handles.editFOVX], 'Enable', 'On');
    set(handles.editFOVY, 'String', fov(1));
    set(handles.editFOVX, 'String', fov(2));
    set([handles.editBaselineY, handles.editBaselineX, handles.editCameraPlaneZ], 'Enable', 'Off');
    set([handles.editBaselineY, handles.editBaselineX, handles.editCameraPlaneZ], 'String', '');
end

set(handles.sliderSpatialScale, 'Value', 1);
set(handles.editSpatialScale, 'String', 1);

set([handles.editAngularIndFromY, handles.editAngularIndFromX, ...
    handles.editAngularIndStepY, handles.editAngularIndStepX], 'String', 1);

set(handles.editAngularIndToY, 'String', angularResY);
set(handles.editAngularIndToX, 'String', angularResX);

set(handles.editSensorSizeY, 'String', imagePlaneSize(1));
set(handles.editSensorSizeX, 'String', imagePlaneSize(2));
set(handles.editSensorPlaneZ, 'String', imagePlaneZ);

end

