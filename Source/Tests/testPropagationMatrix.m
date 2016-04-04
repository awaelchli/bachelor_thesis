function tests = testPropagationMatrix

    tests = functiontests(localfunctions);

end

function testInitialization(testCase)
    
    c = CameraPlane([2, 3], [1, 2], 1);
    s = SensorPlane([3, 3], [1, 1], 0);
    l = LightFieldP(zeros(2, 3, 3, 3, 3), c, s);
    a = Attenuator(2, [3, 3], [1, 1], 1, 3);
    p = PropagationMatrix(l, a);
    
    assertEqual(testCase, p.lightFieldSubscriptRange, [2, 3, 3, 3]);
    assertEqual(testCase, p.attenuatorSubscriptRange, [3, 3, 2]);
    assertEqual(testCase, p.size, [2 * 3 * 3 * 3, 3 * 3 * 2]);
    
    P = p.formSparseMatrix;
    assertEqual(testCase, size(P), p.size);
    assertEqual(testCase, nnz(P), 0);
    
end

function testEntrySubmission(testCase)

    c = CameraPlane([2, 3], [1, 2], 1);
    s = SensorPlane([3, 3], [1, 1], 0);
    l = LightFieldP(zeros(2, 3, 3, 3, 3), c, s);
    a = Attenuator(2, [3, 3], [1, 1], 1, 3);
    p = PropagationMatrix(l, a);
    
    cameraIndexY = 1;
    cameraIndexX = 1;
%     pixelIndexOnSensorY = [0, 0, 0;
%                            1, 1, 1;
%                            0, 0, 0];
%     pixelIndexOnSensorX = [0, 3, 0;
%                            0, 3, 0;
%                            0, 3, 0];

    layerIndex = 1;
    pixelIndexOnLayerY = [1, 1, 1;
                          2, 2, 2;
                          3, 3, 3];
    pixelIndexOnLayerX = [1, 2, 3;
                          1, 2, 3;
                          1, 2, 3];
    weightMatrix = [1, 2, 3;
                    4, 5, 6;
                    7, 8, 9];
    
    p.submitEntries(cameraIndexY, cameraIndexX, ...
                    1, 3, ...
                    layerIndex, ...
                    pixelIndexOnLayerY, pixelIndexOnLayerX, ...
                    weightMatrix);
     
    P = p.formSparseMatrix;
    assertEqual(testCase, nnz(P), 9);
    expectedWeights = [1, 4, 7, 2, 5, 8, 3, 6, 9];
    assertEqual(testCase, P(2 * 3 * 3 * 2 + 1, 1 : 9), sparse(expectedWeights));
    
end

