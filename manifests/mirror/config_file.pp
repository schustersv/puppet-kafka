# @summary
#   This class handles the Kafka mirro config files.
# @api private
define kafka::mirror::config_file (
  Boolean $manage_service                       = $kafka::mirror::manage_service,
  String[1] $service_name                       = $kafka::mirror::service_name,
  Boolean $service_restart                      = $kafka::mirror::service_restart,
  Hash[String[1], Any] $config                  = $kafka::mirror::config,
  Stdlib::Absolutepath $config_dir              = $kafka::mirror::config_dir,
  String[1] $user_name                          = $kafka::mirror::user_name,
  String[1] $group_name                         = $kafka::mirror::group_name,
  Stdlib::Filemode $config_mode                 = $kafka::mirror::config_mode,
  Boolean $manage_log4j                         = $kafka::mirror::manage_log4j,
  Pattern[/[1-9][0-9]*[KMG]B/] $log_file_size   = $kafka::mirror::log_file_size,
  Integer[1, 50] $log_file_count                = $kafka::mirror::log_file_count,
) {
  assert_private()

  if ($manage_service and $service_restart) {
    $config_notify = Service[$service_name]
  } else {
    $config_notify = undef
  }

  $doctag = "${name}configs"
  file { "${config_dir}/${name}.properties":
    ensure  => file,
    owner   => $user_name,
    group   => $group_name,
    mode    => $config_mode,
    content => template('kafka/properties.erb'),
    notify  => $config_notify,
    require => File[$config_dir],
  }

  if $manage_log4j {
    file { "${config_dir}/log4j.properties":
      ensure  => file,
      owner   => $user_name,
      group   => $group_name,
      mode    => $config_mode,
      content => epp('kafka/log4j.properties.epp', { 'log_file_size' => $log_file_size, 'log_file_count' => $log_file_count }),
      notify  => $config_notify,
      require => File[$config_dir],
    }
  }
}
