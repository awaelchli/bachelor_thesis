function tests = testCameraPlane

    tests = functiontests(localfunctions);

end

function testCameraPositions(testCase)

    c = CameraPlane([4, 3], [2, 1], 10);
    verifyEqual(testCase, c.z, 10);
    expectedPositionsY = repmat([3, 1, -1, -3]', 1, 3);
    expectedPositionsX = repmat([-1, 0, 1], 4, 1);
    verifyEqual(testCase, c.cameraPositionMatrixY, expectedPositionsY);
    verifyEqual(testCase, c.cameraPositionMatrixX, expectedPositionsX);
    
end

function testDependentProperties(testCase)
    
    c = CameraPlane([2, 4], [1, 2], 1);
    
    verifyEqual(testCase, c.distanceBetweenTwoCameras, [1, 2]);
    verifyEqual(testCase, c.resolution, [2, 4]);
    verifyEqual(testCase, c.size, [1, 6]);
    
end

function test1DCameraPlane(testCase)
    
    c = CameraPlane([1, 4], [100, 2], 1);
    verifyEqual(testCase, c.resolution, [1, 4]);
    verifyEqual(testCase, c.size, [0, 6]);
    verifyEqual(testCase, c.distanceBetweenTwoCameras, [0, 2])
    verifyEqual(testCase, c.cameraPositionMatrixY, [0, 0, 0, 0]);
    verifyEqual(testCase, c.cameraPositionMatrixX, [-3, -1, 1, 3]);
    
    c = CameraPlane([1, 1], [100, 200], 1);
    verifyEqual(testCase, c.size, [0, 0]);
    verifyEqual(testCase, c.distanceBetweenTwoCameras, [0, 0]);
    verifyEqual(testCase, c.cameraPositionMatrixY, 0);
    verifyEqual(testCase, c.cameraPositionMatrixX, 0);
    
end
