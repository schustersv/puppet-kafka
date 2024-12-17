# @summary
#   This class handles the Kafka (broker) service.
#
# @api private
#
class kafka::broker::service (
  Boolean $manage_service                    = $kafka::broker::manage_service,
  Enum['running', 'stopped'] $service_ensure = $kafka::broker::service_ensure,
  String[1] $service_name                    = $kafka::broker::service_name,
  Boolean $service_restart                   = $kafka::broker::service_restart,
  String[1] $user_name                       = $kafka::broker::user_name,
  String[1] $group_name                      = $kafka::broker::group_name,
  Stdlib::Absolutepath $config_dir           = $kafka::broker::config_dir,
  Stdlib::Absolutepath $log_dir              = $kafka::broker::log_dir,
  Stdlib::Absolutepath $bin_dir              = $kafka::broker::bin_dir,
  Array[String[1]] $service_requires         = $kafka::broker::service_requires,
  Optional[String[1]] $limit_nofile          = $kafka::broker::limit_nofile,
  Optional[String[1]] $limit_core            = $kafka::broker::limit_core,
  Optional[String[1]] $timeout_stop          = $kafka::broker::timeout_stop,
  Boolean $exec_stop                         = $kafka::broker::exec_stop,
  Boolean $daemon_start                      = $kafka::broker::daemon_start,
  Hash $env                                  = $kafka::broker::env,
  String[1] $heap_opts                       = $kafka::broker::heap_opts,
  String[1] $jmx_opts                        = $kafka::broker::jmx_opts,
  String[1] $log4j_opts                      = $kafka::broker::log4j_opts,
  String[0] $opts                            = $kafka::broker::opts,
) {
  assert_private()

  if !defined(Class['kafka::service']) {
    class { 'kafka::service':
      manage_service   => $manage_service,
      service_ensure   => $service_ensure,
      service_name     => $service_name,
      service_restart  => $service_restart,
      user_name        => $user_name,
      group_name       => $group_name,
      config_dir       => $config_dir,
      log_dir          => $log_dir,
      bin_dir          => $bin_dir,
      service_requires => $service_requires,
      limit_nofile     => $limit_nofile,
      limit_core       => $limit_core,
      timeout_stop     => $timeout_stop,
      exec_stop        => $exec_stop,
      daemon_start     => $daemon_start,
      env              => $env,
      heap_opts        => $heap_opts,
      jmx_opts         => $jmx_opts,
      log4j_opts       => $log4j_opts,
      opts             => $opts,
    }
  }
}
