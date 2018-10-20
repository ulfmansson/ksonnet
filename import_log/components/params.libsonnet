{
  global: {
    // User-defined global parameters; accessible to all component and environments, Ex:
    // replicas: 4,
  },
  components: {
    process: {
        name: "import-log",
        replicas: 1,
        image: "docker.ccdp.io:5000/import_log"
    },
    namespace: {
      name: "import-log"
    },
    "proc1": {
      image: "docker",
      name: "import-log",
      replicas: 2,
    },
  },
}
