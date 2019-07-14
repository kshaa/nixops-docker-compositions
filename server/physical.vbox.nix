with import ./common.nix;

{
  ${machineName} =  {
    deployment.targetEnv = "virtualbox";
    deployment.virtualbox = {
      headless   = true;
      memorySize = 1024;
    };
  };
}