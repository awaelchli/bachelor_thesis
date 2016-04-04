%% Setup the parameters for rectification

inputFolder = 'lightFields/dice/perspective/baseline_2.7/10x10x500x500/';
outputFolder = [inputFolder 'rectified/'];

% Baseline in vertical and horizontal direction
baseline = [2.7 2.7];
% Distance between the camera plane and the desired 'center'-plane of the object
d = 7;
% Horizontal field of view of the cameras
fov_h = 60;
% Number of cameras in vertical and horizontal direction
angularResolution = [10 10];
% File format
filetype = 'png';

%% Rectify light field to the desired focal plane

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

editor = LightFieldEditor();
editor.inputFromImageCollection(inputFolder, filetype, angularResolution, 1);

spatialResolution = editor.spatialResolution();

aspect = spatialResolution(2) / spatialResolution(1);
fov_v = 2 * atand((tand(fov_h / 2) / aspect));
fov = [fov_v fov_h];

delta = baseline ./ (angularResolution - 1);

s = 2 * d * tand(fov / 2);

disparity = spatialResolution .* delta ./ s;
disparity = round(disparity);

rawLF = editor.getRawLightField();
data = LightFieldEditor.shear(rawLF.lightFieldData, disparity);

cameraPlane = CameraPlane(angularResolution, delta, d);
sensorPlane = SensorPlane([size(data, 3) size(data, 4)], [1 1], 0);
rectified = LightFieldP(data, cameraPlane, sensorPlane);

%% Save the data of the rectified light field

save([outputFolder 'rectified'], 'rectified');

%% Save the individual pictures

for y = 1 : angularResolution(1)
    for x = 1 : angularResolution(2)
        
        i = sub2ind(angularResolution([2 1]), x, y);
        file = sprintf('%s%03d.png', outputFolder, i - 1);
        imwrite(squeeze(data(y, x, :, :, :)), file);
        
    end
end