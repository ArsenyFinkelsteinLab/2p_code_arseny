function [IDX_remove] = fn_remove_neighbors_2D(XY_all, minimal_distance)


List_all=[1:1:size(XY_all,1)]';

% initializing
IDX_remove=[];
XY_updated=XY_all;
List_updated = List_all;

for j=1:1:numel(List_all)
    
    for i =1:1:numel(List_updated)
        dx = XY_updated(:,1) - XY_updated(i,1);
        dy = XY_updated(:,2) - XY_updated(i,2);
        dist = (sqrt(dx.^2 + dy.^2));
        
        idx_remove_temp = find(dist<=minimal_distance);
        idx_remove_temp(idx_remove_temp==i)=[]; %removes self
        if ~isempty(idx_remove_temp)
            IDX_remove = [IDX_remove;List_updated(idx_remove_temp)];
            XY_updated(idx_remove_temp,:)=[];
            List_updated(idx_remove_temp,:)=[];
            break;
        end
    end
    if i ==numel(List_updated)
        break
    end
end



