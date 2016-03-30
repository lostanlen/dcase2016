function filename = get_feature_filename(audio_file, path, extension)
    % Get feature filename
    %
    % Parameters
    % ----------
    % audio_file : str
    %     audio file name from which the features are extracted
    % 
    % path :  str
    %     feature path
    % 
    % extension : str
    %     file extension
    %     (Default value='mat')
    %
    % Returns
    % -------
    % feature_filename : str
    %     full feature filename
    %
    %

    if nargin < 3
        extension = 'mat';
    end
    [~, raw_filename, ext] = fileparts(audio_file);    
    filename = fullfile(path, [raw_filename, '.', extension]);
end

