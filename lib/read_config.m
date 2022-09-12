% reads the configuration .json file and parses data
function config = read_config(fname_config)
    fid = fopen(fname_config);
    raw = fread(fid, inf);
    str = char (raw');
    fclose(fid);
    config = jsondecode(str);
end