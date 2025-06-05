interface DatabaseConfig {
  url: string;
}

interface ServerConfig {
  port: number;
  host: string;
}

interface AppConfig {
  database: DatabaseConfig;
  server: ServerConfig;
}

interface ValidationResult {
  isValid: boolean;
  errors: string[];
}

export function validateConfig(config: unknown): ValidationResult {
  const errors: string[] = [];

  if (!config || typeof config !== 'object') {
    return { isValid: false, errors: ['Configuration must be an object'] };
  }

  const appConfig = config as AppConfig;

  // Validate database configuration
  if (!appConfig.database) {
    errors.push('Database configuration is required');
  } else {
    if (!appConfig.database.url || typeof appConfig.database.url !== 'string') {
      errors.push('Database URL must be a string');
    } else if (!appConfig.database.url.startsWith('postgresql://')) {
      errors.push('Database URL must be a valid PostgreSQL connection string');
    }
  }

  // Validate server configuration
  if (!appConfig.server) {
    errors.push('Server configuration is required');
  } else {
    if (typeof appConfig.server.port !== 'number') {
      errors.push('Server port must be a number');
    }
    if (!appConfig.server.host || typeof appConfig.server.host !== 'string') {
      errors.push('Server host must be a string');
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
} 