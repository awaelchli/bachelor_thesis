% Measurements for knight scene with the following properties:
%   Light field:    9 x 9 x 512 x 512
%   Attenuator:     Tiling resolution:  3 x 3
%                   Tile resolution:    256 x 256
%                   Overlap:            50%
%   Optimization:   SART, 6 iterations
%
%% Plot average PSNR and average RMSE against number of layers

numberOfLayers = [2, 3, 4, 5, 6,    10];
psnr = [13.168523, 14.899946, 15.275418, 15.430435, 15.423656                    , 15.455257];
rmse = [56.267586, 46.204259, 44.242874, 43.458037, 43.481093 ,                    43.317356];

figure(1);
plot(numberOfLayers, psnr, 'Marker', 'square', 'MarkerFaceColor', 'auto');
title('Average peak signal-to-noise ratio (PSNR)');
xlabel('Layers');
ylabel('PSNR (dB)');

figure(2);
plot(numberOfLayers, rmse, 'Marker', 'square', 'MarkerFaceColor', 'auto');
title('Root-mean-square error (RMSE)');
xlabel('Layers');
ylabel('RMSE');
