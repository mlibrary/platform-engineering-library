{
  _config+:: {
    drupal+: {
      namespace+: "default",
      files_storage+: "2G"
    }
  }
}
+
{
  drupal: {
    web: {
      storage: {
        apiVersion: "v1",
        kind: "PersistentVolumeClaim",
        metadata: {
          name: "web",
          namespace: $._config.drupal.namespace,
        },
        spec: {
          accessModes: [ "ReadWriteOnce" ],
          resources: {
            requests: {
              storage: $._config.drupal.files_storage
            }
          },
          volumeMode: "Filesystem"
        }
      }
    }
  }
}
