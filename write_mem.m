function write_mem(filename, data)
  fid = fopen(filename, "w");

  if fid < 0
    error("Cannot open file: %s", filename);
  end

  for k = 1:numel(data)
    fprintf(fid, "%04X\n", mod(data(k), 2^16));
  end

  fclose(fid);
end
