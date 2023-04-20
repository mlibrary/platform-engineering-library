(import '1.21/mlibrary/drupal.libsonnet') +
{
  _config+:: {
    drupal+: {
      namespace: 'cms',
      web: {
        files_storage: '2G',
        image: 'ghcr.io/mlibrary/my-drupal-image:1.0',
        host: 'cms.my-site.lib.umich.edu',
        certificate_manager: 'letsencrypt-staging',
        env: [
          { name: 'NAME', value: 'value' },
        ],
        secrets: [
          { name: 'name', key: 'KEY' },
        ],
      },
    },
  },
}
