{
  solrCloud:: {
    new(name): {

      apiVersion: 'solr.apache.org/v1beta1',
      kind: 'SolrCloud',
      metadata: {
        name: name,
      },
      spec: {
        customSolrKubeOptions: {
          podOptions: {
            livenessProbe: {
              timeoutSeconds: 30,
            },
          },
        },
        solrAddressability: {
          podPort: 8983,
        },
        solrSecurity: {
          authenticationType: 'Basic',
        },
        updateStrategy: {
          method: 'Managed',
        },
        zookeeperRef: {
          provided: {
            chroot: '/',
            replicas: 3,
            zookeeperPodPolicy: {
              resources: {
                limits: { cpu: '500m' },
                requests: { cpu: '300m' },
              },
            },
          },
        },
      },
    } + self.withZookeeperPersistentStorage(),

    withRecommendedGCTuning(): {
      spec+: {
        solrGCTune+: |||
          -XX:+ExplicitGCInvokesConcurrent
          -XX:SurvivorRatio=4
          -XX:TargetSurvivorRatio=90
          -XX:MaxTenuringThreshold=8
          -XX:+UseConcMarkSweepGC
          -XX:ConcGCThreads=4 -XX:ParallelGCThreads=4
          -XX:+CMSScavengeBeforeRemark
          -XX:PretenureSizeThreshold=64m
          -XX:+UseCMSInitiatingOccupancyOnly
          -XX:CMSInitiatingOccupancyFraction=50
          -XX:CMSMaxAbortablePrecleanTime=6000
          -XX:+CMSParallelRemarkEnabled
          -XX:+ParallelRefProcEnabled
        |||,
      },
    },

    withIngress(domain): {
      local name = self.metadata.name,

      spec+: {
        customSolrKubeOptions+: {
          ingressOptions+: {
            annotations+: {
              'cert-manager.io/cluster-issuer': 'letsencrypt',
            },
            ingressClassName: 'nginx',
          },
        },

        solrAddressability+: {
          external: {
            domainName: domain,
            hideNodes: true,
            ingressTLSTermination: {
              tlsSecret: name + '-solrcloud-common',
            },
            method: 'Ingress',
            useExternalAddress: false,
          },
        },
      },
    },

    withSolrImage(repository='solr', tag): {
      spec+: { solrImage+: {
        repository: repository,
        tag: tag,
      } },
    },

    withSolrJavaMem(memory): { spec+: { solrJavaMem: memory } },
    withSolrOpts(opts): { spec+: { solrOpts: opts } },

    withSolrEphemeralStorage(size='4Gi', medium=''): {
      spec+: { dataStorage: { ephemeral: { emptyDir: {
        sizeLimit: size,
        medium: medium,
      } } } },
    },

    withSolrPersistentStorage(storage_class='rook-ceph-block', size='4Gi'): {
      spec+: { dataStorage: { persistent: { pvcTemplate: {
        spec: {
          accessModes: ['ReadWriteOnce'],
          resources: {
            requests: {
              storage: size,
            },
          },
          storageClassName: storage_class,
        },
      } } } },
    },

    withSolrResources(resources): { spec+: { customSolrKubeOptions+: { resources: resources } } },

    withZookeeperPersistentStorage(storage_class='rook-ceph-block', size='200Mi'): {
      spec+: { zookeeperRef+: { provided+: { persistence: {
        spec: {
          accessModes: ['ReadWriteOnce'],
          resources: {
            requests: {
              storage: size,
            },
          },
          storageClassName: storage_class,
        },
      } } } },
    },

    withZookeeperResources(resources): { zookeeperRef+: { provided+: { zookeeperPodPolicy+: resources } } },

    withZookeeperReplicas(count): { zookeeperRef+: { provided+: { replicas: count } } },

    prometheusExporterFor(solrcloud): {
      local cloud_name = solrcloud.metadata.name,

      apiVersion: 'solr.apache.org/v1beta1',
      kind: 'SolrPrometheusExporter',
      metadata: {
        name: cloud_name + '-prom-exporter',
      },
      spec: {
        solrReference: {
          cloud: {
            name: cloud_name,
          },
          basicAuthSecret: cloud_name + '-solrcloud-basic-auth',
        },
        numThreads: 4,
        scrapeInterval: 30,

        image: {
          repository: 'solr',
          tag: '8.11.1',
        },
      } + if (std.objectHas(solrcloud.spec, 'solrImage')) then { image: solrcloud.spec.solrImage } else {},
    },
  },

}
