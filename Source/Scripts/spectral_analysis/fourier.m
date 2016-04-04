close all;
clc;

inputEPI = 'thesis/Document/Figures/epi_1x500x1000x1000/scanY=641.png';
% inputEPI = 'thesis/Document/Figures/epi_1x500x1000x1000/rectified/scanY=641.png';
% inputEPI = 'lightFields/constant/one_object1.png';
% inputEPI = 'lightFields/constant/one_object2.png';
% inputEPI = 'lightFields/constant/one_object4.png';
% inputEPI = 'lightFields/constant/one_object4.png';
% inputEPI = 'lightFields/constant/two_objects.png';
inputEPI = 'lightFields/constant/set1/layer1.png';
% inputEPI = 'lightFields/constant/three_dice_lambertian.png';

% Name and location to store the fourier image as .mat file
output = 'output/fft_layer_1.mat';

%% Read input
I = imread(inputEPI);
Igray = rgb2gray(I);

%% Windowing
% Using Hann window

[M, N] = size(Igray);
w1 = hann(M)';
w2 = hann(N)';
w = w1' * w2;
IgrayWindowed = im2uint8(im2single(Igray) .* w);

figure;
imshow(IgrayWindowed)

Igray = IgrayWindowed;

%% Padding

Igray = padarray(Igray, [300, 300], 0);
figure;
imshow(Igray);

%% Fourier transform

f = fft2(double(Igray));
% Putting DC in the middle:
f = fftshift(f);

%% Masking

cut_off = 300;

Z_u = -10;
Z_s = 0;
z = 1;

ds_du = (z - Z_s) / (z - Z_u);
epsilon = 2;

xi_s = linspace(-500, 500, 1000);
xi_u = linspace(500, -500, 1000)';

xi_s = repmat(xi_s, [size(xi_u, 1), 1]);
xi_u = repmat(xi_u, [1, size(xi_s, 2)]);

inds = abs(ds_du * xi_s + xi_u) <= epsilon & abs(xi_s) <= cut_off;

f(~inds) = 0;

%% Display spectrum

% Taking the spectrum with log scaling
spectrum = log(1 + abs(f));
% Finding maximum in spectrum:
maximum = max(max(spectrum));
minimum = min(min(spectrum));
% Scaling maximum to 255 and minimum to 0:
spectrum = (spectrum - minimum) / (maximum - minimum);

save(output, 'f', 'spectrum');

figure;
subplot(1, 2, 1);
imagesc(spectrum);
axis equal image;
colormap jet;
title('$ \log (1 + \textrm{abs} ( \hat{f} ) )$', 'interpreter', 'latex');

subplot(1, 2, 2);
clamp = 0.5;
imagesc(spectrum > clamp);
axis equal image;
colormap jet;
title(['$ \log (1 + \textrm{abs} ( \hat{f} ) ) > ' num2str(clamp) '$'], 'interpreter', 'latex');


%% Save data

rgb = ind2rgb(gray2ind(spectrum, 255), jet(255));
imwrite(rgb, 'output/fft_three_dice_lambertian.png');

map = colormap([1, 1, 1; 0, 0, 1]);
rgb = ind2rgb(gray2ind(spectrum > clamp, 255), map);
imwrite(rgb, ['output/fft_three_dice_lambertian_clamp=' num2str(clamp) '.png']);
