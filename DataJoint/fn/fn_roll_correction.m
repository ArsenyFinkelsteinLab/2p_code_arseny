function [x_corr, y_corr ] = fn_roll_correction (roll,x,y)

R = [cosd(roll) -sind(roll); sind(roll) cosd(roll)];

% x_scaling = max(x) - min(x);
% y_scaling = max(y) - min(y);
median_x = median(x);
median_y = median(y);

for i_tr = 1:1:numel(x)
    point = [x(i_tr);y(i_tr)];
    rotpoint = R*point;
    x_corr(i_tr) = rotpoint(1);
    y_corr(i_tr) = rotpoint(2);
end
    

% x_corr = x_corr - median(x_corr) + median_x;
% y_corr = y_corr - median(y_corr) + median_y;


% % Rescale and center the positions again after rotation
% %----------------------------
% x_scaling = max(x) - min(x);
% y_scaling = max(y) - min(y);
% 
% x = x-min(x);
% y = y-min(y);
% 
% 
% x = x/x_scaling;
% y = y/y_scaling;
% 
% y = 2*(x-0.5);
% y = 2*(y-0.5);
%         