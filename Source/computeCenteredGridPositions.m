function [ gridPositionMatrixY, ...
           gridPositionMatrixX ] = computeCenteredGridPositions( gridResolution, ...
                                                                 gridStepSize)
% Input:        
%
%   gridResolution:         The resolution [Y, X] in Y- and X-direction of
%                           the grid to be generated
%   gridStepSize:           The size of the steps [Y, X] between the grid 
%                           points in Y- and X-direction


% TODO: Find a way to eliminate if-statements

gridSize = (gridResolution - 1) .* gridStepSize;

if(gridResolution(1) == 1)
    % Grid is 1D
    positionsVectorY = 0;
else
    positionsVectorY = gridSize(1) / 2 : -gridStepSize(1) : -gridSize(1) / 2;
end

if(gridResolution(2) == 1)
    % Grid is 1D
    positionsVectorX = 0;
else
    positionsVectorX = -gridSize(2) / 2 : gridStepSize(2) : gridSize(2) / 2;
end

[ gridPositionMatrixY, gridPositionMatrixX ] = ndgrid(positionsVectorY, positionsVectorX);

end

