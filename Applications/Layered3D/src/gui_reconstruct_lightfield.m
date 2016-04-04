function [ evaluation ] = gui_reconstruct_lightfield( handles )


% layerResolution = handles.data.attenuator.planeResolution;
% attenuatorSize = handles.data.attenuator.planeSize;
sensorSize = handles.data.lightfield.sensorPlane.planeSize;
sensorResolution = handles.data.lightfield.sensorPlane.planeResolution;
z = handles.data.lightfield.sensorPlane.z;

% For the reconstruction, use a propagation matrix that projects from the sensor plane instead of the sampling plane
resamplingPlane = SensorPlane(round(1 * sensorResolution), round(1 * sensorSize), z);

switch get(handles.popupProjectionType, 'Value')
    case 1
        rec = FastReconstructionForResampledLF(handles.data.lightfield, handles.data.attenuator, resamplingPlane);
    case 2
        rec = ReconstructionForOrthographicLF(handles.data.lightfield, handles.data.attenuator);
end
rec.constructPropagationMatrix();
rec.usePropagationMatrixForReconstruction(rec.propagationMatrix);

[~, mse] =  rec.reconstructLightField();

set(handles.textRMSE, 'String', sprintf('%.3f', sqrt(mse)));
set(handles.textPSNR, 'String', sprintf('%.3f dB', 10 * log10(255^2 / mse)));

evaluation = rec.evaluation;

end

