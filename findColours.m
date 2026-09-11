function res = findColours(filename, varargin)
% FINDCOLOURS Read a colour data-matrix image and return its 4x4 pattern.
%
%   res = findColours(filename) loads the image at the given path,
%   locates the four black registration circles, un-distorts the image
%   using them, and classifies the resulting 4x4 grid into colour
%   names. The result, res, is a 4x4 cell array of char strings drawn
%   from {'white','red','green','blue','yellow'}.
%
%   findColours(filename, mat_filename) is also accepted for backwards
%   compatibility with the original test harness signature, but the
%   optional second argument is ignored - the answer is now computed
%   directly from the image rather than read from a solution file.
%
%   Note: as stated in the lab brief, there is no "correct" orientation
%   for the pattern, so res may come back rotated and/or flipped
%   relative to the original answer. check_answer.m already accounts
%   for this when scoring.

    image = loadImage(filename);

    circleCoordinates = findCircles(image);

    correctedImage = correctImage(circleCoordinates, image);

    res = getColours(correctedImage);
end
