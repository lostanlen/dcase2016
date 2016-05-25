classdef FeatureNormalizer < handle
    % Feature normalizer class
    % 
    % Accumulates feature statistics
    % 
    % Examples
    % --------
    % 
    % normalizer = FeatureNormalizer();
    % train_items = dataset.train(fold);
    % for item_id=1:length(train_items)
    %   ...
    %   normalizer.accumulate(feature_data);
    % end
    % normalizer.finalize();
    %
    % test_items = dataset.test(fold);
    % for item_id=1:length(train_items)
    %   ...
    %   feature_data_normalized = normalizer.normalize(feature_data);
    % end
    
    properties
        N = 0;
        mean = 0;
        S1 = 0;
        S2 = 0;
        std = 0;
        
        cumulative_energy_threshold = 0.0;
        
        monotonic_transformation = struct('type', 'identity');
    end
    
    methods
        function obj = FeatureNormalizer( ...
                cumulative_energy_threshold, monotonic_transformation)
            % Initialization
            %

            obj.cumulative_energy_threshold = cumulative_energy_threshold;
            
            obj.monotonic_transformation = monotonic_transformation;
        end
        
        function accumulate(obj, stat)  
            % Accumalate statistics
            % 
            % Input is statistics struct, format:
            % 
            %     struct(
            %             'mean', mean(feature_matrix,2),...
            %             'std',std(feature_matrix,0,2),...
            %             'N',size(feature_matrix,2),...
            %             'S1',sum(feature_matrix,2),...
            %             'S2',sum(feature_matrix.^2,2)
            %           )
            % 
            % Parameters
            % ----------
            % stat : struct
            %     Statistics struct
            % 
            % Returns
            % -------
            % nothing
            % 
            
            obj.N = obj.N + stat.N;        
            obj.mean = obj.mean + stat.mean;
            obj.S1 = obj.mean + stat.S1;
            obj.S2 = obj.mean + stat.S2;
        end

        function finalize(obj)
            % Finalize statistics calculation
            % 
            % Accumulated values are used to get mean and std for the seen feature data.
            % 
            % Parameters
            % ----------
            % nothing
            % 
            % Returns
            % -------
            % nothing
            % 

            obj.mean = obj.S1 / obj.N;
            obj.std = ...
                sqrt((obj.N * obj.S2 - (obj.S1 .* obj.S1)) / (obj.N .* (obj.N - 1)));
        end
                
        function feature_matrix = normalize(obj, feature_matrix)  
            % Normalize feature matrix with internal statistics of the class
            % 
            % Parameters
            % ----------
            % feature_matrix : matrix [shape=(number of feature values, frames)]
            %     Feature matrix to be normalized
            % 
            % Returns
            % -------
            % feature_matrix : matrix [shape=(number of feature values, frames)]
            %     Normalized feature matrix
            % 

            for i=1:size(feature_matrix,1), 
				feature_matrix(i,:)= (feature_matrix(i,:)-obj.mean(i)) / obj.std(i);
			end	
        end
    end
    
end

