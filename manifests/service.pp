# @summary
#   This class handles common Kafka service configuration.
#
# @api private
#
class kafka::service (
  Boolean $manage_service,
  Enum['running', 'stopped'] $service_ensure,
  String[1] $service_name,
  Boolean $service_restart,
  String[1] $user_name,
  String[1] $group_name,
  Stdlib::Absolutepath $config_dir,
  Stdlib::Absolutepath $log_dir,
  Stdlib::Absolutepath $bin_dir,
  Array[String[1]] $service_requires,
  Optional[String[1]] $limit_nofile ,
  Optional[String[1]] $limit_core,
  Optional[String[1]] $timeout_stop,
  Boolean $exec_stop,
  Boolean $daemon_start,
  Hash $env,
  String[1] $heap_opts,
  String[1] $jmx_opts,
  String[1] $log4j_opts,
  String[0] $opts,
) {
  assert_private()

  if $manage_service {
    include systemd

    if size($service_requires) == 0 {
      $_after_entry = {}
    } else {
      $_after_entry = {
        'After' => join($service_requires, ','),
        'Wants' => join($service_requires, ','),
      }
    }
    $_service_name = $service_name ? {
      'kafka' => 'broker',
      default => split($service_name, '-')[1],
    }
    $_unit_entry = {
      'Description'   => "Apache Kafka server (${_service_name})",
      'Documentation' => 'https://kafka.apache.org/documentation.html',
    } + $_after_entry

    $env_defaults = {
      'KAFKA_HEAP_OPTS'  => $heap_opts,
      'KAFKA_JMX_OPTS'   => $jmx_opts,
      'KAFKA_LOG4J_OPTS' => $log4j_opts,
      'KAFKA_OPTS'       => $opts,
      'LOG_DIR'          => $log_dir,
    }
    $environment = sort(join_keys_to_values(deep_merge($env_defaults, $env), '='))

    if $daemon_start {
      $_type = 'forking'
      $_exec_opt = '-daemon '
    } else {
      $_type = 'simple'
      $_exec_opt = ''
    }
    $_exec_stop = $exec_stop ? {
      false => {},
      true  => { 'ExecStop' => "${bin_dir}/kafka-server-stop.sh" },
    }
    $_limit_core = $limit_core ? {
      undef   => {},
      default => { 'LimitCORE' => $limit_core }
    }
    $_limit_nofile = $limit_nofile ? {
      undef   => {},
      default => { 'LimitNOFILE' => $limit_nofile }
    }
    $_timeout_stop = $timeout_stop ? {
      undef   => {},
      default => { 'TimeoutStopSec' => $timeout_stop }
    }
    $_service_entry = {
      'User'             => $user_name,
      'Group'            => $group_name,
      'SyslogIdentifier' => $service_name,
      'Environment'      => $environment,
      'Type'             => $_type,
      'ExecStart'        => "${bin_dir}/kafka-server-start.sh ${_exec_opt}${config_dir}/server.properties",
    } + $_exec_stop + $_timeout_stop + $_limit_nofile + $_limit_core

    systemd::manage_unit { "${service_name}.service":
      ensure          => 'present',
      mode            => '0644',
      service_restart => $service_restart,
      service_entry   => $_service_entry,
      unit_entry      => $_unit_entry,
      install_entry   => {
        'WantedBy' => 'multi-user.target',
      },
    }
    -> service { $service_name:
      ensure     => $service_ensure,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }
  }
}
