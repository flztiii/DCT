% Author: JZQ
% Date: 2019.3.22
% Info: There is no padding process and make sure the width and height of the input image can be divisible by 8. 
clear;
clc;

% Quantification matrix
QUANMATRIX = [16 11 10 16 24 40 51 61 ; 
              12 12 14 19 26 58 60 55 ; 
              14 13 16 24 40 57 69 56 ; 
              14 17 22 29 51 87 80 62 ; 
              18 22 37 56 68 109 103 77;
              24 35 55 64 81 104 113 92; 
              49 64 78 87 103 121 120 101; 
              72 92 95 98 112 100 103 99];

% img input
path = './lena.jpg';
raw_img = imread(path);
[width, height] = size(raw_img);
raw_img = double(raw_img);

% DCT
fun_dct = @(block_struct) dct2(block_struct.data);
info = blockproc(raw_img, [8 8], fun_dct);

% quantification
fun_quan = @(block_struct) QuanFun(block_struct.data, QUANMATRIX);
quan_info = blockproc(info, [8 8], fun_quan);

% reverse quantification
fun_re_quan = @(block_struct) ReQuanFun(block_struct.data, QUANMATRIX);
re_quan_info = blockproc(quan_info, [8 8], fun_re_quan);

% IDCT
fun_idct = @(block_struct) idct2(block_struct.data);
output_img =  blockproc(re_quan_info, [8 8], fun_idct);

% error calculation

error_matrix = double(output_img) - double(raw_img);
error_matrix = abs(error_matrix);
mse_error = sum(sum(error_matrix.^2))/(width*height);
fprintf('The Calculated MSE is %f\n', mse_error);

% show
figure
subplot(2,3,1);
imshow(uint8(raw_img));
title('原始图');

subplot(2,3,2);
imshow(uint8(info));
title('分块DCT变换图');

subplot(2,3,3);
imshow(uint8(quan_info));
title('量化图');

subplot(2,3,4);
imshow(uint8(re_quan_info));
title('反量化图');

subplot(2,3,5);
imshow(uint8(output_img));
title('DCT反变换恢復图');

subplot(2,3,6);
x = 1: width;
y = 1: height;
[X, Y] = meshgrid(x, y);
mesh(X, Y, error_matrix);
shading interp;

% Quantification function
function[output] = QuanFun(input, QUANMATRIX)
    input = double(input);
    output = zeros(8, 8);
    output = double(output);
    for i = 1:8
        for j = 1:8
            output(i, j) = round(input(i, j)/double(QUANMATRIX(i, j)));
        end
    end
end

% Reverse Quantification function
function[output] = ReQuanFun(input, QUANMATRIX)
    input = double(input);
    output = zeros(8, 8);
    output = double(output);
    for i = 1:8
        for j = 1:8
            output(i, j) = input(i, j)*double(QUANMATRIX(i, j));
        end
    end
end