function group_targets = fn_select_photostim_targets (n_target, n_group)

for i_g = 1:1:n_group
    [x,y] = ginput(n_target);
    group_targets{i_g}.x = x;
    group_targets{i_g}.y = y;
end
