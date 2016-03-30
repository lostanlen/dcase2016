function filename = get_model_filename(fold, path, extension)
    % Get model filename
    % 
    % Parameters
    % ----------
    % fold : int >= 0
    %     evaluation fold number
    % 
    % path :  str
    %     model path
    % 
    % extension : str
    %     file extension
    %     (Default value='mat')
    % 
    % Returns
    % -------
    % model_filename : str
    %     full model filename
    % 
    %    

    if nargin < 3
        extension = 'mat';
    end
    filename = fullfile(path, ['model_fold',num2str(fold), '.', extension]);
end