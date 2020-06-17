function savestack(I,filename)
%SAVESTACK Save m x n x o matrix as a tiff stack
    options.overwrite = true;
    options.message = false;
    options.big = true; % Use BigTIFF format
    saveastiff(I, filename, options);
    options.append = true;
    for l=2:size(I,3)   
        saveastiff(I, filename, options);
    end
end

