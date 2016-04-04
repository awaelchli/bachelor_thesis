
folder = 'lightFields/dice/perspective/1x500x1000x1000/';
out = [folder '/rectified/'];

disparityShift = [0, 0.5];

resolution = [1, 500, 1000, 1000, 3];
            
% cutSizesTop = (resolution(LightField.angularDimensions(1)) - 1) * disparityShift(1) : -disparityShift(1) : 0;
cutSizesLeft = (resolution(LightField.angularDimensions(2)) - 1) * disparityShift(2) : -disparityShift(2) : 0;
% newHeight = resolution(LightField.spatialDimensions(1)) - cutSizesTop(1);
newHeight = resolution(3);
newWidth = resolution(LightField.spatialDimensions(2)) - cutSizesLeft(1);
newWidth = floor(newWidth);

% rectifiedData = zeros([resolution(LightField.angularDimensions), newHeight, newWidth, resolution(LightField.channelDimension)]);

imageList = dir([folder '*.png']);

for cy = 1 : resolution(LightField.angularDimensions(1))
    for cx = 1 : resolution(LightField.angularDimensions(2))

        i = sub2ind(resolution([1, 2]), cy, cx);
        
        image = imread([folder imageList(i).name]);
%         top = cutSizesTop(cy);
        top = 0;
        left = ceil(cutSizesLeft(cx));
        rectifiedImage = image(top + 1 : top + newHeight, left + 1 : left + newWidth, :);
        
        
        imwrite(rectifiedImage, [out imageList(i).name]);
        
    end
end

%% CSF plots
load('C:\Users\Adrian\Documents\MATLAB\bachelor_project\results\contrast\perspective\2layer\evaluation.mat');
evaluation2 = evaluation;
load('C:\Users\Adrian\Documents\MATLAB\bachelor_project\results\contrast\perspective\5layer\evaluation.mat');
evaluation5 = evaluation;
load('C:\Users\Adrian\Documents\MATLAB\bachelor_project\results\contrast\perspective\5layer_1.5_resolution\evaluation.mat');
evaluation15 = evaluation;

err2 = evaluation2.displaySingleErrorImage([5,5]);
err5 = evaluation5.displaySingleErrorImage([5,5]);
err15 = evaluation15.displaySingleErrorImage([5,5]);

max2 = max(err2(:))
max5 = max(err5(:))
max15 = max(err15(:))
%%
figure(1)
ax1 = axes;
imagesc(err2)
caxis([0, 0.2])
colormap jet
colorbar('Ticks', [0, 0.2])
axis off
axis equal image
set(ax1, 'XTickLabel','');
set(ax1, 'YTickLabel','');

s = 255 / max2;
imwrite(s * err2, jet(255), '2layer.png');

%%
figure(2)
ax1 = axes;
imagesc(err5)
caxis([0, 0.2])
colormap jet
colorbar('Ticks', [0, 0.2])
axis off
axis equal image
set(ax1, 'XTickLabel','');
set(ax1, 'YTickLabel','');

s = 255 / max2;
imwrite(s * err5, jet(255), '5layer.png');

%%
figure(3)
ax1 = axes;
imagesc(err15)
caxis([0, 0.2])
colormap jet
colorbar('Ticks', [0, 0.2])
axis off
axis equal image
set(ax1, 'XTickLabel','');
set(ax1, 'YTickLabel','');

s = 255 / max2;
imwrite(s * err15, jet(255), '5layer_1.5x_resolution.png');