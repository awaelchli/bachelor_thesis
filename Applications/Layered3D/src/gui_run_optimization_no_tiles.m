function [ attenuator ] = gui_run_optimization_no_tiles( handles )

attenuator = [];

iterations = str2double(get(handles.editIterations, 'String'));
if isnan(iterations) || iterations <= 0 || rem(iterations, 1) ~= 0
    gui_warning(handles.textOptimizationInfo, 'Iterations must be a positive integer');
    return;
end

solver = @gui_sart;
switch get(handles.popupAlgorithm, 'Value')
    case 1
        solver = @gui_sart;
    case 2
        solver = @gui_lsqlin;
end

layerResolution = handles.data.attenuator.planeResolution;
layerSize = handles.data.attenuator.planeSize;
samplingPlaneSize = layerSize;

% HARD-Coded sampling density
resamplingPlane = SensorPlane(round( 1 * layerResolution), 1 * samplingPlaneSize, handles.data.attenuator.layerPositionZ(1));

switch get(handles.popupProjectionType, 'Value')
    case 1
        rec = FastReconstructionForResampledLF(handles.data.lightfield, handles.data.attenuator, resamplingPlane);
    case 2
        rec = ReconstructionForOrthographicLF(handles.data.lightfield, handles.data.attenuator);
end

% evaluation = rec.evaluation();

rec.verbose = 1;
rec.iterations = iterations;
rec.solver = solver;

set(handles.textOptimizationInfo, 'String', 'Running optimization ...');
drawnow;

ticStart = tic;
rec.computeAttenuationLayers();
elapsed = toc(ticStart);

set(handles.textOptimizationInfo, 'String', sprintf('Done. Elapsed time is %.0f seconds.', elapsed));
drawnow;

attenuator = rec.attenuator;



end

