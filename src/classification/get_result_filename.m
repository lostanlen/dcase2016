function filename = get_result_filename(fold, path, extension)
    % Get result filename
    %
    % Parameters
    % ----------
    % fold : int >= 0
    %     evaluation fold number
    % 
    % path :  str
    %     result path
    % 
    % extension : str
    %     file extension
    %     (Default value='mat')
    % 
    % Returns
    % -------
    % result_filename : str
    %     full result filename
    %

    if nargin < 3
        extension = 'txt';
    end
    filename = fullfile(path, ['results_fold',num2str(fold), '.', extension]);
end