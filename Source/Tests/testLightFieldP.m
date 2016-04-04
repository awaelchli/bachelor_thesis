function tests = testLightFieldP

    tests = functiontests(localfunctions);

end

function testBasicProperties(testCase)
    c = CameraPlane([3, 6], [1, 2], 10);
    s = SensorPlane([5, 10], [4, 8], -1);
    l = LightFieldP(zeros(3, 6, 5, 10, 3), c, s);
    
    assertEqual(testCase, l.resolution, [3, 6, 5, 10]);
    assertEqual(testCase, l.angularResolution, [3, 6]);
    assertEqual(testCase, l.spatialResolution, [5, 10]);
    assertEqual(testCase, l.channels, 3);
    assertEqual(testCase, l.distanceCameraToSensorPlane, 11);
end

function test2DLightField(testCase)
end
