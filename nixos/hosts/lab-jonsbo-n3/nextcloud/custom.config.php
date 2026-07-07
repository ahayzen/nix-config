<?php
$CONFIG = array(
    // Redis caching
    // https://docs.nextcloud.com/server/19/admin_manual/configuration_server/caching_configuration.html#id2
    'memcache.distributed' => '\OC\Memcache\Redis',
    'memcache.locking' => '\OC\Memcache\Redis',
    'redis' => array(
      'host' => 'nextcloud-redis',
      'port' => 6379,
    ),

    // Trust traefik, group-proxy, and VPN tunnel
    // https://docs.nextcloud.com/server/34/admin_manual/configuration_server/reverse_proxy_configuration.html#defining-trusted-proxies
    'trusted_proxies' => array(
        "172.20.20.0/24,172.28.228.128/25",
    ),

    // Do not include external storage in quotes
    // As we set quota to zero to only allow external storage
    // https://docs.nextcloud.com/server/20/admin_manual/configuration_user/user_configuration.html#setting-storage-quotas
    'quota_include_external_storage' => false,

    // Disable default skeleton directory
    // https://docs.nextcloud.com/server/latest/admin_manual/configuration_files/default_files_configuration.html
    'skeletondirectory' => '',

    // https://docs.nextcloud.com/server/20/admin_manual/configuration_files/file_versioning.html
    'versions_retention_obligation' => 'disabled',
);
?>
