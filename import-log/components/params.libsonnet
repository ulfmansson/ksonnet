{
  global: {
    // User-defined global parameters; accessible to all component and environments, Ex:
    // replicas: 4,
  },
  components: {
    "guestbook-ui": {
      image: "docker",
      name: "import-log",
      replicas: 2,
    },
  },
}
