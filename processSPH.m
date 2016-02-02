% point program to folder containing the nist2001/sph/DEVTEST/TRAIN/MALE
% hierarchy. each of these will be in sphere format (SPH) so they need to
% be converted before they can be turned into GMMs for the UBM! given the
% GMMs could be larger, they may need to be saved outside the program
% instead of being stored in memory


function processSPH(folder,varargin)

% set default parameters in the event none are supplied

% time in seconds
mel_window = 0.020;
% coefficients past the 0th
mel_coeff = 12;
% the sphere files are long, specify how many sections to break them into
channels = 10;

display( nargin );
if( nargin == 2 )
    channels = varargin{1};
elseif( nargin == 3)
    channels = varargin{1};
    mel_coeff = varargin{2};
elseif( nargin == 4)
    channels = varargin{1};
    mel_coeff = varargin{2};
    mel_window= varargin{3};
end

default_pathway = '/nist2001/sph/DEVTEST/TRAIN/MALE';
default_extension = '*.sph';

default_target = [ folder , default_pathway ,'/', default_extension ];

files = dir();
all_dir = files([files(:).isdir]);
num_dir = numel(all_dir);
tags = cell(num_dir,1);
for k=1:num_dir
    tags{k}  = all_dir(k).name;
end
mel_count = cellfun(@(S) strfind(S,'melData'), tags,'uniformoutput',0);
mel_count = sum( [mel_count{:}] );

files = dir( default_target );
file_count = length(files);

% build variables that will be returned from readsph
raw_data = cell(1,1);
FS = raw_data;
WRD = raw_data;
PHN = raw_data;
FFX = raw_data;

set_c = cell(file_count,channels);
set_tc = set_c;

for i = 1 : file_count
    target_filename = [folder , default_pathway , '/', files(i).name];
    [raw_data, FS, WRD, PHN, FFX] = readsph( target_filename );
    
    % it appears that the raw data in these files is sometimes devoid of
    % values, all zer0, which throws an error when attempting to convert
    % into melcepst coefficents
    
    raw_data_length = length(raw_data);
    raw_data_sample_rate = FFX{2,1}{5,2};
    data_window = mel_window * raw_data_sample_rate;
    
    data_break = ceil(raw_data_length/channels);
    channel_shift = 0;
    for k=1:channels
        % build variables for mel results
        windows = floor(data_break / data_window);
        c = zeros(mel_coeff,windows);
        tc = zeros(1,windows);
        
        for j = 1 : windows
            
            % turn raw_data into features from recording based upon window
            data_index = 1 + data_window*(j-1) + channel_shift;
            data_mel = raw_data(data_index:data_index+data_window-1);
            % try to avoid knowingly giving mel data that is empty
            if ( sum(abs(data_mel)) ~= 0 )
                [c(:,j), tc(:,j)] = melcepst( ...
                    data_mel, ...
                    raw_data_sample_rate, ...
                    'Mta', ...
                    mel_coeff);
            else
                display('a window came back with a zer0 mode');
            end
        end
        
        channel_shift = data_break * k;
        if ( data_index+data_window-1 + data_break > raw_data_length )
            data_break = raw_data_length - ( data_index+data_window-1 );
        end
        
        % some of the data could be zero or null which is going to hurt the
        % model, prune it
        nan_map = isnan(c);
        c(nan_map) = 0;
        
        set_c{i,k} = c;
        set_tc{i,k} = tc;
    end
end


mel_folder = ['melData_',num2str(mel_count)];
% save the generated coefficents and time stamps
if( exist(mel_folder,'dir') == 0)
    % directy does not exist, makeone
    mkdir(mel_folder);
end
c_save_file = ['./',mel_folder,'/data_melCoef', num2str(mel_coeff), '_melWin', num2str(mel_window*1000), '_c', num2str(channels), '.mat'];
tc_save_file = ['./',mel_folder,'/time_melCoef', num2str(mel_coeff), '_melWin', num2str(mel_window*1000), '_c', num2str(channels),'.mat'];
listing_save_file = ['./',mel_folder,'/list_melCoef', num2str(mel_coeff), '_melWin', num2str(mel_window*1000), '_c', num2str(channels),'.dat'];

fId = fopen(listing_save_file,'wt');
for i=1:file_count
    fprintf(fId, '%s\n',files(i).name);
end
fclose(fId);

if ( exist(c_save_file,'file') == 2 )
    display('data already exists. deleting and recreating.');
    delete(c_save_file,tc_save_file);
    save(c_save_file,'set_c');
    save(tc_save_file,'set_tc');
else
    display('data does not exist. generating');
    save(c_save_file,'set_c');
    save(tc_save_file,'set_tc');
end

end