editor = LightFieldEditor();
editor.inputFromImageCollection('lightFields/dice/orthographic/7x7x384x512_fov10/', 'png', [7, 7], 1);
editor.lightFieldFOV = [10, 10];
lightField = editor.getOrthographicLightField();

attenuator = Attenuator(5, lightField.spatialResolution, [1, 1], 0.4, lightField.channels);

rec = ReconstructionForOrthographicLF(lightField, attenuator);
% rec.solver = @linearLeastSquares;
rec.computeAttenuationLayers();

close all;
evaluation = rec.evaluation();
evaluation.displayLayers(1 : 5);

evaluation.clearOutputFolder();
evaluation.evaluateViews([4, 1; 4, 2; 4, 3; 4, 4; 4, 5; 4, 6; 4, 7]);
evaluation.displayReconstructedViews();
evaluation.displayErrorImages();
evaluation.storeReconstructedViews();