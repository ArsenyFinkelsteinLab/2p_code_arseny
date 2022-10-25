function map_2d = fn_map_2D_legalize_by_neighboring_psth  (map_2d)
% only for the top right corner when 1 bin is missing in some 5X5 experiments
if isnan(map_2d{end,end})
    map_2d{end,end}= nansum([map_2d{end-1,end};map_2d{end,end-1};map_2d{end,end-1}])/3;
else
    return
end
