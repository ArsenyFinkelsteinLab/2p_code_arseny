for i=1:1:10000
    try
        DJconnect
        populate(POP.ROISVDDistanceScaleSpikes)
    catch
           pause(60)
    end
        
end