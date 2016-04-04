close all;
clc;


file = 'lightFields/cubes_bright.lfr';
cameraPath = 'C:\Users\Adrian\AppData\Local\Lytro\cameras\';

LF = loadLightFieldFromLytroFile(file, cameraPath);

angularRes = [size(LF, 1), size(LF, 2)];
spatialRes = [size(LF, 3), size(LF, 4)];

start = floor((spatialRes(2) - spatialRes(1)) / 2);

LF = LF(:, :, :, start + 1 : start + spatialRes(1), 1 : 3);
spatialRes = [size(LF, 3), size(LF, 4)];

%% Aperture view

views = cell(angularRes);

for y = 1 : angularRes(1)
    for x = 1 : angularRes(2)
        
        views{y, x} = squeeze(LF(y, x, :, :, :));
        
    end
end

img = cell2mat(views);
imshow(img);

imwrite(img, 'output/aperture_view.png');

%% Lenslet view

views = cell(angularRes);
padding = 1;

for y = 1 : spatialRes(1)
    for x = 1 : spatialRes(2)
        
        views{y, x} = padarray(squeeze(LF(:, :, y, x, :)), [padding, padding], 0);
        
    end
end

img = cell2mat(views);
imshow(img);

imwrite(img, 'output/lenslet_view.png');