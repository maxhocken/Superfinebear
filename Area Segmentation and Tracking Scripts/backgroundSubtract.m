%Image Background Subtract and Smooth
%%Script that will take input directory of cell images and smooth and
%%subtract images from reference image (last) and save all images to new
%%subdirectory
% Input:
%  - Input directory containing all images of interest with the final image
%  being the reference image to be subtracted. Second input is the
%  smoothing factor for a 2D Gauss smooth (generally betweeen 1-8)
%  --Luca Menozzi 03 09 20
%   
%   Copyright (C) <2020>  <Luca Menozzi>
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.
% 
% 
%%
function [] = backgroundSubtract(img_directory, smoothing_factor)

% Create path of final output directory and check if path already exists
final_dir = strcat(img_directory, '\', 'Subtracted and Smoothed Images');
if exist(final_dir, 'dir')
    error('Output directory already exists')
end

% Break down input data and determining number of files and reference
% image
structure = dir(img_directory);
cell = struct2cell(structure);
[rows , cols] = size(cell);
ref_image_name = cell{1, cols};
ref_image_data = imread(ref_image_name);

% Smooth reference image
smoothed_ref = imgaussfilt(ref_image_data, smoothing_factor);

% Create index array for all images in directory
image_index_array = linspace(1, cols - 3, cols - 3) + 2;

% Make an output directory to store all subtracted and smoothed images 
% inside the directory containing the raw images
mkdir(final_dir);

for i = image_index_array
    
    % Read and smooth image of interest in this iteration (smooth using
    % 2D Gauss Filter)
    img_name = cell{1, i};
    raw_img_data = imread(img_name);
    smoothed_img_data = imgaussfilt(raw_img_data, smoothing_factor);
    
    % Subtract reference image from image of interest in both raw and
    % smoothed cases
    final_image_raw = imsubtract(raw_img_data, ref_image_data);
    final_image_smoothed = imsubtract(smoothed_img_data, smoothed_ref);
    
    % Name both files to be saved in new directory
    smoothed_filename = strcat('smoothed and subtracted', img_name);
    raw_filename = strcat('subtracted', img_name);
    
    % Show both smoothed and raw subtracted images
    %{
    figure
    imshow(final_image_raw)
    title(raw_filename)
    figure
    imshow(final_image_smoothed)
    title(smoothed_filename)
    %}
    % Change to output directory and save the new image files
    cd(final_dir);
    imwrite(final_image_smoothed, smoothed_filename);
    imwrite(final_image_raw, raw_filename);
    
    % Change back to directory of interest
    cd(img_directory);
end
% Save reference image to new directory of output images
cd(final_dir);
imwrite(ref_image_data, strcat('reference', ref_image_name));
end