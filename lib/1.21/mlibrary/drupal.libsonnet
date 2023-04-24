{
  _config+:: {
    drupal+: {
      namespace: 'default',
      web+: {
        files_storage: '2G',
        env+: [],
        secrets+: [],
        certificate_manager: 'letsencrypt',
        //image:  ghcr.io/mlibrary/your-image:1.0 //required
        //host: cms.my-cluster.lib.umich.edu //required
      },
      argo_project: 'default',
      db+: {
        user: 'drupal',
        database: 'drupal',
        host: 'db',
        image: 'mariadb:10.6',
        storage: '1G',
        memory: '500M',
      },
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
          labels: {
            'argocd.argoproj.io/instance': $._config.drupal.argo_project,
          },
        },
        spec: {
          accessModes: ['ReadWriteOnce'],
          resources: {
            requests: {
              storage: $._config.drupal.web.files_storage,
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
            'argocd.argoproj.io/instance': $._config.drupal.argo_project,
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
          labels: {
            'argocd.argoproj.io/instance': $._config.drupal.argo_project,
          },
        },
        spec: {
          minReadySeconds: 10,
          replicas: 1,
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
                         { name: 'MARIADB_USER', value: $._config.drupal.db.user },
                         { name: 'MARIADB_DATABASE', value:
                           $._config.drupal.db.database },
                         { name: 'DATABASE_HOST', value: $._config.drupal.db.host },
                       ] + $._config.drupal.web.env
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
                            }), $._config.drupal.web.secrets
                       ),
                  image: $._config.drupal.web.image,
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
          annotations: {
            'cert-manager.io/cluster-issuer':
              $._config.drupal.web.certificate_manager,
          },
          name: 'web',
          namespace: $._config.drupal.namespace,
        },
        spec: {
          rules:
            [
              {
                host: $._config.drupal.web.host,
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
              hosts: [$._config.drupal.web.host],
              secretName: 'web-tls',
            },
          ],
        },
      },
    },
    db: {
      storage: {
        apiVersion: 'v1',
        kind: 'PersistentVolumeClaim',
        metadata: {
          name: 'db',
          namespace: $._config.drupal.namespace,
          labels: {
            'argocd.argoproj.io/instance': $._config.drupal.argo_project,
          },
        },
        spec: {
          accessModes: ['ReadWriteOnce'],
          resources: {
            requests: {
              storage: $._config.drupal.db.storage,
            },
          },
          volumeMode: 'Filesystem',
        },
      },
      service: {
        apiVersion: 'v1',
        kind: 'Service',
        metadata: {
          name: 'db',
          namespace: $._config.drupal.namespace,
          labels: {
            name: 'db',
            'argocd.argoproj.io/instance': $._config.drupal.argo_project,
          },
        },
        spec: {
          ports: [
            {
              name: 'mysql',
              port: 3306,
              targetPort: 3306,
            },
          ],
          selector: {
            app: 'db',
          },
        },
      },
      deployment: {
        apiVersion: 'apps/v1',
        kind: 'Deployment',
        metadata: {
          name: 'db',
          namespace: $._config.drupal.namespace,
          labels: {
            'argocd.argoproj.io/instance': $._config.drupal.argo_project,
          },
        },
        spec: {
          minReadySeconds: 10,
          replicas: 1,
          revisionHistoryLimit: 10,
          selector: { matchLabels: { app: 'db' } },
          strategy: { type: 'Recreate' },
          template: {
            metadata: { labels: { app: 'db' } },
            spec: {
              containers: [
                {
                  env: [
                    { name: 'MARIADB_USER', value: $._config.drupal.db.user },
                    { name: 'MARIADB_DATABASE', value: $._config.drupal.db.database },
                    { name: 'MARIADB_ROOT_PASSWORD', valueFrom: { secretKeyRef: {
                      key: 'MARIADB_ROOT_PASSWORD',
                      name: 'db-root',
                    } } },
                    { name: 'MARIADB_PASSWORD', valueFrom: { secretKeyRef: {
                      key: 'MARIADB_PASSWORD',
                      name: 'db',
                    } } },
                  ],
                  image: $._config.drupal.db.image,
                  imagePullPolicy: 'IfNotPresent',
                  name: 'mysql',
                  ports: [
                    { containerPort: 3306, name: 'mysql' },
                  ],
                  resources: {
                    requests: { memory: $._config.drupal.db.memory },
                  },
                  volumeMounts: [
                    {
                      mountPath: '/var/lib/mysql',
                      name: 'mariadb',
                    },
                  ],
                },
              ],
              volumes: [
                {
                  name: 'mariadb',
                  persistentVolumeClaim: { claimName: 'db' },
                },
              ],
            },
          },
        },
      },
    },
  },
}
