{
  config,
  ...
}:

{
  age.secrets.niks3-auth-token = {
    owner = "niks3";
    group = "niks3";
    mode = "0400";
    rekeyFile = ../../../secrets/niks3-auth-token.age;
  };
  age.secrets.niks3-signing-key = {
    rekeyFile = ../../../secrets/niks3-signing-key.age;
    owner = "niks3";
    group = "niks3";
    mode = "0400";
  };
  age.secrets.niks3-s3-access-key = {
    rekeyFile = ../../../secrets/niks3-s3-access-key.age;
    owner = "niks3";
    group = "niks3";
    mode = "0400";
  };
  age.secrets.niks3-s3-secret-key = {
    rekeyFile = ../../../secrets/niks3-s3-secret-key.age;
    owner = "niks3";
    group = "niks3";
    mode = "0400";
  };

  niks3 = {
    enable = true;
    db = "remote";
    publicURL = "niks3.${config.web.rootDomain}";
    niks3-auth-token = config.age.secrets.niks3-auth-token.path;
    niks3-signing-key = config.age.secrets.niks3-signing-key.path;
    niks3-s3-access-key = config.age.secrets.niks3-s3-access-key.path;
    niks3-s3-secret-key = config.age.secrets.niks3-s3-secret-key.path;
  };
}
