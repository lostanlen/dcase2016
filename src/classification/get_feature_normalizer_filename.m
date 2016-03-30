function filename = get_feature_normalizer_filename(fold, path, extension)
    % Get normalizer filename
    %
    % Parameters
    % ----------
    % fold : int >= 0
    %     evaluation fold number
    % 
    % path :  str
    %     normalizer path
    % 
    % extension : str
    %     file extension
    %     (Default value='mat')
    %
    % Returns
    % -------
    % normalizer_filename : str
    %     full normalizer filename
    %
    %    

    if nargin < 3
        extension = 'mat';
    end    
    filename = fullfile(path, ['scale_fold',num2str(fold), '.', extension]);
end