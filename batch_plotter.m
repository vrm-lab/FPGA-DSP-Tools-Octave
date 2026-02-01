function batch_plotter()
    % =========================================================================
    % BATCH PLOTTER (OCTAVE/MATLAB SAFE VERSION)
    % Fitur:
    % - NO External dependency (No Perl required)
    % - Menggunakan low-level IO (fopen/dlmread) yang pasti jalan
    % =========================================================================
    
    clc;
    disp('=== Octave/MATLAB Universal Plotter ===');
    
    % 1. Input Folder
    folder_path = input('Paste path folder data: ', 's');
    folder_path = strrep(folder_path, '"', '');
    
    if ~exist(folder_path, 'dir')
        disp('Error: Path tidak valid.');
        return;
    end
    
    % 2. Get Files
    files = dir(fullfile(folder_path, '*.csv'));
    
    if isempty(files)
        disp('Tidak ada file .csv ditemukan.');
        return;
    end
    
    disp(['Memproses ', num2str(length(files)), ' file...']);
    disp('------------------------------------------------');
    
    % 3. Loop Process
    for k = 1:length(files)
        filename = files(k).name;
        filepath = fullfile(folder_path, filename);
        process_file_safe(filepath, filename);
    end
    
    disp('------------------------------------------------');
    disp('Proses Selesai.');
end

function process_file_safe(filepath, filename)
    % --- PARSING MANUAL (ANTI ERROR PERL) ---
    try
        % 1. Baca Header
        fid = fopen(filepath, 'rt');
        if fid == -1
            fprintf('[SKIP] %s -> Gagal membuka file\n', filename);
            return;
        end
        header_line = fgetl(fid);
        fclose(fid);
        
        % Bersihkan header (hapus spasi/kutip)
        header_line = strrep(header_line, '"', '');
        header_line = strrep(header_line, ' ', '');
        
        % Split header jadi cell array
        % Octave/Matlab support strsplit
        headers = strsplit(header_line, ',');
        
        % 2. Baca Data Numerik (Skip baris 1/header)
        % dlmread sangat stabil di Octave
        raw_data = dlmread(filepath, ',', 1, 0);
        
        [rows, cols] = size(raw_data);
        if isempty(raw_data)
            fprintf('[SKIP] %s -> File kosong\n', filename);
            return;
        end
        
        % Mapping ke Struct (Simulasi Table)
        T = struct();
        valid_cols = {};
        
        for i = 1:min(length(headers), cols)
            colName = headers{i};
            % Bersihkan nama variabel agar valid
            colName = regexprep(colName, '[^a-zA-Z0-9_]', '_');
            
            % Assign data column ke struct
            T.(colName) = raw_data(:, i);
            valid_cols{end+1} = colName;
        end
        
    catch err
        fprintf('[SKIP] %s -> Error parsing: %s\n', filename, err.message);
        return;
    end

    % --- LOGIKA DETEKSI (SAMA SEPERTI SEBELUMNYA) ---
    
    % Deteksi X Column (Monotonic)
    x_col = '';
    for i = 1:length(valid_cols)
        cName = valid_cols{i};
        data = T.(cName);
        % Cek monotonic increasing
        if all(diff(data) >= 0) && length(data) > 1 && max(data) > 0
            x_col = cName;
            break;
        end
    end
    
    if isempty(x_col)
        x_data = 1:rows;
        x_label = 'Index';
        y_cols = valid_cols;
    else
        x_data = T.(x_col);
        x_label = x_col;
        y_cols = setdiff(valid_cols, {x_col}, 'stable');
    end
    
    % --- GROUPING LOGIC ---
    col_struct = struct('name', {}, 'suffix', {}, 'max_val', {});
    
    for i = 1:length(y_cols)
        cName = y_cols{i};
        data = T.(cName);
        max_val = max(abs(data));
        
        suffix = 'General';
        % Regex sederhana untuk _L atau _R
        if ~isempty(regexp(cName, '(_[Ll])$', 'once'))
            suffix = 'Left';
        elseif ~isempty(regexp(cName, '(_[Rr])$', 'once'))
            suffix = 'Right';
        end
        
        col_struct(i).name = cName;
        col_struct(i).suffix = suffix;
        col_struct(i).max_val = max_val;
    end
    
    suffixes = {'Left', 'Right', 'General'};
    final_groups = {};
    group_titles = {};
    
    for s = 1:length(suffixes)
        target_sfx = suffixes{s};
        % Manual filter struct array
        idx = [];
        for m = 1:length(col_struct)
            if strcmp(col_struct(m).suffix, target_sfx)
                idx(end+1) = m;
            end
        end
        
        if isempty(idx), continue; end
        
        sfx_cols = col_struct(idx);
        
        % Manual sort struct
        vals = [sfx_cols.max_val];
        [~, sortIdx] = sort(vals);
        sfx_cols = sfx_cols(sortIdx);
        
        current_group_names = {sfx_cols(1).name};
        last_max = sfx_cols(1).max_val;
        
        for j = 2:length(sfx_cols)
            this_max = sfx_cols(j).max_val;
            col_name = sfx_cols(j).name;
            
            ratio = 0;
            if last_max > 0, ratio = this_max / last_max; end
            
            if last_max == 0 || ratio <= 10.0
                current_group_names{end+1} = col_name;
            else
                final_groups{end+1} = current_group_names;
                group_titles{end+1} = target_sfx;
                current_group_names = {col_name};
            end
            last_max = this_max;
        end
        final_groups{end+1} = current_group_names;
        group_titles{end+1} = target_sfx;
    end
    
    % --- PLOTTING ---
    num_plots = length(final_groups);
    if num_plots == 0, return; end
    
    f = figure('Visible', 'off'); 
    % Posisi window [left bottom width height]
    set(f, 'Position', [100, 100, 1000, 300 * num_plots]);
    
    for i = 1:num_plots
        subplot(num_plots, 1, i);
        hold on;
        
        cols_in_group = final_groups{i};
        suffix_title = group_titles{i};
        local_maxes = [];
        
        for c = 1:length(cols_in_group)
            cName = cols_in_group{c};
            y_data = T.(cName);
            plot(x_data, y_data, 'DisplayName', cName, 'LineWidth', 1.2);
            local_maxes(end+1) = max(abs(y_data));
        end
        
        hold off;
        grid on;
        % Legend fix untuk Octave lama
        hL = legend('show');
        set(hL, 'Location', 'northeast');
        set(hL, 'Interpreter', 'none');
        
        group_max_val = max(local_maxes);
        ylabel(sprintf('%s\n(Max ~%.1f)', suffix_title, group_max_val), 'FontWeight', 'bold');
        
        if i == 1
            title(['Visualization of: ', strrep(filename, '_', '\_')], 'FontSize', 14);
        end
        
        if i == num_plots
            xlabel(x_label, 'Interpreter', 'none');
        end
    end
    
    % --- SAVING ---
    [path_part, name_part, ~] = fileparts(filepath);
    out_png = fullfile(path_part, [name_part, '.png']);
    
    print(f, out_png, '-dpng', '-r150');
    close(f);
    
    fprintf('[OK] %s -> Tersimpan (%d grup).\n', filename, num_plots);
end