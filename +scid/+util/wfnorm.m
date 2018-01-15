function output = wfnorm(wf)
%WFNORM Return the norm of the wave function
%   Input:
%      wf: the wave function
%   Output:
%      the norm of the wave function

  output = 0;
  
  for i = 1:size(wf,3)
    output = output + sum(wf(:,2,i) .* wf(:,3,i));
  end

end
