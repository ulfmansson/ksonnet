{
  global: {
    // User-defined global parameters; accessible to all component and environments, Ex:
    // replicas: 4,
  },
  components: {
    "proc1": {
      image: "docker",
      replicas: 1,
    },
  },
}
