%% CSF plots
% load('C:\Users\Adrian\Documents\MATLAB\bachelor_project\results\contrast\perspective\2layer\evaluation.mat');
% load('C:\Users\Adrian\Documents\MATLAB\bachelor_project\results\contrast\perspective\5layer\evaluation.mat');
load('C:\Users\Adrian\Documents\MATLAB\bachelor_project\results\contrast\perspective\5layer_1.5_resolution\evaluation.mat');
% load('C:\Users\Adrian\Documents\MATLAB\bachelor_project\results\contrast\perspective\2layer_0.5_resolution\evaluation.mat');
% load('C:\Users\Adrian\Documents\MATLAB\bachelor_project\results\contrast\perspective\5layer_0.5_resolution\evaluation.mat');
out = '5layer_1.5_resolution';

% evaluation.outputFolder = 'C:\Users\Adrian\Documents\MATLAB\bachelor_project\results\contrast\perspective\2layer\';
% evaluation.storeReconstructedViews();
% evaluation.storeErrorImages();
err = evaluation.displaySingleErrorImage([5,5]);
rec = evaluation.getReplicatedReconstructedView([5,5]);

width = size(err, 2);
height = size(err, 1);

err_cropped = imcrop(err, [1, height - floor(height / 2), width, floor(height / 2)]);
rec_cropped = imcrop(rec, [1, height - floor(height / 2), width, floor(height / 2)]);
imwrite(rec_cropped, [out, '_rec.png']);

max2 = max(err_cropped(:))

caxTop = 0.2;

%% Store

errc = err_cropped;
errc(errc > caxTop) = caxTop;
errc = 255 * (errc - min(errc(:))) / (max(errc(:)) - min(errc(:)));

imshow(errc);
colormap jet;
imwrite(errc, jet(255), [out '.png']);