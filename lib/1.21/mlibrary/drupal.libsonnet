{
  _config+:: {
    drupal+: {
      namespace+: 'default',
      files_storage+: '2G',
      db_user: 'drupal',
      db_database: 'drupal',
      db_host: 'db',
      argo_project: 'default',
      env: [],
      secrets: [],
    },
  },
}
+
{
  drupal: {
    web: {
      storage: {
        apiVersion: 'v1',
        kind: 'PersistentVolumeClaim',
        metadata: {
          name: 'web',
          namespace: $._config.drupal.namespace,
        },
        spec: {
          accessModes: ['ReadWriteOnce'],
          resources: {
            requests: {
              storage: $._config.drupal.files_storage,
            },
          },
          volumeMode: 'Filesystem',
        },
      },
      service: {
        apiVersion: 'v1',
        kind: 'Service',
        metadata: {
          name: 'web',
          namespace: $._config.drupal.namespace,
          labels: {
            name: 'web',
          },
        },
        spec: {
          ports: [
            {
              name: 'web',
              port: 80,
              targetPort: 80,
            },
          ],
          selector: {
            app: 'web',
          },
        },
      },
      deployment: {
        apiVersion: 'apps/v1',
        kind: 'Deployment',
        metadata: {
          name: 'web',
          namespace: $._config.drupal.namespace,
        },
        spec: {
          minReadySeconds: 10,
          replicas: 2,
          revisionHistoryLimit: 10,
          selector: { matchLabels: { app: 'web' } },
          strategy: { type: 'Recreate' },
          template: {
            metadata: { labels: { app: 'web' } },
            spec: {
              containers: [
                {
                  env: [
                         { name: 'HASH_SALT', valueFrom: { secretKeyRef: {
                           key: 'HASH_SALT',
                           name: 'drupal-hash-salt',
                         } } },
                         { name: 'MARIADB_PASSWORD', valueFrom: { secretKeyRef: {
                           key: 'MARIADB_PASSWORD',
                           name: 'db',
                         } } },
                         { name: 'MARIADB_USER', value: $._config.drupal.db_user },
                         { name: 'MARIADB_DATABASE', value:
                           $._config.drupal.db_database },
                         { name: 'DATABASE_HOST', value: $._config.drupal.db_host },
                       ] + $._config.drupal.env
                       + std.map(
                         (function(x)
                            {
                              name: x.key,
                              valueFrom: {
                                secretKeyRef: {
                                  key: x.key,
                                  name: x.name,
                                },
                              },
                            }), $._config.drupal.secrets
                       ),
                  image: $._config.drupal.image,
                  imagePullPolicy: 'IfNotPresent',
                  name: 'web',
                  ports: [
                    { containerPort: 80, name: 'web' },
                  ],
                  volumeMounts: [
                    {
                      mountPath: '/var/www/html/sites/default/files',
                      name: 'drupal-files',
                    },
                  ],
                },
              ],
              imagePullSecrets: [{ name: 'github-packages-read' }],
              volumes: [
                {
                  name: 'drupal-files',
                  persistentVolumeClaim: { claimName: 'web' },
                },
              ],
            },
          },
        },
      },
      ingress: {
        apiVersion: 'networking.k8s.io/v1',
        kind: 'Ingress',
        metadata: {
          labels: {
            'argocd.argoproj.io/instance': $._config.drupal.argo_project,
          },
          name: 'web',
          namespace: $._config.drupal.namespace,
        },
        spec: {
          rules:
            [
              {
                host: $._config.drupal.host,
                http: {
                  paths: [
                    {
                      backend: { service: { name: 'web', port: { number: 80 } } },
                      path: '/',
                      pathType: 'ImplementationSpecific',
                    },
                  ],
                },
              },
            ],
          tls: [
            {
              hosts: [$._config.drupal.host],
              secretName: 'web-tls',
            },
          ],
        },
      },
    },
  },
}
