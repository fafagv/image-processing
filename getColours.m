function colours = getColours(image)
% GETCOLOURS Classify each cell of a 4x4 colour grid image.
%
%   colours = getColours(image) takes a double RGB image that has
%   already been un-distorted into a square 4x4 grid (see correctImage)
%   and returns a 4x4 cell array of char strings, one of:
%       'white', 'red', 'green', 'blue', 'yellow'
%   for each cell, matching the row/column layout of the physical grid.
%
%   Approach:
%   For each of the 16 cells, a central patch of pixels (avoiding the
%   cell edges/borders, where anti-aliasing or grid lines could bias
%   the colour) is averaged to get a representative RGB colour. That
%   average is then matched to the nearest of the 5 known reference
%   colours using simple Euclidean distance in RGB space.

    [rows, cols, ~] = size(image);

    cellHeight = rows / 4;
    cellWidth  = cols / 4;

    colourNames = {'white', 'red', 'green', 'blue', 'yellow'};
    refColours  = [1 1 1;   % white
                   1 0 0;   % red
                   0 1 0;   % green
                   0 0 1;   % blue
                   1 1 0];  % yellow

    % Fraction of each cell (centred) to sample, to avoid picking up
    % neighbouring cells or grid-line artefacts near the edges.
    margin = 0.30;

    colours = cell(4,4);

    for r = 1:4
        for c = 1:4
            rowStart = round((r-1)*cellHeight + margin*cellHeight);
            rowEnd   = round(r*cellHeight - margin*cellHeight);
            colStart = round((c-1)*cellWidth  + margin*cellWidth);
            colEnd   = round(c*cellWidth  - margin*cellWidth);

            rowStart = max(1, rowStart);
            colStart = max(1, colStart);
            rowEnd   = min(rows, rowEnd);
            colEnd   = min(cols, colEnd);

            patch = image(rowStart:rowEnd, colStart:colEnd, :);

            % Use the median rather than the mean to be robust to any
            % stray dark/bright outlier pixels (e.g. shadows, noise
            % speckle) still present in the patch.
            avgColour = [median(patch(:,:,1), 'all'), ...
                         median(patch(:,:,2), 'all'), ...
                         median(patch(:,:,3), 'all')];

            dists = sum((refColours - avgColour).^2, 2);
            [~, idx] = min(dists);

            colours{r,c} = colourNames{idx};
        end
    end
end
