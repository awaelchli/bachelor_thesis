% Measurements for knight scene with the following properties:
%   Light field:    9 x 9 x 512 x 512
%   Attenuator:     Tiling resolution:  3 x 3
%                   Tile resolution:    256 x 256
%                   Overlap:            50%
%                   Number of Layers:   5
%
%% SART: Plot average PSNR and average RMSE against number of SART iterations

iterations = [1, 2, 3, 4, 5, 6, 12, 24, 50, 100];
psnr = [12.874092, 14.023708, 14.522275, 14.894984, 15.191397, 15.423656, 16.303394, 17.005358, 17.425745, 17.627584];
rmse = [58.137537, 51.075596, 48.250536, 46.225376, 44.673320, 43.481093, 39.303101, 36.258923, 34.556226, 33.771028];

figure(1);
plot(iterations, psnr, 'Marker', 'square', 'MarkerFaceColor', 'auto');
title('Average peak signal-to-noise ratio (PSNR)');
xlabel('Iterations');
ylabel('PSNR (dB)');

figure(2);
plot(iterations, rmse, 'Marker', 'square', 'MarkerFaceColor', 'auto');
title('Root-mean-square error (RMSE)');
xlabel('Iterations');
ylabel('RMSE');