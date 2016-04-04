
numberOfLightFields = 100;
spatialResolution = [100, 100];
angularResolution = [1, 15];
thickness = 3;
N = 8;
attenuator = Attenuator(N, spatialResolution, [1, 1], thickness, 3);
resamplingPlaneZ = -thickness / 2;
cameraPlane = CameraPlane(angularResolution, [0.1, 0.1], 10);
sensorPlane = SensorPlane(spatialResolution, attenuator.planeSize, 0);

recFourierImages = cell(numberOfLightFields, numel(resamplingPlaneZ));
fourierImages = cell(numberOfLightFields, numel(resamplingPlaneZ));

lengthLastOutput = 0;

% Precompute projection matrix for reconstruction
tempResamplingPlane = SensorPlane(spatialResolution, attenuator.planeSize, 0);
tempLightField = LightFieldP(zeros([angularResolution, spatialResolution, 3]), cameraPlane, sensorPlane);
tempRec = FastReconstructionForResampledLF(tempLightField, attenuator, tempResamplingPlane);
tempRec.verbose = 0;
%tempRec.computeAttenuationLayers(); % Not actually needed, TODO: remove
P = tempRec.propagationMatrix;

for n = 1 : numberOfLightFields
    
    data = randn(spatialResolution);
    data = repmat(data, 1, 1, 15, 15, 3);
    data = permute(data, [3, 4, 1, 2, 5]);
    data = data(1, :, :, :, :);
    
    resamplingPlane = SensorPlane(2 * spatialResolution, attenuator.planeSize, resamplingPlaneZ);
    lightField = LightFieldP(data, cameraPlane, sensorPlane);

    rec = FastReconstructionForResampledLF(lightField, attenuator, resamplingPlane);
    rec.verbose = 0;
    rec.computeAttenuationLayers();
    rec.usePropagationMatrixForReconstruction(P);
    rec.reconstructLightField();
    recLF = rec.reconstructedLightField.lightFieldData;
    recLF = squeeze(recLF(:, :, :, :, 1));

    recFourierImages{n, 1} = fft2(recLF);
    fourierImages{n, 1} = fft2(squeeze(lightField.lightFieldData(:, :, :, :, 1)));

    % Progress update
    out = sprintf('%i', n);
    fprintf(repmat('\b', 1, lengthLastOutput));
    fprintf(out);
    lengthLastOutput = numel(out);
    
end

recFourierImageStack = cat(3, recFourierImages{:, 1});
recAverageFourierImage = fftshift(recFourierImageStack); 
recAverageFourierImage = abs(recAverageFourierImage);
recAverageFourierImage = log(recAverageFourierImage+1);
recAverageFourierImage = mean(recAverageFourierImage, 3);       


fourierImageStack = cat(3, fourierImages{:, 1});
averageFourierImage = fftshift(fourierImageStack);        
averageFourierImage = abs(averageFourierImage);
averageFourierImage = log(averageFourierImage+1);
averageFourierImage = mean(averageFourierImage, 3);

NZrecAverageFourierImage = recAverageFourierImage / max(recAverageFourierImage(:));

NZrecAverageFourierImage(NZrecAverageFourierImage <= 0.3) = 0;
NZrecAverageFourierImage(NZrecAverageFourierImage > 0.3) = 1;

figure;
subplot(311);
imshow(recAverageFourierImage, []);
subplot(312);
imshow(NZrecAverageFourierImage, []);
subplot(313);
imshow(averageFourierImage, []);