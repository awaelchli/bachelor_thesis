close all;

outputFolder = 'output/ortho/';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Load perspective light field data
% editor = LightFieldEditor();
% editor.inputFromImageCollection('lightFields/dice/perspective/baseline_2.7/rectified/', 'png', [10 10], 1);
% % editor.spatialSliceX(1 : 100);
% % editor.spatialSliceY(1 : 100);
% 
% editor.distanceBetweenTwoCameras = [0.3 0.3];
% d = 7;
% editor.sensorPlaneZ = d;
% perspectiveLF = editor.getPerspectiveLightField();
load('lightFields/dice/perspective/baseline_2.7/10x10x500x500/rectified/rectified');
perspectiveLF = sheared;
d = perspectiveLF.cameraPlane.z;

angularResolutionP = perspectiveLF.angularResolution;
spatialResolutionP = perspectiveLF.spatialResolution;
channels = perspectiveLF.channels;

% Parameters for the orthographic projection
FOV = [10 10];
resolutionO = [10, 10, spatialResolutionP];
sensorSize = perspectiveLF.sensorPlane.planeSize;
sensorPlane = SensorPlane(resolutionO([3, 4]), sensorSize, d);
orthographicLF = LightFieldO(zeros([resolutionO channels]), sensorPlane, FOV);

angularResolutionO = orthographicLF.angularResolution;
spatialResolutionO = orthographicLF.spatialResolution;

angularIndicesY = 1 : orthographicLF.angularResolution(1);
angularIndicesX = 1 : orthographicLF.angularResolution(2);

rayAnglesY = arrayfun(@(i) orthographicLF.rayAngle([i, 1]) * [1, 0]', angularIndicesY);
rayAnglesX = arrayfun(@(i) orthographicLF.rayAngle([1, i]) * [0, 1]', angularIndicesX);

% Grid vectors for the perspective light field
Ug = perspectiveLF.cameraPlane.cameraPositionMatrixX(1, :);
Vg = perspectiveLF.cameraPlane.cameraPositionMatrixY(:, 1);
Sg = perspectiveLF.sensorPlane.pixelPositionMatrixX(1, :);
Tg = perspectiveLF.sensorPlane.pixelPositionMatrixY(:, 1);

% Grid vectors for the orthographic light field (query points)
T = orthographicLF.sensorPlane.pixelPositionMatrixY;
S = orthographicLF.sensorPlane.pixelPositionMatrixX;

phi = repmat(rayAnglesY', [1 angularResolutionO(2)]);
theta = repmat(rayAnglesX, [angularResolutionO(1) 1]);

dtanphi = d * tan(phi);
dtantheta = d * tan(theta);

dtanphi_rep = repmat(dtanphi, [1 1 spatialResolutionO]);
dtantheta_rep = repmat(dtantheta, [1 1 spatialResolutionO]);

T = permute(repmat(T, [1 1 angularResolutionO]), [3 4 1 2]);
S = permute(repmat(S, [1 1 angularResolutionO]), [3 4 1 2]);

V = T + dtanphi_rep;
U = S + dtantheta_rep;

method = 'linear';

O1 = interpn(Vg, Ug, Tg, Sg, squeeze(perspectiveLF.lightFieldData(:, :, :, :, 1)), V, U, T, S, method);
O2 = interpn(Vg, Ug, Tg, Sg, squeeze(perspectiveLF.lightFieldData(:, :, :, :, 2)), V, U, T, S, method);
O3 = interpn(Vg, Ug, Tg, Sg, squeeze(perspectiveLF.lightFieldData(:, :, :, :, 3)), V, U, T, S, method);

O = cat(5, O1, O2, O3);

for i = 1 : angularResolutionO(1)
    for j = 1 : angularResolutionO(2)
        name = sprintf('(%i, %i).png', i, j);
        imwrite(squeeze(O(i, j, :, :, :)), [outputFolder name]);
    end
end
