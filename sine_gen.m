% =========================================================================
% Script: sine_gen.m
% Description: Menghasilkan Verilog Case Statement untuk Sine LUT 256x16-bit
% Usage: Jalankan di Octave/MATLAB
% =========================================================================

DEPTH = 256;      % Jumlah sample (resolusi fase)
WIDTH = 16;       % Lebar data output
MAX_VAL = 32767;  % 2^15 - 1 (Signed 16-bit max)

filename = 'sine_lut_256_body.v';
fid = fopen(filename, 'w');

fprintf(fid, '// Copy paste bagian ini ke dalam module sine_lut_256\n');
fprintf(fid, 'always @(posedge clk) begin\n');
fprintf(fid, '    case(addr)\n');

for i = 0 : DEPTH-1
    % Hitung nilai sinus (0 sampai 2*pi)
    angle = (i / DEPTH) * 2 * pi;
    val = round(sin(angle) * MAX_VAL);
    
    % Konversi ke format Hex (Two's Complement manual untuk Octave)
    if val < 0
        val_hex = 2^WIDTH + val;
    else
        val_hex = val;
    end
    
    % Format string hex 4 digit (misal: 16'h7FFF)
    hex_str = dec2hex(val_hex, 4);
    
    % Tulis ke file/layar
    fprintf(fid, '        8''d%-3d: data = 16''h%s; // %.4f\n', i, hex_str, sin(angle));
end

fprintf(fid, '        default: data = 16''h0000;\n');
fprintf(fid, '    endcase\n');
fprintf(fid, 'end\n');

fclose(fid);

fprintf('File generated: %s\n', filename);
