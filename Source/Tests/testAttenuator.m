function tests = testAttenuator

    tests = functiontests(localfunctions);

end

function testDependentProperties(testCase)

    a = Attenuator(2, [10, 20], [2, 4], 2, 3);
    
    verifyEqual(testCase, a.numberOfLayers, 2);
    verifyEqual(testCase, a.planeResolution, [10, 20]);
    verifyEqual(testCase, a.thickness, 2);
    verifyEqual(testCase, a.channels, 3);
    
end

function testLayerPositions(testCase)
    
    a = Attenuator(5, [4, 6], [10, 15], 4, 3);
    
    verifyEqual(testCase, a.pixelSize, [10 / 4, 15 / 6]);
    expectedPositionsY = 5 - a.pixelSize(1) / 2 : -a.pixelSize(1) : -5 + a.pixelSize(1) / 2;
    expectedPositionsY = repmat(expectedPositionsY', 1, 6);
    expectedPositionsX = -7.5 + a.pixelSize(2) / 2 : a.pixelSize(2) : 7.5 - a.pixelSize(2) / 2;
    expectedPositionsX = repmat(expectedPositionsX, 4, 1);
    verifyEqual(testCase, a.layerPositionZ, [-2, -1, 0, 1, 2]);
    verifyEqual(testCase, a.pixelPositionMatrixY, expectedPositionsY);
    verifyEqual(testCase, a.pixelPositionMatrixX, expectedPositionsX);
    
    a.placeLayer([1, 5], [-3, 3]);
    verifyEqual(testCase, a.layerPositionZ, [-3, -1, 0, 1, 3]);
    verifyEqual(testCase, a.thickness, 6);
    a.placeLayer(5, -4);
    verifyEqual(testCase, a.thickness, 5);
    
end

function test1DLayers(testCase)

    a = Attenuator(2, [1, 4], [2, 8], 1, 3);
    
    verifyEqual(testCase, a.pixelSize, [2, 2]);
    verifyEqual(testCase, a.pixelPositionMatrixY, [0, 0, 0, 0]);
    verifyEqual(testCase, a.pixelPositionMatrixX, [-3, -1, 1, 3]);
    
    a = Attenuator(2, [4, 1], [8, 2], 1, 3);
    
    verifyEqual(testCase, a.pixelSize, [2, 2]);
    verifyEqual(testCase, a.pixelPositionMatrixY, [3, 1, -1, -3]');
    verifyEqual(testCase, a.pixelPositionMatrixX, [0, 0, 0, 0]');
    
end