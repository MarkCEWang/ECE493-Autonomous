close all; 
v = VideoReader('test-data/solidWhiteRight.mp4');
% v = VideoReader('test-data/solidYellowLeft.mp4'); 
nFrames = round(v.Duration*v.FrameRate);
width = v.Width; height = v. Height; 

% for frameN = 1:10:nFrames
    
    frame = read(v, 10);
    % figure, imshow(frame)

    % Convert RGB frame to YCrCb
    frame_y = rgb2ycbcr(frame); 
    frame_hsv = rgb2hsv(frame);

    % Simple thresholding on the Y channel:
    thresh = 0.85; 
    y_channel = frame_hsv(:,:,3); 
    mask = y_channel(:,:) > thresh; 

    figure, imshow(mask);
    title('Thresholded Image'); 

    % Erode the frame to hide noise
    radius = 2; 
    SE = strel('diamond',radius); 
    % SE_square = strel('square', 12); 
    % 
    % dil_img = imdilate(mask, SE); 
    % figure, imshow(dil_img)
    % 
%     car_img = imerode(dil_img, SE_square); 
%     figure, imshow(car_img)

    BW2 = imclose(mask,SE); % dialate then erode
    % figure, imshow(BW2)
    % title('Morphological Thresholded Image'); 

    % Bound the search area for the lane lines
    c = [size(y_channel, 2)/2 10 size(y_channel,2) - 10];
    r = [size(y_channel, 1)/2 size(y_channel,1) size(y_channel, 1)];
    bounded_mask = zeros(size(y_channel)); 
    ROI = roipoly(bounded_mask,c,r);

    Inew = ROI.*BW2;
    Inew = Inew > 0; 
    % figure, imshow(Inew)
    % title('Region of Interest Applied');

    % Get the lane lines now
    % Get the regions 
    line_bounds = regionprops(Inew,'area', 'Centroid', 'Orientation', 'PixelList');

    % Remove any with areas or orientations close to 0 
    area_min = 10; 
    angle_min = 25; 
    left_idx = []; 
    right_idx = []; 

    if(size(line_bounds, 1) > 1)

        idx = 1; 
        while(idx <= size(line_bounds,1))

            if(line_bounds(idx).Area < area_min || ...
                    abs(line_bounds(idx).Orientation) < angle_min)
                line_bounds(idx) = []; 
            else
                if(line_bounds(idx).Orientation > 0)
                    % add to left line
                    left_idx = [left_idx; idx]; 
                else
                    right_idx = [right_idx; idx]; 
                end
                idx = idx + 1; 
            end
        end
    end


    % Draw lines on the original frame
    figure, imshow(frame)
    title('Lane Lines Located')

    % Left Line

    % Get the left most and right most points
    minPts = [];
    maxPts = []; 
    for i = 1:length(left_idx)
        [M, I] =  min(line_bounds(left_idx(i)).PixelList(:,1)); 
        minPts = [minPts ; [M, line_bounds(left_idx(i)).PixelList(I,2)]];
        [M, I] =  max(line_bounds(left_idx(i)).PixelList(:,1)); 
        maxPts = [maxPts ; [M, line_bounds(left_idx(i)).PixelList(I,2)]];

    end


    line( minPts(:,1) ,minPts(:,2) ,'Color','b','LineWidth',5)

    % if(left_angles > 1)
    %     left_angle = median(left_angles); 
    % else 
    %     left_angle = left_angles; 
    % end


    % Right Line

    minPts = [];
    maxPts = []; 
    for i = 1:length(right_idx)
        [M, I] =  min(line_bounds(right_idx(i)).PixelList(:,1)); 
        minPts = [minPts ; [M, line_bounds(right_idx(i)).PixelList(I,2)]];
        [M, I] =  max(line_bounds(right_idx(i)).PixelList(:,1)); 
        maxPts = [maxPts ; [M, line_bounds(right_idx(i)).PixelList(I,2)]];

    end

    line( [minPts(:,1) maxPts(:,1)] , [minPts(:,2) maxPts(:,2)] ,'Color','b','LineWidth',5)


