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

    // Disable default skeleton directory
    // https://docs.nextcloud.com/server/latest/admin_manual/configuration_files/default_files_configuration.html
    'skeletondirectory' => '',

    // https://docs.nextcloud.com/server/20/admin_manual/configuration_files/file_versioning.html
    'versions_retention_obligation' => 'disabled',
);
?>
