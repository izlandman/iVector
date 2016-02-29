% function to process an entire folder set of edf all at once. assumes that
% the file listing being passed in has only the edf files for feature
% generation. breaks up the process using parfor since none of the
% operations are dependent on each other. saves all the files in a new
% directory unique to the original file name

% this will only work if the files have the same channel numbers otherwise
% each header would need to be read for the true channel number. of course,
% if the header has excessive channel tags, how do we sort out which
% channels are real? a rather extensive process no?
function edfFolderGen(file_names, target_folder, channels, window_size, mel_coefs)

file_count = numel(file_names);

parfor i=1:file_count
    try
        processEDFsingle(file_names{i},target_folder, channels, window_size, mel_coefs);
    catch
        disp( ['Failed to find/user: ', file_names{i} ]);
    end
    
end

end