function tests = testLightFieldEditor

    tests = functiontests(localfunctions);

end

function setupOnce(testCase)
    
    testCase.TestData.imageFolder = 'temp/';
    mkdir(testCase.TestData.imageFolder);
    lightFieldData = rand(9, 9, 50, 50, 3);
    storeLightFieldDataAsImages(lightFieldData, testCase.TestData.imageFolder);
    
end

function teardownOnce(testCase) 

    rmdir(testCase.TestData.imageFolder, 's');
    
end

function testLoadingFromImageFolder(testCase)

    editor = LightFieldEditor();
    
    assertError(testCase, @editor.getPerspectiveLightField, 'loadLightFieldData:noInputData');
    assertError(testCase, @editor.getOrthographicLightField, 'loadLightFieldData:noInputData');
    assertError(testCase, @() editor.inputFromImageCollection('/blabla/', 'png', [9, 9], 1), 'inputFromImageCollection:invalidFolder');
    assertError(testCase, @() editor.inputFromImageCollection(testCase.TestData.imageFolder, 'png', [10, 9], 1), 'inputFromImageCollection:wrongAngularResolution');
    assertError(testCase, @() editor.inputFromImageCollection(testCase.TestData.imageFolder, 'png', [9, 9], -100), 'inputFromImageCollection:resizeScaleNotPositive');
    
    editor.inputFromImageCollection(testCase.TestData.imageFolder, 'png', [9, 9], 1);
    editor.cameraPlaneZ = 100;
    editor.distanceBetweenTwoCameras = [2, 3];
    editor.sensorSize = [40, 60];
    editor.sensorPlaneZ = -1;
    result = editor.getPerspectiveLightField();
    assertEqual(testCase, result.cameraPlane.z, 100);
    assertEqual(testCase, result.cameraPlane.distanceBetweenTwoCameras, [2, 3]);
    assertEqual(testCase, result.sensorPlane.planeSize, [40, 60]);
    assertEqual(testCase, result.sensorPlane.z, -1);
    assertEqual(testCase, result.resolution, [9, 9, 50, 50]);
    assertEqual(testCase, result.channels, 3);
    
end

function testSlicing(testCase)

    editor = LightFieldEditor();
    editor.inputFromImageCollection(testCase.TestData.imageFolder, 'png', [9, 9], 1);
    editor.angularSliceY(1 : 2 : 9);
    editor.angularSliceX([1, 2, 3]);
    result = editor.getPerspectiveLightField();
    assertEqual(testCase, result.angularResolution, [5, 3]);
    
    editor.angularSliceX([1, 2]);
    result = editor.getPerspectiveLightField();
    assertEqual(testCase, result.angularResolution, [5, 2]);
    
    editor.spatialSliceY(1);
    editor.spatialSliceX([1 : 48, 50]);
    result = editor.getPerspectiveLightField();
    assertEqual(testCase, result.angularResolution, [5, 2]);
    assertEqual(testCase, result.spatialResolution, [1, 49]);
    
    editor = LightFieldEditor();
    editor.inputFromImageCollection(testCase.TestData.imageFolder, 'png', [9, 9], 1);
    assertError(testCase, @() editor.angularSliceY([0, 1, 9]), 'slice:invalidSlice');
    assertError(testCase, @() editor.angularSliceY([9, 10, 11, 12]), 'slice:invalidSlice');
    assertError(testCase, @() editor.angularSliceY([0.1, 0.2]), 'slice:invalidSlice');
    assertError(testCase, @() editor.angularSliceY([-2, -1, 0, 1, 2]), 'slice:invalidSlice');
    
    assertError(testCase, @() editor.angularSliceX([0, 1, 9]), 'slice:invalidSlice');
    assertError(testCase, @() editor.angularSliceX([9, 10, 11, 12]), 'slice:invalidSlice');
    assertError(testCase, @() editor.angularSliceX([0.1, 0.2]), 'slice:invalidSlice');
    assertError(testCase, @() editor.angularSliceX([-2, -1, 0, 1, 2]), 'slice:invalidSlice');
    
    assertError(testCase, @() editor.spatialSliceY([0, 0, 50]), 'slice:invalidSlice');
    assertError(testCase, @() editor.spatialSliceY([50, 51, 52]), 'slice:invalidSlice');
    assertError(testCase, @() editor.spatialSliceY([0.1, 0.2, 50.1]), 'slice:invalidSlice');
    assertError(testCase, @() editor.spatialSliceY([-2, -1, 0, 1, 2]), 'slice:invalidSlice');
    
    assertError(testCase, @() editor.spatialSliceX([0, 0, 50]), 'slice:invalidSlice');
    assertError(testCase, @() editor.spatialSliceX([50, 51, 52]), 'slice:invalidSlice');
    assertError(testCase, @() editor.spatialSliceX([0.1, 0.2, 50.1]), 'slice:invalidSlice');
    assertError(testCase, @() editor.spatialSliceX([-2, -1, 0, 1, 2]), 'slice:invalidSlice');
    
    assertError(testCase, @() editor.channelSlice([0, 2, 3]), 'slice:invalidSlice');
    assertError(testCase, @() editor.channelSlice([2, 3, 4]), 'slice:invalidSlice');
    assertError(testCase, @() editor.channelSlice([0.1, 0.2, 3.1]), 'slice:invalidSlice');
    assertError(testCase, @() editor.channelSlice([-2, -1, 0]), 'slice:invalidSlice');
    
end

function testResizeAndSlicing(testCase)

    editor = LightFieldEditor();
    resizeScale = 0.95;
    editor.inputFromImageCollection(testCase.TestData.imageFolder, 'png', [9, 9], resizeScale);
    assertEqual(testCase, editor.spatialResolution, [48, 48]);

    editor = LightFieldEditor();
    resizeScale = 0.9;
    editor.inputFromImageCollection(testCase.TestData.imageFolder, 'png', [9, 9], resizeScale);
    assertEqual(testCase, editor.spatialResolution, [45, 45]);
    
    editor.angularSliceX([7, 9]);
    lightField = editor.getPerspectiveLightField();
    assertEqual(testCase, lightField.angularResolution, [9, 2]);
    
    editor.spatialSliceY([1, 2, 45]);
    lightField = editor.getPerspectiveLightField();
    assertEqual(testCase, lightField.spatialResolution, [3, 45]);
end
