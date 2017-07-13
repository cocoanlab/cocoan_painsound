function ts = generate_ts_semic(session_n, varargin)

% [ts, exp] = generate_ts_semic
%
% Session 1 (1 run, 4 levels x 5 times = 20 trials) : target cue + rating 
% Session 2 (1 run, 3 levels x 6 times = 18 trials) : pain + rating
% Session 3 (3 runs, 3 levels x 3 mean x 2 sd = 18 trials x 3 runs = 54 trials): cue + pain + rating 

semicircular = false;
rng('shuffle');

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'semicircular'}
                semicircular = true;
            case {'linear'}
                semicircular = false;
            case {'data'}
                data = varargin{i+1};
        end
    end
end

switch session_n
    case 1
        
        S1{1} = repmat({'NONE'}, 20, 1);
        S1{2} = repmat({'LV0'}, 20, 1);
        S1{3} = repmat({'0000'}, 20, 1);
        S1{5} = repmat({'3'}, 20, 1);
        S1{6} = repmat({'3', '9'; '5', '7'; '9', '3'}, 7, 1);
        S1{7} = repmat({{'draw_social_cue', [.2, 0, 1]}; {'draw_social_cue', [.4, 0, 1]}; {'draw_social_cue', [.6, 0, 1]}; {'draw_social_cue', [.8, 0, 1]}}, 5, 1);
        
        if semicircular
            S1{4} = repmat({'overall_avoidance_semicircular'}, 20, 1);
        else
            S1{4} = repmat({'overall_avoidance'}, 20, 1); 
        end
        
        trial_n = 20;
        
        for k = 1:numel(S1)
            for run_i = 1
                temp = S1{k}(randperm(trial_n),:);
                switch k
                    case {1, 2, 3, 5}
                        for j = 1:trial_n
                            ts{run_i}{j}(k) = temp(j);
                        end
                    case 4
                        for j = 1:trial_n
                            ts{run_i}{j}(4) = {temp(j)};
                        end
                    case 6
                        for j = 1:trial_n
                            ts{run_i}{j}(6) = temp(j,1);
                            ts{run_i}{j}(7) = temp(j,2);
                        end
                    case 7
                        for j = 1:trial_n
                            ts{run_i}{j}(8) = temp(j);
                        end
                end
            end
        end
        
    case 2
        
        S2{1} = repmat({'PP'}, 18, 1);
        S2{2} = repmat({'LV1'; 'LV2'; 'LV3'}, 6, 1);
        S2{3} = repmat({'0010'}, 18, 1);
        S2{5} = repmat({'0'}, 18, 1);
        S2{6} = repmat({'5', '11'; '7', '9'; '9', '7'; '11', '5'}, 5, 1);
        
        if semicircular
            S2{4} = repmat({'overall_avoidance_semicircular'}, 18, 1);
        else
            S2{4} = repmat({'overall_avoidance'}, 18, 1); 
        end
        
        trial_n = 18;
        
        for k = 1:numel(S2)
            for run_i = 1
                temp = S2{k}(randperm(trial_n),:);
                switch k
                    case {1, 2, 3, 5}
                        for j = 1:trial_n
                            ts{run_i}{j}(k) = temp(j);
                        end
                    case 4
                        for j = 1:trial_n
                            ts{run_i}{j}(4) = {temp(j)};
                        end
                    case 6
                        for j = 1:trial_n
                            ts{run_i}{j}(6) = temp(j,1);
                            ts{run_i}{j}(7) = temp(j,2);
                        end
                end
            end
        end
        
    case 3
        
        S3{1} = repmat({'PP'}, 18, 1);
        S3{2} = reshape(repmat({'LV1'; 'LV2'; 'LV3'}, 1, 6)', [], 1);
        S3{3} = repmat({'0010'}, 18, 1);
        S3{5} = repmat({'3'}, 18, 1);
        S3{6} = repmat({'5', '11'; '7', '9'; '9', '7'; '11', '5'}, 5, 1);
        
        if semicircular
            S3{4} = repmat({'overall_avoidance_semicircular'}, 18, 1);
        else
            S3{4} = repmat({'overall_avoidance'}, 18, 1);
        end
        
        % make S3{7}
        for j = 1:3, rating_lv{j} = []; end
        
        if exist('data', 'var')
            for trial_i = 1:numel(data.dat{1})
                if semicircular
                    rating_lv{str2double(data.dat{1}{trial_i}.intensity(end))}(end+1) = data.dat{1}{trial_i}.overall_avoidance_semicircular_rating_r_theta(:,2);
                else
                    rating_lv{str2double(data.dat{1}{trial_i}.intensity(end))}(end+1) = data.dat{1}{trial_i}.overall_avoidance_rating;
                end
            end
        else
            warning('There is no data file. It will use a fake data.');
            rating_lv{1} = .2;
            rating_lv{2} = .35;
            rating_lv{3} = .5;
        end
        
        ref_mean = cellfun(@mean, rating_lv)';
        ref_bounds = [ref_mean - mean(diff(ref_mean)) ref_mean + mean(diff(ref_mean))]; % column 1: lower bound, column 2: upper bound
        
        std=[.03 .05 .12 .14];
        
        for i = 1:3
            temp_bounds(i,:) = linspace(ref_bounds(i,1), ref_bounds(i,2), 3);
            [A,B] = meshgrid(temp_bounds(i,:), std);
            temp_pair = reshape(cat(2, A', B'), [], 2);
            ref(6*i-5:6*i, :) = temp_pair([randperm(6,3) randperm(6,3)+6],:);
        end
        
        for ii = 1:size(ref,1)
            S3{7}{ii,1} = [S3{2}(ii) {'draw_social_cue', [ref(ii,1), ref(ii,2)+(rand/30-(1/30)/2), 20]}]; % add a little randomness
        end
        
        trial_n = 18;
        
        for k = 1:numel(S3)
            for run_i = 1:3 
                temp = S3{k}(randperm(trial_n),:);
                switch k
                    case {1, 3, 5}
                        for j = 1:trial_n
                            ts{run_i}{j}(k) = temp(j);
                        end
                    case 4
                        for j = 1:trial_n
                            ts{run_i}{j}(4) = {temp(j)};
                        end
                    case 6
                        for j = 1:trial_n
                            ts{run_i}{j}(6) = temp(j,1);
                            ts{run_i}{j}(7) = temp(j,2);
                        end
                    case 7
                        for j = 1:trial_n
                            ts{run_i}{j}(2) = temp{j}(1);
                            ts{run_i}{j}{8} = temp{j}(2:3);
                        end
                end
            end
        end

end