enum Environment { development, staging, production }

class AppConfig {
  static const Environment environment = Environment.development;

  // API Configuration
  static String get apiBaseUrl {
    switch (environment) {
      case Environment.development:
        return 'http://safty-zone-env.eba-rhpc9ydc.us-east-1.elasticbeanstalk.com';
      case Environment.staging:
        return 'http://safty-zone-env.eba-rhpc9ydc.us-east-1.elasticbeanstalk.com';
      case Environment.production:
        return 'https://api.safetyzone.com';
    }
  }

  // SSL Configuration
  static bool get shouldBypassSSLVerification =>
      environment == Environment.development;

  // Feature flags
  static bool get enableDebugLogs => environment != Environment.production;
}
