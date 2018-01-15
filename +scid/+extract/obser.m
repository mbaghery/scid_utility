function [time, vp, norm, energy, dipole_z, groundstate] = obser(outputfile)
%OBSER Extract the information in the output file
%and save it in a .mat file next to the output file.
%Furthermore, return the extracted information.
%
%   Input:
%     outputfile
%   Ouput:
%     [time, vp (vp_magnitude, theta, phi), norm (complex), energy (complex),
%      dipole_z, gs (population, phase)]


  [path,name,~] = fileparts(outputfile);
  matfile = fullfile(path, [name, '.mat']);
  
  if exist(matfile, 'file')
    load(matfile, 'time', 'vp', 'norm', 'energy', 'dipole_z', 'groundstate');
    
    if exist('groundstate', 'var')
      return;
    end
  end
  
  
  % load the parameters
  params = scid.extract.params(outputfile);
  
  
  
  no_output_lines = floor(params.simlength / (params.dt * params.output_each));
  
  time = zeros(no_output_lines, 1);
  vp = zeros(no_output_lines, 3);
  norm = complex(zeros(no_output_lines, 1));
  energy = complex(zeros(no_output_lines, 1));
  dipole_z = zeros(no_output_lines, 1);
  groundstate = zeros(no_output_lines, 2);
  
  
  

  f = fopen(outputfile);
  
  while ~feof(f)
    line = upper(fgetl(f));
    if isempty(line)
      continue;
    end
    
    if (line(1) == '@')
      break;
    end
  end
  

  formatSpec = '%*s %*f %*s %f %*s %f %*s %f %*s %f %*s %f %f %*s %f %f %*s %f %*s %f %*s %f';

  for i = 1:no_output_lines
    a = sscanf(line, formatSpec);
    
    % the new version sometimes adds a line in the middle of simulation
    if (length(a) < 10)
      line = upper(fgetl(f));
      a = sscanf(line, formatSpec);
    end
    
    % time, [vp, th, ph], norm (complex), energy (complex), dipole_z, gs (population, phase)
    time(i) = a(1);
    vp(i,:) = [a(2), a(3), a(4)];
    norm(i) = complex(a(5),a(6));
    energy(i) = complex(a(7),a(8));
    dipole_z(i) = a(9);
    groundstate(i,:) = [a(10), a(11)];
    
    line = upper(fgetl(f));
  end

  
  
  if exist(matfile, 'file')
    save(matfile, 'time', 'vp', 'norm', 'energy', 'dipole_z', 'groundstate', '-append');
  else
    save(matfile, 'time', 'vp', 'norm', 'energy', 'dipole_z', 'groundstate');
  end

end

