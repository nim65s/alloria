{
  lib,
  python3,
  version,
}:

python3.pkgs.buildPythonApplication {
  inherit version;
  pname = "alloria";
  pyproject = true;

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./alloria
      ./pyproject.toml
      ./README.md
    ];
  };

  build-system = [
    python3.pkgs.hatchling
  ];

  dependencies = with python3.pkgs; [
    aiomqtt
  ];

  pythonImportsCheck = [
    "alloria"
  ];

  meta = {
    description = "Escape game sound system";
    homepage = "https://github.com/nim65s/alloria";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nim65s ];
    mainProgram = "alloria";
  };
}
