function [xxx_interp] = fn_interpolate_lick (xxx, max_frames_interp, frame_idx)

%   max_frames_interp if there is a non NaN value within this number of frames on each side of the peak we'll take it for interpolation. If there is only a non NaN value on one of the sides from the peak, we'll take this value

xxx_interp=xxx;
if isnan(xxx(frame_idx))
    temp_xxx=xxx;
    temp_xxx(isnan(xxx))=0;
    t_bf = find(temp_xxx(1:1:frame_idx),1, 'last');
    t_af = find(temp_xxx(frame_idx:1:end),1, 'first') + frame_idx -1;
    if ((t_af- frame_idx)<=max_frames_interp & (frame_idx-t_bf)<=max_frames_interp)
        xxx_interp(frame_idx) = interp1([t_bf,t_af],[xxx(t_bf), xxx(t_af)],frame_idx);
    elseif (frame_idx-t_bf)<=max_frames_interp
        xxx_interp(frame_idx) =xxx(t_bf);
    elseif (t_af- frame_idx)<=max_frames_interp
        xxx_interp(frame_idx) =xxx(t_af);
    end
end
