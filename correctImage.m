function correctedImage = correctImage(circleCoordinates, image)
% CORRECTIMAGE Un-distort the image using the 4 circle coordinates.
%
%   correctedImage = correctImage(circleCoordinates, image) takes the
%   4x2 [x y] circle centres (ordered TL, TR, BL, BR, as returned by
%   findCircles) and the original double RGB image, and returns a
%   square, axis-aligned image containing just the 4x4 colour grid.
%
%   A projective transform is fitted mapping the 4 detected circle
%   centres onto the 4 corners of a fixed-size square. This corrects
%   for rotation, translation, scaling, and any perspective skew caused
%   by the camera not being perfectly square-on to the pattern (which
%   is exactly what the black circles are there to help calibrate,
%   per the lab brief).
%
%   Note: as stated in the brief, there is no "correct" orientation, so
%   the result here may end up flipped and/or rotated by 90/180/270
%   degrees relative to the original pattern. check_answer.m accounts
%   for this by checking all 8 rotation/flip combinations.

    outputSize = 400; % pixels, arbitrary but must be big enough to sample

    movingPoints = circleCoordinates;               % TL, TR, BL, BR
    fixedPoints  = [0          0; ...                % TL
                     outputSize 0; ...                % TR
                     0          outputSize; ...        % BL
                     outputSize outputSize];           % BR

    tform = fitgeotrans(movingPoints, fixedPoints, 'projective');

    outputView = imref2d([outputSize outputSize]);
    correctedImage = imwarp(image, tform, 'OutputView', outputView, ...
        'FillValues', 1); % fill any out-of-image area with white
end
