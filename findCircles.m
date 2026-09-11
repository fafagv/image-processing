function circleCoordinates = findCircles(image)
% FINDCIRCLES Locate the four black registration circles in the image.
%
%   circleCoordinates = findCircles(image) takes the double RGB image
%   and returns a 4x2 matrix of [x y] pixel coordinates for the centres
%   of the four black circles, ordered as:
%       row 1: top-left
%       row 2: top-right
%       row 3: bottom-left
%       row 4: bottom-right
%
%   Approach:
%   1. Convert to grayscale and threshold to find dark ("black") blobs.
%   2. Clean up the mask with morphological opening / small-object
%      removal to get rid of noise and thin edges/lines.
%   3. Use regionprops to find connected components and keep only the
%      ones that are roughly circular (compactness close to 1) and of a
%      plausible size relative to the image.
%   4. If more than 4 circular blobs remain (e.g. noisy images), keep
%      the 4 most circular ones.
%   5. Sort the 4 centroids into TL/TR/BL/BR order using the sum and
%      difference of their x/y coordinates, which is a standard trick
%      for ordering the corners of a (possibly rotated) quadrilateral.

    gray = rgb2gray(image);

    % Otsu's threshold, then take the darker side. This is more robust
    % than a fixed threshold across images of varying brightness.
    level = graythresh(gray);
    bw = gray < level * 0.6;   % bias towards genuinely dark pixels

    % Remove tiny specks of noise.
    bw = bwareaopen(bw, round(numel(bw)*0.0002));

    % Fill any small holes inside the circles (e.g. specular highlights).
    bw = imfill(bw,'holes');

    stats = regionprops(bw, 'Centroid', 'Area', 'Perimeter', 'BoundingBox');

    if isempty(stats)
        error('findCircles:notFound', 'No dark blobs found in image.');
    end

    % Circularity metric: 1 for a perfect circle, lower for other shapes.
    circularity = arrayfun(@(s) 4*pi*s.Area / max(s.Perimeter^2,eps), stats);

    % Aspect ratio of bounding box should be close to 1 for a circle.
    aspect = arrayfun(@(s) s.BoundingBox(3) / s.BoundingBox(4), stats);

    isCircle = circularity > 0.65 & aspect > 0.6 & aspect < 1.6;

    candidates = stats(isCircle);

    if numel(candidates) < 4
        % Fall back: relax the circularity threshold rather than fail
        % outright, since noisy/compressed images can distort blob shape.
        isCircle = circularity > 0.45;
        candidates = stats(isCircle);
    end

    if numel(candidates) < 4
        error('findCircles:notFound', ...
            'Could not find 4 circular blobs (found %d).', numel(candidates));
    end

    centroids = reshape([candidates.Centroid], 2, [])';
    areas     = [candidates.Area]';

    if size(centroids,1) > 4
        % Registration circles should be roughly similar in size and are
        % usually amongst the larger blobs in the mask (as opposed to
        % small stray noise specks that survived filtering). Keep the 4
        % with area closest to the median candidate area.
        medArea = median(areas);
        [~, order] = sort(abs(areas - medArea));
        centroids = centroids(order(1:4), :);
    end

    % --- Order the 4 points as TL, TR, BL, BR ---
    x = centroids(:,1);
    y = centroids(:,2);

    s = x + y;   % smallest -> top-left, largest -> bottom-right
    d = x - y;   % largest  -> top-right, smallest -> bottom-left

    [~, idxTL] = min(s);
    [~, idxBR] = max(s);
    [~, idxTR] = max(d);
    [~, idxBL] = min(d);

    circleCoordinates = [centroids(idxTL,:); ...
                          centroids(idxTR,:); ...
                          centroids(idxBL,:); ...
                          centroids(idxBR,:)];
end
