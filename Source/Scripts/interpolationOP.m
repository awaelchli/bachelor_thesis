close all;

editor = LightFieldEditor();
editor.inputFromImageCollection('lightFields/dice/orthographic/7x7x384x512_fov10/', 'png', [7, 7], 1);
editor.spatialSliceX(1 : 100);
editor.spatialSliceY(1 : 100);

editor.lightFieldFOV = [10 10];
orthographicLF = editor.getOrthographicLightField();

angularResolution = orthographicLF.angularResolution;
spatialResolution = orthographicLF.spatialResolution;

angularIndicesY = 1 : orthographicLF.angularResolution(1);
angularIndicesX = 1 : orthographicLF.angularResolution(2);

rayAnglesY = arrayfun(@(i) orthographicLF.rayAngle([i, 1]) * [1, 0]', angularIndicesY);
rayAnglesX = arrayfun(@(i) orthographicLF.rayAngle([1, i]) * [0, 1]', angularIndicesX);

d = 1;

Y = orthographicLF.sensorPlane.pixelPositionMatrixY;
X = orthographicLF.sensorPlane.pixelPositionMatrixX;
% Y = flip(Y, 1);

phi = repmat(rayAnglesY', [1 angularResolution(2)]);
theta = repmat(rayAnglesX, [angularResolution(1) 1]);

dtanphi = d * tan(phi);
dtantheta = d * tan(theta);

dtanphi_rep = repmat(dtanphi, [1 1 spatialResolution]);
dtantheta_rep = repmat(dtantheta, [1 1 spatialResolution]);

Y = permute(repmat(Y, [1 1 angularResolution]), [3 4 1 2]);
X = permute(repmat(X, [1 1 angularResolution]), [3 4 1 2]);

V = Y + dtanphi_rep;
U = X + dtantheta_rep;

Yq = Y;
Xq = X;

gridResolution = [7, 7];
step = orthographicLF.sensorPlane.planeSize ./ (gridResolution - 1);
uvPlane = CameraPlane(gridResolution, step, -d);

Vq = repmat(uvPlane.cameraPositionMatrixY, [1 1 spatialResolution]);
Uq = repmat(uvPlane.cameraPositionMatrixX, [1 1 spatialResolution]);

% P = interpn(V, U, Y, X, squeeze(orthographicLF.lightFieldData(:, :, :, :, 1)), Vq, Uq, Yq, Xq);


Lo = reshape(orthographicLF.lightFieldData(:, :, :, :, 1), [], 1);
G = [V(:) U(:) Y(:) X(:)];
Q = [Vq(:) Uq(:) Yq(:) Xq(:)];

Lp = griddatan(G, Lo, Q);

Lp = reshape(Lp, [angularResolution spatialResolution]);

figure;
imshow(squeeze(Lp(1, 1, :, :)));






